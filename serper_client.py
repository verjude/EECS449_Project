"""serper_client.py - Pure Python helper for Google Shopping API via Serper.dev"""

import requests


def search_google_shopping(query, api_key, num_results=20):
    """Call Serper.dev Google Shopping endpoint and return structured results."""
    if not api_key:
        print("Serper: No API key provided")
        return []
    try:
        response = requests.post(
            "https://google.serper.dev/shopping",
            headers={
                "X-API-KEY": api_key,
                "Content-Type": "application/json"
            },
            json={
                "q": query,
                "gl": "us",
                "hl": "en",
                "num": num_results
            },
            timeout=10
        )
        response.raise_for_status()
        data = response.json()
        results = data.get("shopping", [])
        print(f"Serper: Got {len(results)} results for '{query}'")
        return results
    except Exception as e:
        print(f"Serper error: {e}")
        return []