import from serper_client { search_google_shopping }

with entry {
    results = search_google_shopping("AirPods Pro 2", "f9181c85e50b3547e7d0df656dbebc91d1713cb5", 5);
    print("Got results: " + str(len(results)));
    for r in results {
        print(r.get("title", "") + " - " + r.get("price", ""));
    }
}