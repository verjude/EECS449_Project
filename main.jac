"""PriceComparator - A multi-user price comparison app with AI-powered analysis."""

cl {
    import from frontend { app as ClientApp }

    def:pub app {
        return <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }
import from duckduckgo_search { DDGS }

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# --- AI Types ---

enum ProductCategory { PRODUCTIVITY, ELECTRONICS, GROCERIES, CLOTHING, HOME, HEALTH, BEAUTY, BABY, CHILDREN, OTHER }
enum PriceRange { BUDGET, MODERATE, PREMIUM, LUXURY }

obj PriceAnalysis {
    has best_store: str;
    has worst_store: str;
    has avg_price: float;
    has recommendation: str;
}

obj NearbyStore {
    has name: str;
    has address: str;
    has distance_miles: float;
    has store_type: str;
}

obj ExtractedPrice {
    has store_name: str;
    has price: float;
    has currency: str;
    has available: bool;
}

sem PriceAnalysis.recommendation = "A brief recommendation on where to buy based on price comparison";
sem NearbyStore.distance_miles = "Estimated distance in miles from the user's location";
sem NearbyStore.store_type = "Type of store, e.g. supermarket, pharmacy, electronics, department store";
sem ExtractedPrice.price = "The numeric price value, or 0.0 if not found";
sem ExtractedPrice.store_name = "The name of the store or retailer";
sem ExtractedPrice.available = "Whether the product appears to be in stock";

"""Categorize a product based on its name."""
def categorize_product(product_name: str) -> ProductCategory by llm();

"""Determine the price range category of a product based on its price."""
def classify_price_range(price: float, product_name: str) -> PriceRange by llm();

"""Analyze price data and provide recommendation."""
def analyze_prices(product_name: str, store_prices: list[dict]) -> PriceAnalysis by llm();

"""Given a location, return a list of well-known stores nearby with their estimated distances."""
def find_nearby_stores(location: str) -> list[NearbyStore] by llm();

"""You are a helpful shopping assistant for a price comparator app.
Given the conversation history, provide helpful advice about products,
pricing strategies, and where to buy. Be concise and practical."""
def ask_ai(history: list[dict]) -> str by llm();

"""Extract the store name and price from a search result snippet for the given product.
If no price is found, set price to 0.0 and available to false."""
def extract_price_from_snippet(product_name: str, snippet: str, source: str) -> ExtractedPrice by llm();

# --- Data Nodes ---

node Product {
    has id: str,
        name: str,
        category: str = "other";
}

node Store {
    has name: str,
        price: float,
        last_updated: str = "",
        available: bool = True,
        url: str = "";
}

node StoreEntry {
    has id: str,
        name: str;
}

# --- Product Walkers ---

walker:priv AddProduct {
    has title: str;

    can create with Root entry {
        category = str(categorize_product(self.title)).split(".")[-1].lower();

        new_product = here ++> Product(
            id=str(uuid4()),
            name=self.title,
            category=category
        );
        report {
            "id": new_product[0].id,
            "name": new_product[0].name,
            "category": new_product[0].category
        };
    }
}

walker:priv ListProducts {
    has products: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with Product entry {
        self.products.append({
            "id": here.id,
            "name": here.name,
            "category": here.category
        });
    }

    can report_all with Root exit {
        report self.products;
    }
}

walker:priv DeleteProduct {
    has product_id: str;

    can search with Root entry {
        visit [-->];
    }

    can delete with Product entry {
        if here.id == self.product_id {
            del here;
            report {"deleted": self.product_id};
        }
    }
}

# --- Store Price Walkers ---

walker:priv AddStorePrice {
    has product_id: str;
    has store_name: str;
    has price: float;
    has url: str = "";
    has last_updated: str = "";

    can search with Root entry {
        visit [-->];
    }

    can add_store with Product entry {
        if here.id == self.product_id {
            here ++> Store(
                name=self.store_name,
                price=self.price,
                available=True,
                url=self.url,
                last_updated=self.last_updated
            );
            report {
                "product_id": here.id,
                "store": self.store_name,
                "price": self.price
            };
        }
    }
}

walker:priv ListStorePrices {
    has product_id: str;
    has stores: list = [];

    can search with Root entry {
        visit [-->];
    }

    can collect with Product entry {
        if here.id == self.product_id {
            visit [-->];
        }
    }

    can gather with Store entry {
        self.stores.append({
            "name": here.name,
            "price": here.price,
            "available": here.available,
            "url": here.url,
            "last_updated": here.last_updated
        });
    }

    can report_all with Root exit {
        report self.stores;
    }
}

walker:priv UpdateStorePrice {
    has product_id: str;
    has store_name: str;
    has price: float;
    has last_updated: str = "";

    can search with Root entry {
        visit [-->];
    }

    can find_product with Product entry {
        if here.id == self.product_id {
            visit [-->];
        }
    }

    can update with Store entry {
        if here.name == self.store_name {
            here.price = self.price;
            here.last_updated = self.last_updated;
            report {
                "store": here.name,
                "price": here.price,
                "updated": True
            };
        }
    }
}

walker:priv DeleteStore {
    has product_id: str;
    has store_name: str;

    can search with Root entry {
        visit [-->];
    }

    can find_product with Product entry {
        if here.id == self.product_id {
            visit [-->];
        }
    }

    can delete with Store entry {
        if here.name == self.store_name {
            del here;
            report {"deleted": self.store_name};
        }
    }
}

walker:priv GetBestPrice {
    has product_id: str;
    has stores: list = [];

    can search with Root entry {
        visit [-->];
    }

    can find_product with Product entry {
        if here.id == self.product_id {
            visit [-->];
        }
    }

    can collect with Store entry {
        self.stores.append({
            "name": here.name,
            "price": here.price,
            "available": here.available,
            "url": here.url
        });
    }

    can analyze with Root exit {
        if len(self.stores) > 0 {
            available_stores = [s for s in self.stores if s["available"]];
            if len(available_stores) > 0 {
                best = available_stores[0];
                for store in available_stores {
                    if store["price"] < best["price"] {
                        best = store;
                    }
                }
                report {
                    "best_store": best["name"],
                    "best_price": best["price"],
                    "url": best["url"],
                    "all_stores": available_stores
                };
            } else {
                report {"error": "No available stores"};
            }
        } else {
            report {"error": "No stores found"};
        }
    }
}

walker:priv ComparePrices {
    has product_id: str;
    has product_name: str = "";
    has stores: list = [];

    can search with Root entry {
        visit [-->];
    }

    can find_product with Product entry {
        if here.id == self.product_id {
            self.product_name = here.name;
            visit [-->];
        }
    }

    can collect with Store entry {
        self.stores.append({
            "name": here.name,
            "price": here.price
        });
    }

    can analyze with Root exit {
        if len(self.stores) > 0 and self.product_name {
            analysis = analyze_prices(self.product_name, self.stores);
            report {
                "best_store": analysis.best_store,
                "worst_store": analysis.worst_store,
                "avg_price": analysis.avg_price,
                "recommendation": analysis.recommendation,
                "stores": self.stores
            };
        } else {
            report {"error": "No data for comparison"};
        }
    }
}

# --- Global Store List Walkers ---

walker:priv AddStoreEntry {
    has name: str;

    can create with Root entry {
        new_entry = here ++> StoreEntry(
            id=str(uuid4()),
            name=self.name
        );
        report {
            "id": new_entry[0].id,
            "name": new_entry[0].name
        };
    }
}

walker:priv ListStoreEntries {
    has entries: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with StoreEntry entry {
        self.entries.append({
            "id": here.id,
            "name": here.name
        });
    }

    can report_all with Root exit {
        report self.entries;
    }
}

walker:priv DeleteStoreEntry {
    has store_id: str;

    can search with Root entry {
        visit [-->];
    }

    can delete with StoreEntry entry {
        if here.id == self.store_id {
            del here;
            report {"deleted": self.store_id};
        }
    }
}

walker:priv FindNearbyStores {
    has location: str;

    can search with Root entry {
        results = find_nearby_stores(self.location);
        report [
            {
                "name": s.name,
                "address": s.address,
                "distance": s.distance_miles,
                "store_type": s.store_type
            } for s in results
        ];
    }
}

# --- Live Price Search Walker (DuckDuckGo) ---

walker:pub LivePriceSearch {
    has product_name: str;

    can run with Root entry {
        raw_results = [];

        # 1. Search DuckDuckGo for prices across major stores
        try {
            with DDGS() as ddgs {
                search_results = ddgs.text(
                    self.product_name + " price buy site:amazon.com OR site:walmart.com OR site:bestbuy.com OR site:target.com OR site:ebay.com",
                    max_results=10
                );
                for r in search_results {
                    raw_results.append({
                        "title": r["title"],
                        "snippet": r["body"],
                        "url": r["href"],
                        "source": r["href"].split("/")[2].replace("www.", "")
                    });
                }
            }
        } except Exception as e {
            report {"error": "Search failed: " + str(e)};
            return;
        }

        if len(raw_results) == 0 {
            report {"error": "No search results found for " + self.product_name};
            return;
        }

        # 2. Use AI to extract prices from each snippet
        extracted_prices = [];
        for result in raw_results {
            try {
                extracted = extract_price_from_snippet(
                    self.product_name,
                    result["snippet"],
                    result["source"]
                );
                # Only keep results where AI found a valid price
                if extracted.price > 0.0 {
                    extracted_prices.append({
                        "store": extracted.store_name,
                        "price": extracted.price,
                        "currency": extracted.currency,
                        "available": extracted.available,
                        "url": result["url"]
                    });
                }
            } except Exception as e {
                continue;
            }
        }

        if len(extracted_prices) == 0 {
            report {"error": "Could not extract prices for " + self.product_name};
            return;
        }

        # 3. Run AI analysis on extracted prices
        analysis = analyze_prices(self.product_name, extracted_prices);

        report {
            "product": self.product_name,
            "prices": extracted_prices,
            "analysis": {
                "best_store": analysis.best_store,
                "worst_store": analysis.worst_store,
                "avg_price": analysis.avg_price,
                "recommendation": analysis.recommendation
            }
        };
    }
}

# --- Chat Walker ---

walker:pub AskAI {
    has history: list;

    can answer with Root entry {
        response = ask_ai(self.history);
        report {"response": response};
    }
}
