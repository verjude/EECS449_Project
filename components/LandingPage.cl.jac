"""LandingPage - Public landing page shown before login."""

def:pub LandingPage(onSignIn: any, isSignup: bool, username: str, password: str, error: str, loading: bool, onUsernameChange: any, onPasswordChange: any, onSubmit: any, onToggleMode: any, showAuthModal: bool, onOpenAuth: any, onCloseAuth: any) -> obj {

    features = [
        {
            "icon": "🔍",
            "title": "Live Price Search",
            "desc": "Search any product and instantly compare prices across all your stores in real time."
        },
        {
            "icon": "🧠",
            "title": "AI Value Analysis",
            "desc": "Our AI accounts for pack sizes and unit pricing so you always know the true best deal."
        },
        {
            "icon": "🏷️",
            "title": "Store-Brand Finder",
            "desc": "Automatically surfaces generic alternatives that match quality at a fraction of the cost."
        },
        {
            "icon": "📍",
            "title": "Nearby Store Locator",
            "desc": "Find stores around you by GPS or address and add them to your tracked list instantly."
        }
    ];

    steps = [
        {"n": "1", "text": "Add stores you shop at — or use GPS to find nearby ones."},
        {"n": "2", "text": "Search any product. We pull live prices from Google Shopping."},
        {"n": "3", "text": "Let AI highlight the best deal, unit pricing, and store-brand alternatives."}
    ];

    return
        <div style={{
            "minHeight": "100vh",
            "background": "linear-gradient(160deg, #fdf6ec 0%, #fef3e2 40%, #fdf0d5 100%)",
            "fontFamily": "system-ui, sans-serif",
            "overflowX": "hidden"
        }}>

            {(
                <div
                    onClick={lambda -> None { onCloseAuth(); }}
                    style={{
                        "position": "fixed",
                        "inset": "0",
                        "background": "rgba(0,0,0,0.4)",
                        "backdropFilter": "blur(4px)",
                        "zIndex": "200",
                        "display": "flex",
                        "alignItems": "center",
                        "justifyContent": "center",
                        "padding": "1rem"
                    }}
                >
                    <div
                        onClick={lambda e: any -> None { e.stopPropagation(); }}
                        style={{
                            "background": "#fdf6ec",
                            "borderRadius": "16px",
                            "padding": "2.5rem",
                            "width": "100%",
                            "maxWidth": "400px",
                            "boxShadow": "0 20px 60px rgba(0,0,0,0.2)",
                            "border": "1px solid rgba(44,32,16,0.1)"
                        }}
                    >
                        <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "1.75rem"}}>
                            <h2 style={{
                                "margin": "0",
                                "fontSize": "1.4rem",
                                "fontWeight": "700",
                                "color": "#1a1008",
                                "fontFamily": "Georgia, serif"
                            }}>
                                {("Create account" if isSignup else "Welcome back")}
                            </h2>
                            <button
                                onClick={lambda -> None { onCloseAuth(); }}
                                style={{
                                    "background": "none",
                                    "border": "none",
                                    "fontSize": "1.25rem",
                                    "cursor": "pointer",
                                    "color": "rgba(44,32,16,0.4)",
                                    "padding": "0.25rem",
                                    "lineHeight": "1"
                                }}
                            >
                                ✕
                            </button>
                        </div>

                        {(
                            <div style={{
                                "marginBottom": "1rem",
                                "padding": "0.75rem 1rem",
                                "background": "rgba(248,113,113,0.1)",
                                "border": "1px solid rgba(248,113,113,0.3)",
                                "borderRadius": "8px",
                                "color": "#ef4444",
                                "fontSize": "0.875rem"
                            }}>
                                {error}
                            </div>
                        ) if error else None}

                        <div style={{"display": "flex", "flexDirection": "column", "gap": "0.75rem"}}>
                            <input
                                type="text"
                                value={username}
                                onChange={onUsernameChange}
                                placeholder="Username"
                                style={{
                                    "padding": "0.75rem 1rem",
                                    "borderRadius": "8px",
                                    "border": "1.5px solid rgba(44,32,16,0.15)",
                                    "background": "rgba(255,255,255,0.8)",
                                    "fontSize": "0.95rem",
                                    "color": "#1a1008",
                                    "outline": "none",
                                    "fontFamily": "system-ui, sans-serif"
                                }}
                            />
                            <input
                                type="password"
                                value={password}
                                onChange={onPasswordChange}
                                placeholder="Password"
                                style={{
                                    "padding": "0.75rem 1rem",
                                    "borderRadius": "8px",
                                    "border": "1.5px solid rgba(44,32,16,0.15)",
                                    "background": "rgba(255,255,255,0.8)",
                                    "fontSize": "0.95rem",
                                    "color": "#1a1008",
                                    "outline": "none",
                                    "fontFamily": "system-ui, sans-serif"
                                }}
                            />
                            <button
                                onClick={onSubmit}
                                disabled={loading}
                                style={{
                                    "background": "linear-gradient(135deg, #2c2010 0%, #4a3820 100%)",
                                    "color": "#fdf6ec",
                                    "border": "none",
                                    "borderRadius": "8px",
                                    "padding": "0.8rem",
                                    "fontSize": "0.95rem",
                                    "fontWeight": "600",
                                    "cursor": "pointer",
                                    "marginTop": "0.25rem",
                                    "opacity": ("0.7" if loading else "1")
                                }}
                            >
                                {("Loading..." if loading else ("Create Account" if isSignup else "Sign In"))}
                            </button>
                        </div>

                        <p style={{
                            "textAlign": "center",
                            "marginTop": "1.25rem",
                            "marginBottom": "0",
                            "fontSize": "0.875rem",
                            "color": "rgba(44,32,16,0.5)"
                        }}>
                            {("Already have an account? " if isSignup else "Don't have an account? ")}
                            <button
                                onClick={lambda -> None { onToggleMode(); }}
                                style={{
                                    "background": "none",
                                    "border": "none",
                                    "color": "#3b82f6",
                                    "fontWeight": "600",
                                    "cursor": "pointer",
                                    "fontSize": "0.875rem",
                                    "padding": "0",
                                    "fontFamily": "system-ui, sans-serif"
                                }}
                            >
                                {("Sign in" if isSignup else "Sign up")}
                            </button>
                        </p>
                    </div>
                </div>
            ) if showAuthModal else None}

            <div style={{
                "position": "sticky",
                "top": "0",
                "zIndex": "100",
                "background": "rgba(253,246,236,0.88)",
                "backdropFilter": "blur(12px)",
                "borderBottom": "1px solid rgba(44,32,16,0.1)",
                "padding": "0 1.5rem"
            }}>
                <div style={{
                    "maxWidth": "1100px",
                    "margin": "0 auto",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "space-between",
                    "height": "56px"
                }}>
                    <div style={{"display": "flex", "alignItems": "center", "gap": "0.45rem"}}>
                        <span style={{"fontSize": "1.2rem"}}>🛒</span>
                        <span style={{
                            "fontFamily": "Georgia, serif",
                            "fontWeight": "700",
                            "fontSize": "1rem",
                            "color": "#1a1008"
                        }}>
                            PriceComparator
                        </span>
                    </div>
                    <button
                        onClick={lambda -> None { onOpenAuth(); }}
                        style={{
                            "background": "linear-gradient(135deg, #2c2010 0%, #4a3820 100%)",
                            "color": "#fdf6ec",
                            "border": "none",
                            "borderRadius": "8px",
                            "padding": "0.45rem 1.1rem",
                            "fontSize": "0.88rem",
                            "fontWeight": "600",
                            "cursor": "pointer",
                            "boxShadow": "0 2px 8px rgba(44,32,16,0.2)"
                        }}
                    >
                        Sign In
                    </button>
                </div>
            </div>

            <div style={{
                "maxWidth": "860px",
                "margin": "0 auto",
                "padding": "5rem 2rem 3rem",
                "textAlign": "center"
            }}>
                <div style={{
                    "display": "inline-flex",
                    "alignItems": "center",
                    "gap": "0.4rem",
                    "background": "rgba(59,130,246,0.1)",
                    "border": "1px solid rgba(59,130,246,0.25)",
                    "borderRadius": "999px",
                    "padding": "0.3rem 0.9rem",
                    "fontSize": "0.78rem",
                    "fontWeight": "600",
                    "letterSpacing": "0.08em",
                    "textTransform": "uppercase",
                    "color": "#3b82f6",
                    "marginBottom": "1.75rem"
                }}>
                    ✦ AI-Powered Price Comparison
                </div>

                <h1 style={{
                    "fontSize": "clamp(2.4rem, 6vw, 4rem)",
                    "fontWeight": "700",
                    "color": "#1a1008",
                    "lineHeight": "1.15",
                    "margin": "0 0 1.25rem",
                    "letterSpacing": "-0.02em",
                    "fontFamily": "Georgia, serif"
                }}>
                    Stop overpaying.<br />
                    <span style={{
                        "background": "linear-gradient(135deg, #f59e0b 0%, #ef4444 100%)",
                        "WebkitBackgroundClip": "text",
                        "WebkitTextFillColor": "transparent",
                        "backgroundClip": "text"
                    }}>
                        Shop smarter.
                    </span>
                </h1>

                <p style={{
                    "fontSize": "1.15rem",
                    "color": "rgba(44,32,16,0.6)",
                    "lineHeight": "1.7",
                    "maxWidth": "560px",
                    "margin": "0 auto 2.5rem"
                }}>
                    Compare prices across your favorite stores, get size-aware AI recommendations,
                    and discover store-brand savings — all in one place.
                </p>

                <button
                    onClick={lambda -> None { onOpenAuth(); }}
                    style={{
                        "background": "linear-gradient(135deg, #2c2010 0%, #4a3820 100%)",
                        "color": "#fdf6ec",
                        "border": "none",
                        "borderRadius": "10px",
                        "padding": "0.875rem 2rem",
                        "fontSize": "1rem",
                        "fontWeight": "600",
                        "cursor": "pointer",
                        "boxShadow": "0 4px 20px rgba(44,32,16,0.25)",
                        "letterSpacing": "0.01em"
                    }}
                >
                    Get Started — It's Free →
                </button>
            </div>

            <div style={{"maxWidth": "860px", "margin": "0 auto", "padding": "0 2rem"}}>
                <div style={{
                    "height": "1px",
                    "background": "linear-gradient(90deg, transparent, rgba(44,32,16,0.12), transparent)"
                }} />
            </div>

            <div style={{"maxWidth": "860px", "margin": "0 auto", "padding": "3rem 2rem"}}>
                <p style={{
                    "textAlign": "center",
                    "fontSize": "0.78rem",
                    "fontWeight": "600",
                    "letterSpacing": "0.1em",
                    "textTransform": "uppercase",
                    "color": "rgba(44,32,16,0.35)",
                    "marginBottom": "2rem"
                }}>
                    Everything you need
                </p>
                <div style={{
                    "display": "grid",
                    "gridTemplateColumns": "repeat(auto-fit, minmax(180px, 1fr))",
                    "gap": "1rem"
                }}>
                    {[
                        <div
                            key={feat["title"]}
                            style={{
                                "background": "rgba(255,255,255,0.72)",
                                "border": "1px solid rgba(44,32,16,0.09)",
                                "borderRadius": "14px",
                                "padding": "1.5rem 1.25rem",
                                "backdropFilter": "blur(8px)"
                            }}
                        >
                            <div style={{"fontSize": "1.75rem", "marginBottom": "0.75rem"}}>
                                {feat["icon"]}
                            </div>
                            <h3 style={{
                                "fontSize": "0.95rem",
                                "fontWeight": "700",
                                "color": "#1a1008",
                                "margin": "0 0 0.4rem"
                            }}>
                                {feat["title"]}
                            </h3>
                            <p style={{
                                "fontSize": "0.83rem",
                                "color": "rgba(44,32,16,0.55)",
                                "lineHeight": "1.55",
                                "margin": "0"
                            }}>
                                {feat["desc"]}
                            </p>
                        </div>
                        for feat in features
                    ]}
                </div>
            </div>

            <div style={{"maxWidth": "620px", "margin": "0 auto", "padding": "0 2rem 5rem"}}>
                <div style={{
                    "background": "rgba(255,255,255,0.6)",
                    "border": "1px solid rgba(44,32,16,0.1)",
                    "borderRadius": "16px",
                    "padding": "2rem 2.25rem"
                }}>
                    <p style={{
                        "fontSize": "0.78rem",
                        "fontWeight": "600",
                        "letterSpacing": "0.1em",
                        "textTransform": "uppercase",
                        "color": "rgba(44,32,16,0.35)",
                        "marginBottom": "1.25rem",
                        "marginTop": "0"
                    }}>
                        Get started in 3 steps
                    </p>
                    <div style={{"display": "flex", "flexDirection": "column", "gap": "1rem"}}>
                        {[
                            <div
                                key={step["n"]}
                                style={{"display": "flex", "gap": "1rem", "alignItems": "flex-start"}}
                            >
                                <div style={{
                                    "width": "28px",
                                    "height": "28px",
                                    "borderRadius": "50%",
                                    "background": "linear-gradient(135deg, #f59e0b, #ef4444)",
                                    "display": "flex",
                                    "alignItems": "center",
                                    "justifyContent": "center",
                                    "fontSize": "0.78rem",
                                    "fontWeight": "700",
                                    "color": "white",
                                    "flexShrink": "0",
                                    "marginTop": "1px"
                                }}>
                                    {step["n"]}
                                </div>
                                <p style={{
                                    "margin": "0",
                                    "fontSize": "0.9rem",
                                    "color": "rgba(44,32,16,0.7)",
                                    "lineHeight": "1.6",
                                    "paddingTop": "3px"
                                }}>
                                    {step["text"]}
                                </p>
                            </div>
                            for step in steps
                        ]}
                    </div>
                    <div style={{"marginTop": "1.75rem", "textAlign": "center"}}>
                        <button
                            onClick={lambda -> None { onOpenAuth(); }}
                            style={{
                                "background": "transparent",
                                "border": "1.5px solid rgba(44,32,16,0.25)",
                                "borderRadius": "8px",
                                "padding": "0.65rem 1.5rem",
                                "fontSize": "0.9rem",
                                "fontWeight": "600",
                                "color": "#2c2010",
                                "cursor": "pointer"
                            }}
                        >
                            Sign In to Get Started →
                        </button>
                    </div>
                </div>
            </div>

        </div>;
}