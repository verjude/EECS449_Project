"""Navbar component for app navigation."""

def:pub Navbar(
    currentPage: str,
    onNavigate: any,
    onLogout: any
) -> obj {
    return
        <nav className="navbar">
            <div className="navbar-brand">
                <span className="app-title" style={{"fontSize": "1.5rem", "marginBottom": "0"}}>🛒 PriceComparator</span>
            </div>
            <div className="navbar-links">
                <button
                    className={("nav-link" + (" active" if currentPage == "home" or currentPage == "store-products" else ""))}
                    onClick={lambda -> None { onNavigate("home"); }}
                >
                    Stores & Products
                </button>
            </div>
            <div className="navbar-actions">
                <button onClick={onLogout} className="btn-signout">
                    Sign Out
                </button>
            </div>
        </nav>;
}