"""CrossProductResults - Displays AI cross-product comparison results."""

def:pub CrossProductResults(results: any) -> obj {
    if not results {
        return <div></div>;
    }

    original = results.original;
    alternatives = results.alternatives or [];
    ai_summary = results.ai_summary or "";
    source = results.source or "unknown";

    return
        <div style={{"marginTop": "1.5rem"}}>
            <div style={{"display": "flex", "alignItems": "center", "gap": "0.75rem", "marginBottom": "1rem"}}>
                <span style={{
                    "fontSize": "0.75rem",
                    "padding": "0.25rem 0.6rem",
                    "borderRadius": "999px",
                    "background": ("rgba(74,222,128,0.15)" if source == "google_shopping" else "rgba(251,191,36,0.15)"),
                    "color": ("#4ade80" if source == "google_shopping" else "#fbbf24"),
                    "border": ("1px solid rgba(74,222,128,0.3)" if source == "google_shopping" else "1px solid rgba(251,191,36,0.3)")
                }}>
                    {("✓ Google Shopping" if source == "google_shopping" else "⚠ Estimated prices")}
                </span>
            </div>

            {(
                <div style={{
                    "padding": "1.25rem",
                    "background": "rgba(255,255,255,0.03)",
                    "borderRadius": "10px",
                    "border": "1px solid rgba(255,255,255,0.08)",
                    "marginBottom": "1rem"
                }}>
                    <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "1rem"}}>
                        <h3 style={{"margin": "0", "fontSize": "1.05rem", "color": "rgba(255,255,255,0.9)"}}>
                            {original.name}
                        </h3>
                        {(
                            <span style={{"fontSize": "1.25rem", "fontWeight": "700", "color": "#4ade80"}}>
                                {"$" + str(original.best_price.toFixed(2))}
                            </span>
                        ) if original.best_price > 0 else None}
                    </div>

                    {(
                        <div style={{
                            "padding": "0.75rem 1rem",
                            "marginBottom": "1rem",
                            "borderRadius": "8px",
                            "background": ("rgba(74,222,128,0.08)" if original.deal_evaluation.is_good_deal else "rgba(251,191,36,0.08)"),
                            "borderLeft": ("3px solid #4ade80" if original.deal_evaluation.is_good_deal else "3px solid #fbbf24")
                        }}>
                            <div style={{"fontSize": "0.9rem", "fontWeight": "600", "color": "rgba(255,255,255,0.9)", "marginBottom": "0.25rem"}}>
                                {original.deal_evaluation.verdict}
                            </div>
                            {(
                                <div style={{"fontSize": "0.8rem", "color": "rgba(255,255,255,0.6)"}}>
                                    {"💡 " + original.deal_evaluation.savings_tip}
                                </div>
                            ) if original.deal_evaluation.savings_tip else None}
                        </div>
                    ) if original.deal_evaluation and original.deal_evaluation.verdict else None}

                    {(
                        <div style={{"display": "flex", "flexDirection": "column", "gap": "0.4rem"}}>
                            {[
                                <div
                                    key={p.store}
                                    style={{
                                        "display": "flex",
                                        "justifyContent": "space-between",
                                        "alignItems": "center",
                                        "padding": "0.5rem 0.75rem",
                                        "borderRadius": "6px"
                                    }}
                                >
                                    <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem"}}>
                                        <span style={{"fontSize": "0.9rem", "color": "rgba(255,255,255,0.8)"}}>
                                            {p.store}
                                        </span>
                                        {(
                                            <span style={{"fontSize": "0.75rem", "color": "rgba(255,255,255,0.3)"}}>
                                                {"★ " + str(p.rating)}
                                            </span>
                                        ) if p.rating else None}
                                    </div>
                                    <div style={{"display": "flex", "alignItems": "center", "gap": "0.75rem"}}>
                                        <span style={{"fontWeight": "600", "fontSize": "0.95rem", "color": "rgba(255,255,255,0.7)"}}>
                                            {"$" + str(p.price.toFixed(2))}
                                        </span>
                                        {(
                                            <a
                                                href={p.url}
                                                target="_blank"
                                                rel="noopener noreferrer"
                                                style={{"fontSize": "0.75rem", "color": "#3b82f6", "textDecoration": "none"}}
                                            >
                                                View →
                                            </a>
                                        ) if p.url else None}
                                    </div>
                                </div> for p in original.prices
                            ]}
                        </div>
                    ) if original.prices and original.prices.length > 0 else (
                        <div style={{"color": "rgba(255,255,255,0.4)", "fontSize": "0.85rem"}}>
                            No prices found for this product.
                        </div>
                    )}
                </div>
            ) if original else None}

            {(
                <div>
                    <h3 style={{
                        "fontSize": "1rem",
                        "color": "rgba(255,255,255,0.9)",
                        "margin": "1.25rem 0 0.5rem 0",
                        "display": "flex",
                        "alignItems": "center",
                        "gap": "0.5rem"
                    }}>
                        <span>🤖</span>
                        <span>AI-Recommended Alternatives</span>
                    </h3>

                    {(
                        <div style={{
                            "padding": "0.75rem 1rem",
                            "marginBottom": "1rem",
                            "background": "rgba(59,130,246,0.08)",
                            "borderRadius": "8px",
                            "borderLeft": "3px solid #3b82f6",
                            "fontSize": "0.85rem",
                            "color": "rgba(255,255,255,0.7)",
                            "lineHeight": "1.5"
                        }}>
                            {ai_summary}
                        </div>
                    ) if ai_summary else None}

                    <div style={{"display": "flex", "flexDirection": "column", "gap": "0.75rem"}}>
                        {[
                            <div
                                key={alt.name}
                                style={{
                                    "padding": "1rem 1.25rem",
                                    "background": "rgba(255,255,255,0.03)",
                                    "borderRadius": "10px",
                                    "border": "1px solid rgba(255,255,255,0.08)"
                                }}
                            >
                                <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "flex-start", "marginBottom": "0.5rem"}}>
                                    <div style={{"flex": "1"}}>
                                        <div style={{"fontWeight": "600", "fontSize": "0.95rem", "color": "rgba(255,255,255,0.9)"}}>
                                            {alt.name}
                                        </div>
                                        <div style={{"fontSize": "0.8rem", "color": "rgba(255,255,255,0.5)", "marginTop": "0.25rem", "lineHeight": "1.4"}}>
                                            {alt.reason}
                                        </div>
                                    </div>
                                    <div style={{"textAlign": "right", "marginLeft": "1rem", "flexShrink": "0"}}>
                                        {(
                                            <div>
                                                <div style={{"fontWeight": "700", "fontSize": "1.1rem", "color": "#4ade80"}}>
                                                    {"$" + str(alt.best_price.toFixed(2))}
                                                </div>
                                                <div style={{"fontSize": "0.75rem", "color": "rgba(255,255,255,0.4)"}}>
                                                    {alt.best_store}
                                                </div>
                                            </div>
                                        ) if alt.best_price > 0 else (
                                            <div style={{"fontSize": "0.8rem", "color": "rgba(255,255,255,0.4)"}}>
                                                Price unavailable
                                            </div>
                                        )}
                                    </div>
                                </div>

                                {(
                                    <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem", "marginTop": "0.5rem"}}>
                                        <span style={{
                                            "fontSize": "0.75rem",
                                            "padding": "0.2rem 0.5rem",
                                            "borderRadius": "999px",
                                            "background": ("rgba(74,222,128,0.15)" if alt.price_diff < 0 else "rgba(248,113,113,0.15)"),
                                            "color": ("#4ade80" if alt.price_diff < 0 else "#f87171"),
                                            "fontWeight": "600"
                                        }}>
                                            {("Save $" + str(abs(alt.price_diff).toFixed(2))) if alt.price_diff < 0 else ("$" + str(alt.price_diff.toFixed(2)) + " more")}
                                        </span>
                                        {(
                                            <span style={{"fontSize": "0.75rem", "color": "rgba(255,255,255,0.3)"}}>
                                                {"★ " + str(alt.rating)}
                                            </span>
                                        ) if alt.rating else None}
                                    </div>
                                ) if alt.best_price > 0 and alt.price_diff != 0 else None}

                                {(
                                    <div style={{"marginTop": "0.5rem"}}>
                                        <a
                                            href={alt.best_url}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            style={{"fontSize": "0.8rem", "color": "#3b82f6", "textDecoration": "none"}}
                                        >
                                            View best deal →
                                        </a>
                                    </div>
                                ) if alt.best_url else None}
                            </div> for alt in alternatives
                        ]}
                    </div>
                </div>
            ) if alternatives.length > 0 else None}
        </div>;
}
