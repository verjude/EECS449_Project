"""CrossProductResults - Displays price comparison grouped by store with AI insights."""

def:pub CrossProductResults(results: any) -> JsxElement {
    if not results {
        return <div></div>;
    }

    # No-results path: show LLM suggestions instead
    if results.no_store_results {
        suggestions = results.suggestions or [];
        ai_summary = results.ai_summary or "";
        return
            <div style={{"marginTop": "1.5rem"}}>
                <div style={{
                    "padding": "0.75rem 1rem",
                    "marginBottom": "1rem",
                    "borderRadius": "8px",
                    "background": "rgba(251,191,36,0.08)",
                    "borderLeft": "3px solid #fbbf24"
                }}>
                    <div style={{"fontSize": "0.85rem", "fontWeight": "600", "color": "#fbbf24", "marginBottom": "0.25rem"}}>
                        No results found at the selected stores
                    </div>
                    <div style={{"fontSize": "0.85rem", "color": "rgba(44,32,16,0.7)", "lineHeight": "1.5"}}>
                        {"No listings were found for \"" + results.product + "\" at those stores. Here are some AI suggestions:"}
                    </div>
                </div>

                {ai_summary and (
                    <div style={{
                        "padding": "0.75rem 1rem",
                        "marginBottom": "1rem",
                        "borderRadius": "8px",
                        "background": "rgba(74,222,128,0.08)",
                        "borderLeft": "3px solid #4ade80"
                    }}>
                        <div style={{"fontSize": "0.85rem", "fontWeight": "600", "color": "#4ade80", "marginBottom": "0.25rem"}}>
                            AI Overview
                        </div>
                        <div style={{"fontSize": "0.85rem", "color": "rgba(44,32,16,0.8)", "lineHeight": "1.5"}}>
                            {ai_summary}
                        </div>
                    </div>
                )}

                {suggestions.length > 0 and (
                    <div style={{"display": "flex", "flexDirection": "column", "gap": "1rem"}}>
                        <div style={{"fontSize": "0.85rem", "fontWeight": "600", "color": "rgba(44,32,16,0.5)"}}>
                            Similar products found at your stores:
                        </div>
                        {[
                            <div
                                key={alt.name}
                                style={{
                                    "padding": "1rem 1.25rem",
                                    "background": "rgba(255,255,255,0.6)",
                                    "borderRadius": "10px",
                                    "border": "1px solid rgba(0,0,0,0.07)"
                                }}
                            >
                                <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "flex-start", "marginBottom": "0.5rem"}}>
                                    <div style={{"fontSize": "0.9rem", "fontWeight": "700", "color": "#2c2010"}}>
                                        {alt.name}
                                    </div>
                                    {alt.best_price > 0 and (
                                        <div style={{"textAlign": "right", "flexShrink": "0", "marginLeft": "1rem"}}>
                                            <div style={{"fontSize": "1rem", "fontWeight": "700", "color": "#4ade80"}}>
                                                {"$" + str(alt.best_price.toFixed(2))}
                                            </div>
                                            <div style={{"fontSize": "0.75rem", "color": "rgba(44,32,16,0.4)"}}>
                                                {"at " + alt.best_store}
                                            </div>
                                        </div>
                                    )}
                                </div>
                                <div style={{"fontSize": "0.82rem", "color": "rgba(44,32,16,0.55)", "lineHeight": "1.5", "marginBottom": "0.75rem"}}>
                                    {alt.reason}
                                </div>
                                {alt.store_groups and alt.store_groups.length > 0 and (
                                    <div style={{"display": "flex", "flexDirection": "column", "gap": "0.35rem"}}>
                                        {[
                                            <div
                                                key={group.store}
                                                style={{
                                                    "display": "flex",
                                                    "justifyContent": "space-between",
                                                    "alignItems": "center",
                                                    "padding": "0.35rem 0.6rem",
                                                    "borderRadius": "6px",
                                                    "background": "rgba(0,0,0,0.03)"
                                                }}
                                            >
                                                <span style={{"fontSize": "0.82rem", "color": "rgba(44,32,16,0.6)"}}>
                                                    {group.store}
                                                </span>
                                                <div style={{"display": "flex", "alignItems": "center", "gap": "0.6rem"}}>
                                                    <span style={{"fontSize": "0.85rem", "fontWeight": "600", "color": "#4ade80"}}>
                                                        {"$" + str(group.products[0].price.toFixed(2))}
                                                    </span>
                                                    {group.products[0].url and (
                                                        <a
                                                            href={group.products[0].url}
                                                            target="_blank"
                                                            rel="noopener noreferrer"
                                                            style={{"fontSize": "0.75rem", "color": "#3b82f6", "textDecoration": "none"}}
                                                        >
                                                            View
                                                        </a>
                                                    )}
                                                </div>
                                            </div> for group in alt.store_groups
                                        ]}
                                    </div>
                                )}
                                {(not alt.store_groups or alt.store_groups.length == 0) and (
                                    <div style={{"fontSize": "0.78rem", "color": "rgba(255,255,255,0.3)", "fontStyle": "italic"}}>
                                        Not found at selected stores
                                    </div>
                                )}
                            </div> for alt in suggestions
                        ]}
                    </div>
                )}
            </div>;
    }

    source = results.source or "unknown";
    analysis = results.analysis or {};
    store_groups = results.store_groups or [];
    smart_analysis = results.smart_analysis or {};
    store_brand = results.store_brand or {};

    return
        <div style={{"marginTop": "1.5rem"}}>
            <div style={{"display": "flex", "alignItems": "center", "gap": "0.75rem", "marginBottom": "1rem"}}>
                <span style={{
                    "fontSize": "0.85rem",
                    "fontWeight": "600",
                    "color": "#2c2010"
                }}>
                    {results.product}
                </span>
            </div>

            {smart_analysis.recommendation and (
                <div style={{
                    "padding": "0.75rem 1rem",
                    "marginBottom": "1rem",
                    "borderRadius": "8px",
                    "background": "rgba(74,222,128,0.08)",
                    "borderLeft": "3px solid #4ade80"
                }}>
                    <div style={{"fontSize": "0.85rem", "fontWeight": "600", "color": "#4ade80", "marginBottom": "0.25rem"}}>
                        AI Recommendation
                    </div>
                    <div style={{"fontSize": "0.85rem", "color": "rgba(44,32,16,0.8)", "lineHeight": "1.5"}}>
                        {smart_analysis.recommendation}
                    </div>
                    {smart_analysis.unit_price_note and (
                        <div style={{"fontSize": "0.8rem", "color": "rgba(44,32,16,0.6)", "marginTop": "0.4rem"}}>
                            {smart_analysis.unit_price_note}
                        </div>
                    )}
                    {smart_analysis.size_warning and (
                        <div style={{"fontSize": "0.8rem", "color": "#fbbf24", "marginTop": "0.4rem"}}>
                            {"⚠ " + smart_analysis.size_warning}
                        </div>
                    )}
                </div>
            )}

            {store_brand.has_store_brand and store_brand.explanation and (
                <div style={{
                    "padding": "0.75rem 1rem",
                    "marginBottom": "1rem",
                    "borderRadius": "8px",
                    "background": "rgba(59,130,246,0.08)",
                    "borderLeft": "3px solid #3b82f6"
                }}>
                    <div style={{"fontSize": "0.85rem", "fontWeight": "600", "color": "#3b82f6", "marginBottom": "0.25rem"}}>
                        Store Brand Alternative
                    </div>
                    <div style={{"fontSize": "0.85rem", "color": "rgba(44,32,16,0.8)", "lineHeight": "1.5"}}>
                        {store_brand.explanation}
                    </div>
                    {store_brand.estimated_savings_pct > 0 and (
                        <span style={{
                            "display": "inline-block",
                            "marginTop": "0.4rem",
                            "fontSize": "0.75rem",
                            "padding": "0.15rem 0.5rem",
                            "borderRadius": "999px",
                            "background": "rgba(74,222,128,0.15)",
                            "color": "#4ade80",
                            "fontWeight": "600"
                        }}>
                            {"Save ~" + str(store_brand.estimated_savings_pct.toFixed(0)) + "%"}
                        </span>
                    )}
                </div>
            )}

            {store_brand.has_store_brand == False and store_brand.explanation and (
                <div style={{
                    "padding": "0.75rem 1rem",
                    "marginBottom": "1rem",
                    "borderRadius": "8px",
                    "background": "rgba(59,130,246,0.05)",
                    "borderLeft": "3px solid rgba(59,130,246,0.3)"
                }}>
                    <div style={{"fontSize": "0.8rem", "color": "rgba(44,32,16,0.6)", "lineHeight": "1.4"}}>
                        {"💡 " + store_brand.explanation}
                    </div>
                </div>
            )}

            {store_groups.length > 0 and (
                <div style={{"display": "flex", "flexDirection": "column", "gap": "1rem"}}>
                    {[
                        <div
                            key={group.store}
                            style={{
                                "padding": "1rem 1.25rem",
                                "background": "rgba(255,255,255,0.6)",
                                "borderRadius": "10px",
                                "border": "1px solid rgba(0,0,0,0.07)"
                            }}
                        >
                            <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem", "marginBottom": "0.75rem", "borderBottom": "1px solid rgba(0,0,0,0.08)", "paddingBottom": "0.5rem"}}>
                                <span style={{"fontSize": "1rem", "fontWeight": "700", "color": "#2c2010"}}>
                                    {group.store}
                                </span>
                                <span style={{"fontSize": "0.75rem", "color": "rgba(44,32,16,0.4)"}}>
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
                                            "background": "rgba(0,0,0,0.02)"
                                        }}
                                    >
                                        <div style={{"flex": "1", "minWidth": "0"}}>
                                            <span style={{"fontSize": "0.85rem", "color": "rgba(44,32,16,0.8)"}}>
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
        </div>;
}
