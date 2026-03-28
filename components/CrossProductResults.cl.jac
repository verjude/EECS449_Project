"""CrossProductResults - Displays price comparison results grouped by store."""

def:pub CrossProductResults(results: any) -> JsxElement {
    if not results {
        return <div></div>;
    }

    source = results.source or "unknown";
    analysis = results.analysis or {};
    store_groups = results.store_groups or [];
    prices = results.prices or [];

    return
        <div style={{"marginTop": "1.5rem"}}>
            <div style={{"display": "flex", "alignItems": "center", "gap": "0.75rem", "marginBottom": "1rem"}}>
                <span style={{
                    "fontSize": "0.75rem",
                    "padding": "0.25rem 0.6rem",
                    "borderRadius": "999px",
                    "background": "rgba(74,222,128,0.15)",
                    "color": "#4ade80",
                    "border": "1px solid rgba(74,222,128,0.3)"
                }}>
                    {results.product}
                </span>
                {analysis.recommendation and (
                    <span style={{"fontSize": "0.8rem", "color": "rgba(255,255,255,0.5)"}}>
                        {analysis.recommendation}
                    </span>
                )}
            </div>

            {store_groups.length > 0 and (
                <div style={{"display": "flex", "flexDirection": "column", "gap": "1rem"}}>
                    {[
                        <div
                            key={group.store}
                            style={{
                                "padding": "1rem 1.25rem",
                                "background": "rgba(255,255,255,0.03)",
                                "borderRadius": "10px",
                                "border": "1px solid rgba(255,255,255,0.08)"
                            }}
                        >
                            <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem", "marginBottom": "0.75rem", "borderBottom": "1px solid rgba(255,255,255,0.08)", "paddingBottom": "0.5rem"}}>
                                <span style={{"fontSize": "1rem", "fontWeight": "700", "color": "rgba(255,255,255,0.95)"}}>
                                    {group.store}
                                </span>
                                <span style={{"fontSize": "0.75rem", "color": "rgba(255,255,255,0.4)"}}>
                                    {str(group.products.length) + " items"}
                                </span>
                            </div>
                            <div style={{"display": "flex", "flexDirection": "column", "gap": "0.35rem"}}>
                                {[
                                    <div
                                        key={product.title + str(product.price)}
                                        style={{
                                            "display": "flex",
                                            "justifyContent": "space-between",
                                            "alignItems": "center",
                                            "padding": "0.4rem 0.5rem",
                                            "borderRadius": "6px",
                                            "background": "rgba(255,255,255,0.02)"
                                        }}
                                    >
                                        <div style={{"flex": "1", "minWidth": "0"}}>
                                            <span style={{"fontSize": "0.85rem", "color": "rgba(255,255,255,0.8)"}}>
                                                {product.title}
                                            </span>
                                            {product.rating and (
                                                <span style={{"fontSize": "0.7rem", "color": "rgba(255,255,255,0.3)", "marginLeft": "0.5rem"}}>
                                                    {"★ " + str(product.rating)}
                                                </span>
                                            )}
                                        </div>
                                        <div style={{"display": "flex", "alignItems": "center", "gap": "0.75rem", "flexShrink": "0", "marginLeft": "1rem"}}>
                                            <span style={{"fontWeight": "600", "fontSize": "0.95rem", "color": "#4ade80"}}>
                                                {"$" + str(product.price.toFixed(2))}
                                            </span>
                                            {product.url and (
                                                <a
                                                    href={product.url}
                                                    target="_blank"
                                                    rel="noopener noreferrer"
                                                    style={{"fontSize": "0.75rem", "color": "#3b82f6", "textDecoration": "none", "whiteSpace": "nowrap"}}
                                                >
                                                    View
                                                </a>
                                            )}
                                        </div>
                                    </div> for product in group.products
                                ]}
                            </div>
                        </div> for group in store_groups
                    ]}
                </div>
            )}

            {store_groups.length == 0 and prices.length > 0 and (
                <div style={{"display": "flex", "flexDirection": "column", "gap": "0.4rem"}}>
                    {[
                        <div
                            key={p.store + str(p.price)}
                            style={{
                                "display": "flex",
                                "justifyContent": "space-between",
                                "alignItems": "center",
                                "padding": "0.5rem 0.75rem",
                                "borderRadius": "6px"
                            }}
                        >
                            <span style={{"fontSize": "0.9rem", "color": "rgba(255,255,255,0.8)"}}>
                                {p.store + " - " + p.title}
                            </span>
                            <span style={{"fontWeight": "600", "fontSize": "0.95rem", "color": "#4ade80"}}>
                                {"$" + str(p.price.toFixed(2))}
                            </span>
                        </div> for p in prices
                    ]}
                </div>
            )}
        </div>;
}
