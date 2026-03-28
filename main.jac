"""PriceComparator - Google Shopping prices + AI recommendations."""

cl {
    import from frontend { app as ClientApp }

    def:pub app {
        return <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }
import from ddgs { DDGS }
import from serper_client { search_google_shopping }

glob SERPER_API_KEY = "f9181c85e50b3547e7d0df656dbebc91d1713cb5";

def google_shopping_search(query: str, num_results: int = 20) -> list[dict] {
    result = search_google_shopping(query, SERPER_API_KEY, num_results);
    print("DEBUG: google_shopping got " + str(len(result)) + " results");
    return result;
}

def ddgs_fallback_search(query: str, max_results: int = 10) -> list[dict] {
    ddgs = DDGS();
    return [r for r in ddgs.text(query, max_results=max_results)];
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

obj ExtractedPrice {
    has store_name: str;
    has price: float;
    has currency: str;
    has available: bool;
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

obj DealVerdict {
    has is_good_deal: bool;
    has verdict: str;
    has savings_tip: str;
}

sem PriceAnalysis.recommendation = "A brief recommendation on where to buy based on price comparison";
sem NearbyStore.distance_miles = "Estimated distance in miles from the user's location";
sem NearbyStore.store_type = "Type of store, e.g. supermarket, pharmacy, electronics, department store";
sem ExtractedPrice.price = "The numeric price value, or 0.0 if not found";
sem ExtractedPrice.store_name = "The name of the store or retailer";
sem ExtractedPrice.available = "Whether the product appears to be in stock";
sem AlternativeProduct.name = "The full product name of the alternative";
sem AlternativeProduct.reason = "A concise 1-2 sentence explanation of why this is a good alternative";
sem AlternativeProduct.search_query = "The exact search query to use on Google Shopping to find this product";
sem ProductRecommendation.alternatives = "A list of 2-3 alternative products. Include cheaper options AND similar-priced competitors";
sem ProductRecommendation.comparison_summary = "A 2-3 sentence overview of the competitive landscape";
sem DealVerdict.is_good_deal = "True if this price represents good value";
sem DealVerdict.verdict = "A brief verdict like 'Great deal' or 'Overpriced'";
sem DealVerdict.savings_tip = "A specific tip to save money";

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

"""Extract the store name and price from a search result snippet. If no price found, set price to 0.0."""
def extract_price_from_snippet(product_name: str, snippet: str, source: str) -> ExtractedPrice by llm();

"""Suggest 2-3 alternative products the user should consider. Include cheaper and similar-priced options."""
def suggest_alternatives(product_name: str, product_category: str, current_best_price: float) -> ProductRecommendation by llm();

"""Determine if a price is a good deal compared to the average."""
def evaluate_deal(product_name: str, store_name: str, store_price: float, avg_price: float) -> DealVerdict by llm();

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

def parse_shopping_results(shopping_results: list[dict], selected_stores: list = []) -> list[dict] {
    extracted = [];
    for r in shopping_results {
        store_name = r.get("source", "Unknown");
        price_str = r.get("price", "");
        link = r.get("link", "");
        title = r.get("title", "");
        rating = r.get("rating", None);
        reviews = r.get("ratingCount", None);

        price_val = 0.0;
        if price_str {
            try {
                cleaned = price_str.replace("$", "").replace(",", "").strip();
                price_val = float(cleaned);
            } except Exception { continue; }
        }
        if price_val <= 0.0 { continue; }

        if len(selected_stores) > 0 {
            store_lower = store_name.lower();
            matched = False;
            for s in selected_stores {
                if s.lower() in store_lower or store_lower in s.lower() { matched = True; break; }
            }
            if not matched { continue; }
        }

        extracted.append({"store": store_name, "price": price_val, "currency": "USD", "available": True, "url": link, "title": title, "rating": rating, "reviews": reviews});
    }
    return extracted;
}

# ─────────────────────────────────────────────
# LivePriceSearch — NO AI, just raw prices
# ─────────────────────────────────────────────

walker:pub LivePriceSearch {
    has product_name: str;
    has selected_stores: list = [];

    can run with Root entry {
        shopping_results = google_shopping_search(self.product_name);

        if len(shopping_results) > 0 {
            extracted_prices = parse_shopping_results(shopping_results, selected_stores=self.selected_stores);
            print("DEBUG LivePriceSearch: " + str(len(extracted_prices)) + " prices");

            if len(extracted_prices) > 0 {
                report {
                    "product": self.product_name,
                    "source": "google_shopping",
                    "prices": extracted_prices[:10],
                    "analysis": {
                        "best_store": extracted_prices[0]["store"],
                        "worst_store": extracted_prices[0]["store"],
                        "avg_price": 0.0,
                        "recommendation": "Prices from Google Shopping"
                    },
                    "deal_evaluation": {}
                };
                return;
            }
        }

        report {"error": "No results found for " + self.product_name};
    }
}

# ─────────────────────────────────────────────
# CrossProductSearch — NO AI, just raw prices + alternatives
# ─────────────────────────────────────────────

walker:pub CrossProductSearch {
    has product_name: str;
    has selected_stores: list = [];
    has max_alternatives: int = 3;

    can run with Root entry {
        original_results = google_shopping_search(self.product_name);
        original_prices = [];

        if len(original_results) > 0 {
            original_prices = parse_shopping_results(original_results, selected_stores=self.selected_stores);
        }

        original_best_price = 0.0;
        if len(original_prices) > 0 {
            original_best_price = original_prices[0]["price"];
            for p in original_prices { if p["price"] < original_best_price { original_best_price = p["price"]; } }
        }

        # AI: get category and alternatives
        category = str(categorize_product(self.product_name)).split(".")[-1].lower();
        recommendations = suggest_alternatives(self.product_name, category, original_best_price);

        alternatives_with_prices = [];
        alt_count = 0;
        for alt in recommendations.alternatives {
            if alt_count >= self.max_alternatives { break; }

            alt_results = google_shopping_search(alt.search_query);
            alt_prices = [];
            if len(alt_results) > 0 {
                alt_prices = parse_shopping_results(alt_results, selected_stores=self.selected_stores);
            }

            alt_best_price = 0.0;
            alt_best_store = "";
            alt_best_url = "";
            if len(alt_prices) > 0 {
                alt_best_price = alt_prices[0]["price"];
                alt_best_store = alt_prices[0]["store"];
                alt_best_url = alt_prices[0]["url"];
                for p in alt_prices {
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
                "all_prices": alt_prices[:3],
                "rating": alt_prices[0].get("rating", None) if len(alt_prices) > 0 else None,
                "reviews": alt_prices[0].get("reviews", None) if len(alt_prices) > 0 else None
            });
            alt_count = alt_count + 1;
        }

        report {
            "product": self.product_name,
            "category": category,
            "source": "google_shopping" if len(original_results) > 0 else "duckduckgo_fallback",
            "original": {
                "name": self.product_name,
                "best_price": original_best_price,
                "prices": original_prices[:10],
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
