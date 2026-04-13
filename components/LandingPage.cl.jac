"""LandingPage - Public landing page shown before login."""

def:pub LandingPage(onSignIn: any, isSignup: bool, username: str, password: str, error: str, loading: bool, onUsernameChange: any, onPasswordChange: any, onSubmit: any, onToggleMode: any, showAuthModal: bool, onOpenAuth: any, onOpenAuthSignup: any, onCloseAuth: any, eulaAccepted: bool, eulaSignupOpen: bool, onEulaAcceptedChange: any, onEulaSignupOpen: any) -> obj {

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
                            {(
                                <label style={{
                                    "display": "flex",
                                    "alignItems": "flex-start",
                                    "gap": "0.5rem",
                                    "fontSize": "0.83rem",
                                    "color": "rgba(44,32,16,0.7)",
                                    "lineHeight": "1.5",
                                    "cursor": "pointer",
                                    "marginTop": "0.25rem"
                                }}>
                                    <input
                                        type="checkbox"
                                        checked={eulaAccepted}
                                        onChange={onEulaAcceptedChange}
                                        style={{"accentColor": "#3b82f6", "marginTop": "0.2rem", "flexShrink": "0"}}
                                        disabled={loading}
                                    />
                                    <span>
                                        I have read and agree to the{" "}
                                        <button
                                            type="button"
                                            onClick={lambda -> None { onEulaSignupOpen(True); }}
                                            style={{"background": "none", "border": "none", "color": "#3b82f6", "cursor": "pointer", "textDecoration": "underline", "fontSize": "0.83rem", "padding": "0", "fontFamily": "system-ui, sans-serif"}}
                                        >End User License Agreement</button>
                                    </span>
                                </label>
                            ) if isSignup else None}
                            <button
                                onClick={onSubmit}
                                disabled={loading or (isSignup and not eulaAccepted)}
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
                                    "opacity": ("0.7" if (loading or (isSignup and not eulaAccepted)) else "1")
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

            {(
                <div style={{"position": "fixed", "inset": "0", "background": "rgba(0,0,0,0.45)", "zIndex": "300", "display": "flex", "alignItems": "center", "justifyContent": "center", "padding": "1.5rem"}}>
                    <div style={{"background": "#fdf6ec", "borderRadius": "16px", "padding": "2rem 2.5rem", "maxWidth": "680px", "width": "100%", "maxHeight": "82vh", "overflowY": "auto", "boxShadow": "0 20px 60px rgba(0,0,0,0.25)", "border": "1px solid rgba(44,32,16,0.1)"}}>
                        <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "flex-start", "marginBottom": "1.5rem"}}>
                            <div>
                                <h2 style={{"fontSize": "1.4rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.25rem", "fontFamily": "Georgia, serif"}}>End User License Agreement</h2>
                                <p style={{"fontSize": "0.8rem", "color": "rgba(44,32,16,0.5)", "margin": "0"}}>Last Updated: April 13, 2026</p>
                            </div>
                            <button onClick={lambda -> None { onEulaSignupOpen(False); }} style={{"background": "transparent", "border": "none", "fontSize": "1.5rem", "cursor": "pointer", "color": "rgba(44,32,16,0.4)", "lineHeight": "1", "padding": "0.25rem"}}>×</button>
                        </div>
                        <p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.7)", "marginBottom": "1.25rem", "lineHeight": "1.6"}}>PLEASE READ THIS AGREEMENT CAREFULLY BEFORE USING THIS SOFTWARE. By accessing or using this software ("the Service"), you agree to be bound by the terms of this End User License Agreement. If you do not agree, do not use the Service.</p>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>Educational Context</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>This software was developed by students as part of an academic course at the University of Michigan. It is provided for demonstration and educational purposes only and may not meet the standards of commercially released software.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>Use at Your Own Risk</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, RELIABILITY, OR NON-INFRINGEMENT. YOUR USE OF THE SERVICE IS SOLELY AT YOUR OWN RISK.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>Limitation of Liability</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, NEITHER THE STUDENT DEVELOPERS, THE UNIVERSITY OF MICHIGAN, ITS FACULTY, INSTRUCTORS, REGENTS, EMPLOYEES, NOR ANY AFFILIATED PARTIES SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF — OR INABILITY TO USE — THE SERVICE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>No Guarantees of Availability</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>The Service may be discontinued, modified, or taken offline at any time without notice. No guarantee of uptime, continued access, or future development is made.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>Data</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>Do not submit sensitive, confidential, or personal data to this Service. The student developers make no guarantees regarding data security, storage, or privacy.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>Indemnification</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>You agree to indemnify and hold harmless the student developers, the University of Michigan, its faculty, instructors, and Regents from any claims, damages, or expenses arising from your use of the Service or your violation of this Agreement.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>Governing Law</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>This Agreement shall be governed by the laws of the State of Michigan, without regard to conflict of law principles. Any disputes shall be subject to the exclusive jurisdiction of the courts located in Washtenaw County, Michigan.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#1a1008", "marginBottom": "0.4rem"}}>Acceptance</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>By using the Service, you acknowledge that you have read, understood, and agree to be bound by this Agreement.</p></div>
                        <div style={{"marginTop": "1.5rem", "textAlign": "right"}}>
                            <button onClick={lambda -> None { onEulaSignupOpen(False); }} style={{"background": "linear-gradient(135deg, #2c2010 0%, #4a3820 100%)", "color": "#fdf6ec", "border": "none", "borderRadius": "8px", "padding": "0.6rem 1.5rem", "fontSize": "0.9rem", "fontWeight": "600", "cursor": "pointer"}}>Close</button>
                        </div>
                    </div>
                </div>
            ) if eulaSignupOpen else None}

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
                    onClick={lambda -> None { onOpenAuthSignup(); }}
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
            
            <div style={{"maxWidth": "760px", "margin": "0 auto", "padding": "3rem 2rem"}}>
                <p style={{
                    "textAlign": "center",
                    "fontSize": "0.78rem",
                    "fontWeight": "600",
                    "letterSpacing": "0.1em",
                    "textTransform": "uppercase",
                    "color": "rgba(44,32,16,0.35)",
                    "marginBottom": "1.5rem"
                }}>
                    See it in action
                </p>
                <div style={{
                    "position": "relative",
                    "width": "100%",
                    "paddingBottom": "56.25%",
                    "borderRadius": "16px",
                    "overflow": "hidden",
                    "boxShadow": "0 12px 40px rgba(44,32,16,0.15)",
                    "border": "1px solid rgba(44,32,16,0.08)"
                }}>
                    <iframe 
                        src="https://www.youtube.com/embed/yhjGy6c957I?si=Yh1B1WRVwAUiIxKH" 
                        title="PriceComparator Demo"
                        frameborder="0" 
                        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" 
                        allowFullScreen={True}
                        referrerpolicy="strict-origin-when-cross-origin"
                        style={{
                            "position": "absolute",
                            "top": "0",
                            "left": "0",
                            "width": "100%",
                            "height": "100%",
                            "border": "none"
                        }}
                    >
                    </iframe>
                </div>
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
                            onClick={lambda -> None { onOpenAuthSignup(); }}
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
                            Sign Up to Get Started →
                        </button>
                    </div>
                </div>
            </div>
            
            <div style={{
                "borderTop": "1px solid rgba(44,32,16,0.08)",
                "padding": "1.75rem 2rem",
                "textAlign": "center"
            }}>
                <p style={{
                    "margin": "0",
                    "fontSize": "0.82rem",
                    "color": "rgba(44,32,16,0.4)",
                    "fontFamily": "system-ui, sans-serif"
                }}>
                    <a
                        href="https://www.jac-lang.org"
                        target="_blank"
                        style={{
                            "color": "#3b82f6",
                            "fontWeight": "600",
                            "textDecoration": "none",
                            "marginLeft": "0.3rem"
                        }}
                    >
                        Built with Jaseci
                    </a>
                    {" · "}
                    <button
                        onClick={lambda -> None { onEulaSignupOpen(True); }}
                        style={{"background": "none", "border": "none", "color": "#3b82f6", "fontWeight": "600", "cursor": "pointer", "textDecoration": "none", "fontSize": "0.82rem", "padding": "0", "fontFamily": "system-ui, sans-serif"}}
                    >Terms of Use (EULA)</button>
                </p>
            </div>
    
        </div>;

}