"""Store item component for the price list."""

def:pub StoreItem(
    store: dict,
    onDelete: any,
    isBest: bool
) -> obj {
    return
        <div className={("ingredient-item" + (" best-price-item" if isBest else ""))}>
            <div className="ingredient-info">
                <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem"}}>
                    {(
                        <span style={{"fontSize": "1.2rem"}}>🏆</span>
                    ) if isBest else None}
                    <div>
                        <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem"}}>
                            <span className="ingredient-name">{store.name}</span>
                            {(
                                <span className="carb-badge" style={{
                                    "background": "rgba(74, 222, 128, 0.2)",
                                    "color": "#4ade80"
                                }}>
                                    Best
                                </span>
                            ) if isBest else None}
                        </div>
                        {(
                            <a 
                                href={store.url}
                                target="_blank"
                                rel="noopener noreferrer"
                                className="store-url"
                                onClick={lambda e: any -> None { e.stopPropagation(); }}
                                style={{
                                    "fontSize": "0.75rem",
                                    "color": "rgba(59, 130, 246, 0.8)",
                                    "textDecoration": "none",
                                    "marginTop": "0.25rem",
                                    "display": "block"
                                }}
                            >
                                View product →
                            </a>
                        ) if store.url else None}
                    </div>
                </div>
            </div>
            <div className="ingredient-meta">
                <span className="cost-label" style={{
                    "fontSize": "1.1rem",
                    "fontWeight": "600",
                    "color": (("#4ade80" if isBest else "#2c2010"))
                }}>
                    ${store.price.toFixed(2)}
                </span>
                <button
                    onClick={lambda -> None { onDelete(store.name); }}
                    className="btn-delete"
                    style={{"marginLeft": "0.5rem"}}
                >
                    ×
                </button>
            </div>
        </div>;
}