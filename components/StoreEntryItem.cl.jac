"""StoreEntryItem — a single row in the global store list."""

def:pub StoreEntryItem(
    store: dict,
    onDelete: any
) -> obj {
    return
        <div className="ingredient-item">
            <div
                className="ingredient-info"
                style={{"flex": "1"}}
            >
                <span
                    className="ingredient-name"
                    style={{"color": "#2c2010"}}
                >
                    {store.name}
                </span>
            </div>
            <div className="ingredient-meta">
                <button
                    onClick={lambda e: any -> None {
                        e.stopPropagation();
                        onDelete(store.id);
                    }}
                    className="btn-delete"
                    style={{"marginLeft": "0.5rem"}}
                >
                    ×
                </button>
            </div>
        </div>;
}
