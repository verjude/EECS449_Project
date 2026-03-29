"""serper_client.py - Google Shopping API via Serper.dev"""

import requests
import os
from dotenv import load_dotenv
load_dotenv()
DEFAULT_API_KEY = os.environ.get("SERPER_API_KEY", "")

def search_google_shopping(query, api_key=None, num_results=5):
    """Generic Google Shopping search."""
    if api_key is None:
        api_key = DEFAULT_API_KEY
    if not api_key:
        print("Serper: No API key set. Run: export SERPER_API_KEY='your_key'")
        return []
    try:
        response = requests.post(
            "https://google.serper.dev/shopping",
            headers={"X-API-KEY": api_key, "Content-Type": "application/json"},
            json={"q": query, "gl": "us", "hl": "en", "num": num_results},
            timeout=10
        )
        response.raise_for_status()
        return response.json().get("shopping", [])
    except Exception as e:
        print(f"Serper error: {e}")
        return []


def search_store_prices(product_name, store_names, api_key=None, results_per_store=5):
    """Search Google Shopping once per store, return combined results.
    
    Args:
        product_name: e.g. "tylenol extra strength"
        store_names: e.g. ["Target", "CVS", "Walgreens"]
        api_key: Serper.dev API key (reads from env if not provided)
        results_per_store: how many results per store (hard cap)
    
    Returns:
        List of dicts with store, price, title, url, rating, reviews
    """
    if api_key is None:
        api_key = DEFAULT_API_KEY
    if not api_key:
        print("Serper: No API key set. Run: export SERPER_API_KEY='your_key'")
        return []
    
    all_results = []
    
    for store_name in store_names:
        query = product_name + " " + store_name
        try:
            response = requests.post(
                "https://google.serper.dev/shopping",
                headers={"X-API-KEY": api_key, "Content-Type": "application/json"},
                json={"q": query, "gl": "us", "hl": "en", "num": results_per_store},
                timeout=10
            )
            response.raise_for_status()
            results = response.json().get("shopping", [])
            
            kept = 0
            for r in results:
                if kept >= results_per_store:
                    break
                source = r.get("source", "")
                # Only keep results actually from this store
                if store_name.lower() in source.lower() or source.lower() in store_name.lower():
                    all_results.append({
                        "source": source,
                        "price": r.get("price", ""),
                        "title": r.get("title", ""),
                        "link": r.get("link", ""),
                        "rating": r.get("rating", None),
                        "ratingCount": r.get("ratingCount", None),
                        "store_query": store_name
                    })
                    kept += 1
            
            print(f"Serper: {len(results)} raw results for '{query}', kept {kept} from {store_name}")
            
        except Exception as e:
            print(f"Serper error for {store_name}: {e}")
    
    print(f"Serper: {len(all_results)} total results across {len(store_names)} stores")
    return all_results