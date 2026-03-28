"""PriceComparator - Compare prices across Target, CVS, and Walgreens."""

cl {
    import from frontend { app as ClientApp }

    def:pub app {
        return <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }
import from ddgs { DDGS }
import from serper_client { search_store_prices }

glob SERPER_API_KEY = "f9181c85e50b3547e7d0df656dbebc91d1713cb5";

def search_product_at_stores(product_name: str, store_names: list) -> list[dict] {
    results = search_store_prices(product_name, store_names, SERPER_API_KEY, 5);
    print("DEBUG: Got " + str(len(results)) + " total results across " + str(len(store_names)) + " stores");
    return results;
}

def web_search(query: str, max_results: int = 10) -> list[dict] {
    ddgs = DDGS();
    return [r for r in ddgs.text(query, max_results=max_results)];
}

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# ─────────────────────────────────────────────
# AI Types
# ─────────────────────────────────────────────

enum ProductCategory { PRODUCTIVITY, ELECTRONICS, GROCERIES, CLOTHING, HOME, HEALTH, BEAUTY, BABY, CHILDREN, OTHER }

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

obj AlternativeProduct {
    has name: str;
    has reason: str;
    has search_query: str;
}

obj ProductRecommendation {
    has alternatives: list[AlternativeProduct];
    has comparison_summary: str;
}

sem PriceAnalysis.recommendation = "A brief recommendation on where to buy based on price comparison";
sem NearbyStore.distance_miles = "Estimated distance in miles from the user's location";
sem NearbyStore.store_type = "Type of store, e.g. supermarket, pharmacy, electronics, department store";
sem AlternativeProduct.name = "The full product name of the alternative";
sem AlternativeProduct.reason = "A concise 1-2 sentence explanation of why this is a good alternative";
sem AlternativeProduct.search_query = "The exact search query to use on Google Shopping to find this product";
sem ProductRecommendation.alternatives = "A list of 2-3 alternative products. Include cheaper options AND similar-priced competitors";
sem ProductRecommendation.comparison_summary = "A 2-3 sentence overview of the competitive landscape";

# ─────────────────────────────────────────────
# AI Functions
# ─────────────────────────────────────────────

"""Categorize a product based on its name."""
def categorize_product(product_name: str) -> ProductCategory by llm();

"""Analyze price data and provide recommendation."""
def analyze_prices(product_name: str, store_prices: list[dict]) -> PriceAnalysis by llm();

"""Given a location, return a list of well-known stores nearby."""
def find_nearby_stores(location: str) -> list[NearbyStore] by llm();

"""You are a helpful shopping assistant. Provide advice about products and pricing. Use web search if needed."""
def ask_ai(history: list[dict]) -> str by llm(tools=[web_search]);

"""Suggest 2-3 alternative products the user should consider. Include cheaper and similar-priced options."""
def suggest_alternatives(product_name: str, product_category: str, current_best_price: float) -> ProductRecommendation by llm();

# ─────────────────────────────────────────────
# Data Nodes
# ─────────────────────────────────────────────

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

# ─────────────────────────────────────────────
# Product Walkers
# ─────────────────────────────────────────────

walker:priv AddProduct {
    has title: str;
    can create with Root entry {
        category = str(categorize_product(self.title)).split(".")[-1].lower();
        new_product = here ++> Product(id=str(uuid4()), name=self.title, category=category);
        report {"id": new_product[0].id, "name": new_product[0].name, "category": new_product[0].category};
    }
}

walker:priv ListProducts {
    has products: list = [];
    can collect with Root entry { visit [-->]; }
    can gather with Product entry { self.products.append({"id": here.id, "name": here.name, "category": here.category}); }
    can report_all with Root exit { report self.products; }
}

walker:priv DeleteProduct {
    has product_id: str;
    can search with Root entry { visit [-->]; }
    can delete with Product entry { if here.id == self.product_id { del here; report {"deleted": self.product_id}; } }
}

# ─────────────────────────────────────────────
# Store Price Walkers
# ─────────────────────────────────────────────

walker:priv AddStorePrice {
    has product_id: str;
    has store_name: str;
    has price: float;
    has url: str = "";
    has last_updated: str = "";
    can search with Root entry { visit [-->]; }
    can add_store with Product entry {
        if here.id == self.product_id {
            here ++> Store(name=self.store_name, price=self.price, available=True, url=self.url, last_updated=self.last_updated);
            report {"product_id": here.id, "store": self.store_name, "price": self.price};
        }
    }
}

walker:priv ListStorePrices {
    has product_id: str;
    has stores: list = [];
    can search with Root entry { visit [-->]; }
    can collect with Product entry { if here.id == self.product_id { visit [-->]; } }
    can gather with Store entry { self.stores.append({"name": here.name, "price": here.price, "available": here.available, "url": here.url, "last_updated": here.last_updated}); }
    can report_all with Root exit { report self.stores; }
}

walker:priv UpdateStorePrice {
    has product_id: str;
    has store_name: str;
    has price: float;
    has last_updated: str = "";
    can search with Root entry { visit [-->]; }
    can find_product with Product entry { if here.id == self.product_id { visit [-->]; } }
    can update with Store entry { if here.name == self.store_name { here.price = self.price; here.last_updated = self.last_updated; report {"store": here.name, "price": here.price, "updated": True}; } }
}

walker:priv DeleteStore {
    has product_id: str;
    has store_name: str;
    can search with Root entry { visit [-->]; }
    can find_product with Product entry { if here.id == self.product_id { visit [-->]; } }
    can delete with Store entry { if here.name == self.store_name { del here; report {"deleted": self.store_name}; } }
}

walker:priv GetBestPrice {
    has product_id: str;
    has stores: list = [];
    can search with Root entry { visit [-->]; }
    can find_product with Product entry { if here.id == self.product_id { visit [-->]; } }
    can collect with Store entry { self.stores.append({"name": here.name, "price": here.price, "available": here.available, "url": here.url}); }
    can analyze with Root exit {
        if len(self.stores) > 0 {
            available_stores = [s for s in self.stores if s["available"]];
            if len(available_stores) > 0 {
                best = available_stores[0];
                for store in available_stores { if store["price"] < best["price"] { best = store; } }
                report {"best_store": best["name"], "best_price": best["price"], "url": best["url"], "all_stores": available_stores};
            } else { report {"error": "No available stores"}; }
        } else { report {"error": "No stores found"}; }
    }
}

walker:priv ComparePrices {
    has product_id: str;
    has product_name: str = "";
    has stores: list = [];
    can search with Root entry { visit [-->]; }
    can find_product with Product entry { if here.id == self.product_id { self.product_name = here.name; visit [-->]; } }
    can collect with Store entry { self.stores.append({"name": here.name, "price": here.price}); }
    can analyze with Root exit {
        if len(self.stores) > 0 and self.product_name {
            analysis = analyze_prices(self.product_name, self.stores);
            report {"best_store": analysis.best_store, "worst_store": analysis.worst_store, "avg_price": analysis.avg_price, "recommendation": analysis.recommendation, "stores": self.stores};
        } else { report {"error": "No data for comparison"}; }
    }
}

# ─────────────────────────────────────────────
# Global Store List Walkers
# ─────────────────────────────────────────────

walker:priv AddStoreEntry {
    has name: str;
    can create with Root entry {
        new_entry = here ++> StoreEntry(id=str(uuid4()), name=self.name);
        report {"id": new_entry[0].id, "name": new_entry[0].name};
    }
}

walker:priv ListStoreEntries {
    has entries: list = [];
    can collect with Root entry { visit [-->]; }
    can gather with StoreEntry entry { self.entries.append({"id": here.id, "name": here.name}); }
    can report_all with Root exit { report self.entries; }
}

walker:priv DeleteStoreEntry {
    has store_id: str;
    can search with Root entry { visit [-->]; }
    can delete with StoreEntry entry { if here.id == self.store_id { del here; report {"deleted": self.store_id}; } }
}

walker:priv FindNearbyStores {
    has location: str;
    can search with Root entry {
        results = find_nearby_stores(self.location);
        report [{"name": s.name, "address": s.address, "distance": s.distance_miles, "store_type": s.store_type} for s in results];
    }
}

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────

def parse_and_group_by_store(raw_results: list[dict]) -> list[dict] {
    """Parse results and group by store. Returns list of store groups:
    [{"store": "Target", "products": [{"title": "...", "price": 4.59, "url": "...", "rating": 4.8}, ...]}, ...]
    Each store's products are sorted by price ascending."""

    # Collect all valid prices
    all_prices = [];
    for r in raw_results {
        store_name = r.get("source", "Unknown");
        price_str = r.get("price", "");
        link = r.get("link", "");
        title = r.get("title", "");
        rating = r.get("rating", None);

        price_val = 0.0;
        if price_str {
            try {
                cleaned = price_str.replace("$", "").replace(",", "").strip();
                price_val = float(cleaned);
            } except Exception { continue; }
        }
        if price_val <= 0.0 { continue; }

        all_prices.append({
            "store": store_name,
            "title": title,
            "price": price_val,
            "url": link,
            "rating": rating
        });
    }

    # Group by store name
    store_names_seen = [];
    store_groups = [];

    for p in all_prices {
        store = p["store"];
        # Find if we already have this store group
        found = False;
        for g in store_groups {
            if g["store"] == store {
                g["products"].append({
                    "title": p["title"],
                    "price": p["price"],
                    "url": p["url"],
                    "rating": p["rating"]
                });
                found = True;
                break;
            }
        }
        if not found {
            store_groups.append({
                "store": store,
                "products": [{
                    "title": p["title"],
                    "price": p["price"],
                    "url": p["url"],
                    "rating": p["rating"]
                }]
            });
        }
    }

    # Sort products within each store by price ascending
    for g in store_groups {
        products = g["products"];
        n = len(products);
        i = 0;
        while i < n {
            j = 0;
            while j < n - i - 1 {
                if products[j]["price"] > products[j + 1]["price"] {
                    temp = products[j];
                    products[j] = products[j + 1];
                    products[j + 1] = temp;
                }
                j = j + 1;
            }
            i = i + 1;
        }
    }

    # Sort store groups by their cheapest product price
    ng = len(store_groups);
    i = 0;
    while i < ng {
        j = 0;
        while j < ng - i - 1 {
            price_a = store_groups[j]["products"][0]["price"] if len(store_groups[j]["products"]) > 0 else 9999;
            price_b = store_groups[j + 1]["products"][0]["price"] if len(store_groups[j + 1]["products"]) > 0 else 9999;
            if price_a > price_b {
                temp = store_groups[j];
                store_groups[j] = store_groups[j + 1];
                store_groups[j + 1] = temp;
            }
            j = j + 1;
        }
        i = i + 1;
    }

    return store_groups;
}

def flatten_prices(store_groups: list[dict]) -> list[dict] {
    """Flatten grouped results back to a flat list for the analysis field."""
    flat = [];
    for g in store_groups {
        for p in g["products"] {
            flat.append({
                "store": g["store"],
                "price": p["price"],
                "title": p["title"],
                "url": p["url"],
                "rating": p["rating"],
                "currency": "USD",
                "available": True,
                "reviews": None
            });
        }
    }
    return flat;
}

# ─────────────────────────────────────────────
# LivePriceSearch — grouped by store
# ─────────────────────────────────────────────

walker:pub LivePriceSearch {
    has product_name: str;
    has selected_stores: list = [];

    can run with Root entry {
        stores_to_search = self.selected_stores;
        if len(stores_to_search) == 0 {
            stores_to_search = ["Target", "CVS", "Walgreens"];
        }

        raw_results = search_product_at_stores(self.product_name, stores_to_search);

        if len(raw_results) > 0 {
            store_groups = parse_and_group_by_store(raw_results);
            flat_prices = flatten_prices(store_groups);
            print("DEBUG LivePriceSearch: " + str(len(flat_prices)) + " prices in " + str(len(store_groups)) + " stores");

            if len(flat_prices) > 0 {
                best = flat_prices[0];
                worst = flat_prices[0];
                total = 0.0;
                for p in flat_prices {
                    total = total + p["price"];
                    if p["price"] < best["price"] { best = p; }
                    if p["price"] > worst["price"] { worst = p; }
                }
                avg = total / len(flat_prices);

                report {
                    "product": self.product_name,
                    "source": "google_shopping",
                    "store_groups": store_groups,
                    "prices": flat_prices[:15],
                    "analysis": {
                        "best_store": best["store"],
                        "worst_store": worst["store"],
                        "avg_price": round(avg, 2),
                        "recommendation": "Best price at " + best["store"] + " ($" + str(best["price"]) + "). Average: $" + str(round(avg, 2)) + "."
                    },
                    "deal_evaluation": {}
                };
                return;
            }
        }

        report {"error": "No results found for " + self.product_name + " at selected stores."};
    }
}

# ─────────────────────────────────────────────
# CrossProductSearch — grouped by store + AI alternatives
# ─────────────────────────────────────────────

walker:pub CrossProductSearch {
    has product_name: str;
    has selected_stores: list = [];
    has max_alternatives: int = 3;

    can run with Root entry {
        stores_to_search = self.selected_stores;
        if len(stores_to_search) == 0 {
            stores_to_search = ["Target", "CVS", "Walgreens"];
        }

        raw_results = search_product_at_stores(self.product_name, stores_to_search);
        store_groups = parse_and_group_by_store(raw_results);
        flat_prices = flatten_prices(store_groups);

        original_best_price = 0.0;
        if len(flat_prices) > 0 {
            original_best_price = flat_prices[0]["price"];
            for p in flat_prices { if p["price"] < original_best_price { original_best_price = p["price"]; } }
        }

        category = str(categorize_product(self.product_name)).split(".")[-1].lower();
        recommendations = suggest_alternatives(self.product_name, category, original_best_price);

        alternatives_with_prices = [];
        alt_count = 0;
        for alt in recommendations.alternatives {
            if alt_count >= self.max_alternatives { break; }

            alt_raw = search_product_at_stores(alt.search_query, stores_to_search);
            alt_groups = parse_and_group_by_store(alt_raw);
            alt_flat = flatten_prices(alt_groups);

            alt_best_price = 0.0;
            alt_best_store = "";
            alt_best_url = "";
            if len(alt_flat) > 0 {
                alt_best_price = alt_flat[0]["price"];
                alt_best_store = alt_flat[0]["store"];
                alt_best_url = alt_flat[0]["url"];
                for p in alt_flat {
                    if p["price"] < alt_best_price {
                        alt_best_price = p["price"];
                        alt_best_store = p["store"];
                        alt_best_url = p["url"];
                    }
                }
            }

            price_diff = 0.0;
            price_diff_pct = 0.0;
            if original_best_price > 0.0 and alt_best_price > 0.0 {
                price_diff = alt_best_price - original_best_price;
                price_diff_pct = (price_diff / original_best_price) * 100;
            }

            alternatives_with_prices.append({
                "name": alt.name,
                "reason": alt.reason,
                "best_price": alt_best_price,
                "best_store": alt_best_store,
                "best_url": alt_best_url,
                "price_diff": round(price_diff, 2),
                "price_diff_pct": round(price_diff_pct, 1),
                "store_groups": alt_groups,
                "rating": None,
                "reviews": None
            });
            alt_count = alt_count + 1;
        }

        report {
            "product": self.product_name,
            "category": category,
            "source": "google_shopping",
            "original": {
                "name": self.product_name,
                "best_price": original_best_price,
                "prices": flat_prices[:15],
                "store_groups": store_groups,
                "deal_evaluation": {}
            },
            "alternatives": alternatives_with_prices,
            "ai_summary": recommendations.comparison_summary
        };
    }
}

# ─────────────────────────────────────────────
# Chat Walker
# ─────────────────────────────────────────────

walker:pub AskAI {
    has history: list;
    can answer with Root entry {
        response = ask_ai(self.history);
        report {"response": response};
    }
}
