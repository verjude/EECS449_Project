"""Authentication form component."""

def:pub AuthForm(
    isSignup: bool,
    username: str,
    password: str,
    error: str,
    loading: bool,
    onUsernameChange: any,
    onPasswordChange: any,
    onSubmit: any,
    onToggleMode: any
) -> obj {
    return
        <div className="auth-container">
            <div className="auth-card">
                <div style={{"textAlign": "center", "marginBottom": "2rem"}}>
                    <h1 className="app-title" style={{"fontSize": "2rem", "marginBottom": "0.5rem"}}>
                        PriceComparator
                    </h1>
                    <p className="app-subtitle">
                        Compare prices across stores with AI
                    </p>
                    <h2>
                        {(
                            "Sign Up" if isSignup else "Sign In"
                        )}
                    </h2>
                </div>
                <form onSubmit={onSubmit}>
                    <div className="form-group">
                        <label className="form-label">Username</label>
                        <input
                            type="text"
                            value={username}
                            onChange={onUsernameChange}
                            className="form-input"
                            placeholder="Enter username"
                            disabled={loading}
                        />
                    </div>
                    <div className="form-group">
                        <label className="form-label">Password</label>
                        <input
                            type="password"
                            value={password}
                            onChange={onPasswordChange}
                            className="form-input"
                            placeholder="Enter password"
                            disabled={loading}
                        />
                    </div>
                    {(
                        <div className="error-message">{error.message}</div>
                    ) if error else None}
                    <button
                        type="submit"
                        className="btn-submit"
                        disabled={loading}
                    >
                        {(
                            "Loading..." if loading else (
                                "Sign Up" if isSignup else "Sign In"
                            )
                        )}
                    </button>
                </form>
                <div className="auth-toggle">
                    <span style={{"color": "rgba(255,255,255,0.6)"}}>
                        {(
                            "Already have an account?" if isSignup else "Don't have an account?"
                        )}
                    </span>
                    <button
                        onClick={onToggleMode}
                        className="btn-link"
                        disabled={loading}
                    >
                        {("Sign In" if isSignup else "Sign Up")}
                    </button>
                </div>
            </div>
        </div>;
}