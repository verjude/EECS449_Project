"""StoreEntryItem — a single row in the global store list."""

def:pub StoreEntryItem(
    store: dict,
    onDelete: any,
    onSelect: any   # NEW: called when the store name is clicked
) -> obj {
    return
        <div className="ingredient-item">
            <div
                className="ingredient-info"
                onClick={lambda -> None { onSelect(store); }}
                style={{"cursor": "pointer", "flex": "1"}}
                title="Click to manage products for this store"
            >
                <span
                    className="ingredient-name"
                    style={{"textDecoration": "underline dotted", "color": "#2c2010"}}
                >
                    {store.name}
                </span>
                <span style={{"fontSize": "0.75rem", "color": "rgba(255,255,255,0.4)", "marginLeft": "0.5rem"}}>
                    → view products
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
