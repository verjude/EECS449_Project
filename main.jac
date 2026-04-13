"""PriceComparator - Compare prices across Target, CVS, and Walgreens.
   AI features: size-aware value analysis, store-brand alternatives."""

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

def search_product_at_stores(product_name: str, store_names: list) -> list[dict] {
    results = search_store_prices(product_name, store_names, results_per_store=5);
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

obj NearbyStore {
    has name: str;
    has address: str;
    has distance_miles: float;
    has store_type: str;
}

# AI Analysis: understands product sizes and calculates unit pricing
obj SmartPriceAnalysis {
    has best_value_product: str;
    has best_value_store: str;
    has best_value_price: float;
    has unit_price_note: str;
    has size_warning: str;
    has recommendation: str;
}

# AI Analysis: finds store-brand alternatives
obj StoreBrandSuggestion {
    has has_store_brand: bool;
    has store_brand_name: str;
    has store_brand_store: str;
    has estimated_savings_pct: float;
    has explanation: str;
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

sem NearbyStore.distance_miles = "Estimated distance in miles from the user's location";
sem NearbyStore.store_type = "Type of store, e.g. supermarket, pharmacy, electronics, department store";

sem SmartPriceAnalysis.best_value_product = "The specific product listing that offers the best value per unit (e.g. 'Tylenol Extra Strength 100ct at CVS')";
sem SmartPriceAnalysis.best_value_store = "The store name where the best value is found";
sem SmartPriceAnalysis.best_value_price = "The price of the best value product";
sem SmartPriceAnalysis.unit_price_note = "A brief note about unit pricing, e.g. 'CVS 100ct ($0.10/caplet) vs Target 24ct ($0.19/caplet)'. If you cannot determine unit counts, say 'Unable to determine unit prices from product titles'";
sem SmartPriceAnalysis.size_warning = "Warning if some results are different sizes, travel packs, or bundles that make direct comparison misleading. Empty string if all products appear comparable";
sem SmartPriceAnalysis.recommendation = "A 1-2 sentence practical recommendation for the shopper";

sem StoreBrandSuggestion.has_store_brand = "True if any of the results include a store-brand/generic alternative (e.g. up&up for Target, CVS Health for CVS, Walgreens brand for Walgreens, Equate for Walmart)";
sem StoreBrandSuggestion.store_brand_name = "The name of the store-brand product found in the results (e.g. 'CVS Extra Strength Acetaminophen'). Empty string if none found";
sem StoreBrandSuggestion.store_brand_store = "Which store sells the store-brand alternative";
sem StoreBrandSuggestion.estimated_savings_pct = "Estimated percentage savings of store brand vs name brand. 0 if no store brand found";
sem StoreBrandSuggestion.explanation = "A brief explanation like 'CVS brand has the same active ingredient (500mg acetaminophen) at 42% less than Tylenol'. If no store brand found, suggest the user search for the generic name (e.g. 'Try searching acetaminophen to find store-brand options')";

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

"""Given a location, return a list of well-known stores nearby."""
def find_nearby_stores(location: str) -> list[NearbyStore] by llm();

"""You are a helpful shopping assistant. Provide advice about products and pricing. Use web search if needed."""
def ask_ai(history: list[dict]) -> str by llm(tools=[web_search]);

"""Suggest 2-3 alternative products the user should consider. Include cheaper and similar-priced options."""
def suggest_alternatives(product_name: str, product_category: str, current_best_price: float) -> ProductRecommendation by llm();

"""You are a smart shopping analyst. Given a product name and a list of search results
(each with store name, product title, and price), analyze the results considering:
1. Different pack sizes (10ct vs 50ct vs 100ct) — calculate per-unit price when possible
2. Travel/trial sizes vs full sizes
3. Different formulations (gels vs caplets vs tablets)
4. Bundles vs single products
Identify which listing is truly the best VALUE (not just cheapest price)."""
def analyze_smart_prices(
    product_name: str,
    results: list[dict]
) -> SmartPriceAnalysis by llm();

"""You are a store-brand expert. Given a product name and search results from stores,
identify if any results are store-brand/generic alternatives. Common store brands:
- Target: up&up, Good & Gather
- CVS: CVS Health, CVS Pharmacy brand, Gold Emblem
- Walgreens: Walgreens brand, Well at Walgreens, Nice!
- Walmart: Equate, Great Value
Compare the store brand to the name brand and explain the value proposition."""
def find_store_brand_alternative(
    product_name: str,
    results: list[dict]
) -> StoreBrandSuggestion by llm();

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
            ai_prices = [];
            for s in self.stores { ai_prices.append({"store": s["name"], "price": s["price"]}); }
            analysis = analyze_smart_prices(self.product_name, ai_prices);
            report {"best_store": analysis.best_value_store, "worst_store": "", "avg_price": analysis.best_value_price, "recommendation": analysis.recommendation, "stores": self.stores};
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

        all_prices.append({"store": store_name, "title": title, "price": price_val, "url": link, "rating": rating});
    }

    # Group by store
    store_groups = [];
    for p in all_prices {
        store = p["store"];
        found = False;
        for g in store_groups {
            if g["store"] == store {
                g["products"].append({"title": p["title"], "price": p["price"], "url": p["url"], "rating": p["rating"]});
                found = True;
                break;
            }
        }
        if not found {
            store_groups.append({"store": store, "products": [{"title": p["title"], "price": p["price"], "url": p["url"], "rating": p["rating"]}]});
        }
    }

    # Sort products within each store by price
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

    # Sort store groups by cheapest product
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

def flatten_for_ai(store_groups: list[dict]) -> list[dict] {
    flat = [];
    for g in store_groups {
        for p in g["products"] {
            flat.append({"store": g["store"], "title": p["title"], "price": p["price"]});
        }
    }
    return flat;
}

# ─────────────────────────────────────────────
# LivePriceSearch — grouped by store + AI insights
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
            ai_data = flatten_for_ai(store_groups);
            print("DEBUG LivePriceSearch: " + str(len(ai_data)) + " prices in " + str(len(store_groups)) + " stores");

            if len(ai_data) > 0 {
                # AI #1: Smart price analysis (size-aware)
                smart_analysis = {};
                try {
                    analysis = analyze_smart_prices(self.product_name, ai_data);
                    smart_analysis = {
                        "best_value_product": analysis.best_value_product,
                        "best_value_store": analysis.best_value_store,
                        "best_value_price": analysis.best_value_price,
                        "unit_price_note": analysis.unit_price_note,
                        "size_warning": analysis.size_warning,
                        "recommendation": analysis.recommendation
                    };
                    print("DEBUG: Smart analysis done");
                } except Exception {
                    print("DEBUG: Smart analysis failed, using basic stats");
                    best = ai_data[0];
                    for p in ai_data { if p["price"] < best["price"] { best = p; } }
                    smart_analysis = {
                        "best_value_product": best["title"],
                        "best_value_store": best["store"],
                        "best_value_price": best["price"],
                        "unit_price_note": "",
                        "size_warning": "",
                        "recommendation": "Cheapest option at " + best["store"] + " ($" + str(best["price"]) + ")."
                    };
                }

                # AI #2: Store-brand alternative
                store_brand = {};
                try {
                    sb = find_store_brand_alternative(self.product_name, ai_data);
                    store_brand = {
                        "has_store_brand": sb.has_store_brand,
                        "store_brand_name": sb.store_brand_name,
                        "store_brand_store": sb.store_brand_store,
                        "estimated_savings_pct": sb.estimated_savings_pct,
                        "explanation": sb.explanation
                    };
                    print("DEBUG: Store brand analysis done");
                } except Exception {
                    print("DEBUG: Store brand analysis failed");
                    store_brand = {"has_store_brand": False, "store_brand_name": "", "store_brand_store": "", "estimated_savings_pct": 0, "explanation": ""};
                }

                report {
                    "product": self.product_name,
                    "source": "google_shopping",
                    "store_groups": store_groups,
                    "smart_analysis": smart_analysis,
                    "store_brand": store_brand,
                    "analysis": {
                        "best_store": smart_analysis["best_value_store"],
                        "worst_store": "",
                        "avg_price": 0.0,
                        "recommendation": smart_analysis["recommendation"]
                    },
                    "deal_evaluation": {}
                };
                return;
            }
        }

        # No results found — get LLM alternatives and search for them at stores
        category = "other";
        try {
            category = str(categorize_product(self.product_name)).split(".")[-1].lower();
        } except Exception { }

        alternatives = [];
        ai_summary = "";
        try {
            rec = suggest_alternatives(self.product_name, category, 0.0);
            ai_summary = rec.comparison_summary;
            alt_count = 0;
            for alt in rec.alternatives {
                if alt_count >= 3 { break; }
                alt_raw = search_product_at_stores(alt.search_query, stores_to_search);
                alt_groups = parse_and_group_by_store(alt_raw);
                alt_flat = flatten_for_ai(alt_groups);
                alt_best_price = 0.0;
                alt_best_store = "";
                if len(alt_flat) > 0 {
                    alt_best_price = alt_flat[0]["price"];
                    alt_best_store = alt_flat[0]["store"];
                    for p in alt_flat {
                        if p["price"] < alt_best_price {
                            alt_best_price = p["price"];
                            alt_best_store = p["store"];
                        }
                    }
                }
                alternatives.append({
                    "name": alt.name,
                    "reason": alt.reason,
                    "store_groups": alt_groups,
                    "best_price": alt_best_price,
                    "best_store": alt_best_store
                });
                alt_count = alt_count + 1;
            }
        } except Exception {
            try {
                ai_summary = ask_ai([{"role": "user", "content": "I searched for '" + self.product_name + "' but found no results at retail stores. Suggest 3 similar products to search for instead, and briefly explain why each is a good alternative."}]);
            } except Exception { }
        }

        report {
            "product": self.product_name,
            "error": "No results found at the selected stores.",
            "no_store_results": True,
            "suggestions": alternatives,
            "ai_summary": ai_summary
        };
    }
}

# ─────────────────────────────────────────────
# CrossProductSearch — grouped + AI alternatives
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
        ai_data = flatten_for_ai(store_groups);

        original_best_price = 0.0;
        if len(ai_data) > 0 {
            original_best_price = ai_data[0]["price"];
            for p in ai_data { if p["price"] < original_best_price { original_best_price = p["price"]; } }
        }

        # AI: smart analysis
        smart_analysis = {};
        try {
            analysis = analyze_smart_prices(self.product_name, ai_data);
            smart_analysis = {
                "best_value_product": analysis.best_value_product,
                "best_value_store": analysis.best_value_store,
                "best_value_price": analysis.best_value_price,
                "unit_price_note": analysis.unit_price_note,
                "size_warning": analysis.size_warning,
                "recommendation": analysis.recommendation
            };
        } except Exception {
            smart_analysis = {"best_value_product": "", "best_value_store": "", "best_value_price": 0, "unit_price_note": "", "size_warning": "", "recommendation": ""};
        }

        # AI: store brand
        store_brand = {};
        try {
            sb = find_store_brand_alternative(self.product_name, ai_data);
            store_brand = {
                "has_store_brand": sb.has_store_brand,
                "store_brand_name": sb.store_brand_name,
                "store_brand_store": sb.store_brand_store,
                "estimated_savings_pct": sb.estimated_savings_pct,
                "explanation": sb.explanation
            };
        } except Exception {
            store_brand = {"has_store_brand": False, "store_brand_name": "", "store_brand_store": "", "estimated_savings_pct": 0, "explanation": ""};
        }

        # AI: product alternatives
        category = str(categorize_product(self.product_name)).split(".")[-1].lower();
        recommendations = suggest_alternatives(self.product_name, category, original_best_price);

        alternatives_with_prices = [];
        alt_count = 0;
        for alt in recommendations.alternatives {
            if alt_count >= self.max_alternatives { break; }

            alt_raw = search_product_at_stores(alt.search_query, stores_to_search);
            alt_groups = parse_and_group_by_store(alt_raw);
            alt_flat = flatten_for_ai(alt_groups);

            alt_best_price = 0.0;
            alt_best_store = "";
            alt_best_url = "";
            if len(alt_flat) > 0 {
                alt_best_price = alt_flat[0]["price"];
                alt_best_store = alt_flat[0]["store"];
                for p in alt_flat {
                    if p["price"] < alt_best_price {
                        alt_best_price = p["price"];
                        alt_best_store = p["store"];
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
                "best_url": "",
                "price_diff": round(price_diff, 2),
                "price_diff_pct": round(price_diff_pct, 1),
                "store_groups": alt_groups,
                "rating": None,
                "reviews": None
            });
            alt_count = alt_count + 1;
        }

        no_store_results = len(store_groups) == 0;
        suggestions = [{"name": alt.name, "reason": alt.reason, "search_query": alt.search_query} for alt in recommendations.alternatives] if no_store_results else [];

        report {
            "product": self.product_name,
            "category": category,
            "source": "google_shopping",
            "no_store_results": no_store_results,
            "suggestions": suggestions,
            "original": {
                "name": self.product_name,
                "best_price": original_best_price,
                "store_groups": store_groups,
                "deal_evaluation": {}
            },
            "smart_analysis": smart_analysis,
            "store_brand": store_brand,
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
