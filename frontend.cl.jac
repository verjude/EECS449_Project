"""Price Comparator - Client-Side UI with routing, location search, and AI cross-product recommendations."""

import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }
import "./styles.css";

import from components.StoreItem { StoreItem }
import from components.StoreEntryItem { StoreEntryItem }
import from components.AuthForm { AuthForm }
import from components.StoreProductsPage { StoreProductsPage }
import from components.Navbar { Navbar }
import from components.CrossProductResults { CrossProductResults }
import from components.LandingPage { LandingPage }

sv import from main {
    AddProduct, ListProducts, DeleteProduct,
    AddStorePrice, ListStorePrices, UpdateStorePrice, DeleteStore,
    GetBestPrice, ComparePrices,
    AddStoreEntry, ListStoreEntries, DeleteStoreEntry, FindNearbyStores,
    LivePriceSearch
}

def:pub app -> JsxElement {
    has isLoggedIn: bool = False,
        checkingAuth: bool = True,
        isSignup: bool = False,
        username: str = "",
        password: str = "",
        error: str = "",
        loading: bool = False,
        showAuthModal: bool = False,

        # --- Routing ---
        currentPage: str = "home",
        selectedStoreEntry: any = None,

        # --- Products ---
        products: list = [],
        newProductName: str = "",
        productsLoading: bool = True,
        selectedProductId: str = "",
        selectedProductName: str = "",
        stores: list = [],
        storesLoading: bool = False,
        newStoreName: str = "",
        newStorePrice: str = "",
        newStoreUrl: str = "",
        comparison: any = None,
        comparisonLoading: bool = False,

        # --- Global store list ---
        storeEntries: list = [],
        newStoreEntryName: str = "",
        storeEntriesLoading: bool = True,

        # --- Location search ---
        locationQuery: str = "",
        nearbyStores: list = [],
        locationLoading: bool = False,
        locationError: str = "",

        # --- AI Product Search ---
        searchQuery: str = "",
        searchLoading: bool = False,
        searchResults: any = None,
        searchError: str = "",
        useSelectedStores: bool = True,
        searchVersion: int = 0,
        eulaOpen: bool = False,
        eulaAccepted: bool = False,
        eulaSignupOpen: bool = False;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    can with [isLoggedIn] entry {
        if isLoggedIn {
            fetchStoreEntries();
        }
    }

    # --- Product methods ---
    async def fetchProducts -> None;
    async def addProduct -> None;
    async def deleteProduct(productId: str) -> None;
    async def selectProduct(productId: str, productName: str) -> None;
    async def fetchStores(productId: str) -> None;
    async def addStore -> None;
    async def deleteStore(storeName: str) -> None;
    async def compareAllPrices -> None;
    async def handleLogin -> None;
    async def handleSignup -> None;
    def handleLogout -> None;
    async def handleSubmit(e: any) -> None;
    def handleProductKeyPress(e: any) -> None;
    def handleStoreKeyPress(e: any) -> None;
    def getBestPrice -> any;

    # --- Store list methods ---
    async def fetchStoreEntries -> None;
    async def addStoreEntry -> None;
    async def deleteStoreEntry(storeId: str) -> None;
    def handleStoreEntryKeyPress(e: any) -> None;
    async def addStoreEntryDirect(name: str) -> None;

    # --- Routing methods ---
    def navigateToStoreProducts(store: any) -> None;
    def navigateTo(page: str) -> None;

    # --- Location search methods ---
    async def searchNearbyStores -> None;
    def getUserLocation -> None;
    def handleLocationKeyPress(e: any) -> None;

    # --- Search methods ---
    def handleSearchKeyPress(e: any) -> None;
    async def handleQuickPriceSearch -> None;
    def cancelSearch -> None;
    def clearSearch -> None;

    if checkingAuth {
        return
            <div style={{"display": "flex", "justifyContent": "center",
                         "alignItems": "center", "minHeight": "100vh",
                         "color": "rgba(44,32,16,0.6)", "fontFamily": "system-ui"}}>
                Loading...
            </div>;
    }

    # ── Not logged in: show public landing page ──
    if not isLoggedIn {
        return
            <LandingPage
                isSignup={isSignup}
                username={username}
                password={password}
                error={error}
                loading={loading}
                showAuthModal={showAuthModal}
                onUsernameChange={lambda e: any -> None { username = e.target.value; }}
                onPasswordChange={lambda e: any -> None { password = e.target.value; }}
                onSubmit={handleSubmit}
                onToggleMode={lambda -> None { isSignup = not isSignup; error = ""; eulaAccepted = False; }}
                onOpenAuth={lambda -> None { showAuthModal = True; isSignup = False; error = ""; }}
                onOpenAuthSignup={lambda -> None { showAuthModal = True; isSignup = True; error = ""; }}
                onCloseAuth={lambda -> None { showAuthModal = False; error = ""; }}
                eulaAccepted={eulaAccepted}
                eulaSignupOpen={eulaSignupOpen}
                onEulaAcceptedChange={lambda e: any -> None { eulaAccepted = e.target.checked; }}
                onEulaSignupOpen={lambda val: bool -> None { eulaSignupOpen = val; }}
            />;
    }

    # ── Logged in: show app ──
    bestPrice = getBestPrice();

    return
        <div className="main-layout">
            <Navbar
                currentPage={currentPage}
                onNavigate={navigateTo}
                onLogout={handleLogout}
            />
            {(
                <StoreProductsPage
                    store={selectedStoreEntry}
                    onBack={lambda -> None { navigateTo("home"); }}
                />
            ) if currentPage == "store-products" and selectedStoreEntry else (
                <div className="app-container">
                    <div className="app-content">

                        <div className="card" style={{"marginBottom": "1.5rem"}}>
                            <h2 className="panel-title" style={{"display": "flex", "alignItems": "center", "gap": "0.5rem"}}>
                                <span>🔍</span> Price Search
                            </h2>
                            <p className="panel-subtitle" style={{"color": "rgba(44,32,16,0.55)"}}>
                                Search for any product to compare prices across stores
                            </p>
                            <div className="add-row" style={{"gap": "0.5rem", "flexWrap": "wrap"}}>
                                <input
                                    type="text"
                                    value={searchQuery}
                                    onChange={lambda e: any -> None { searchQuery = e.target.value; }}
                                    onKeyPress={handleSearchKeyPress}
                                    placeholder="Search any product (e.g. Tylenol, AirPods Pro 2)..."
                                    className="todo-input"
                                    style={{"flex": "1", "minWidth": "200px"}}
                                />
                                {(
                                    <button
                                        onClick={lambda -> None { cancelSearch(); }}
                                        style={{
                                            "whiteSpace": "nowrap",
                                            "padding": "0.75rem 1.25rem",
                                            "background": "rgba(0,0,0,0.06)",
                                            "border": "1px solid rgba(0,0,0,0.15)",
                                            "borderRadius": "8px",
                                            "color": "rgba(44,32,16,0.7)",
                                            "fontWeight": "600",
                                            "fontSize": "0.95rem",
                                            "cursor": "pointer"
                                        }}
                                    >
                                        Stop
                                    </button>
                                ) if searchLoading else (
                                    <button
                                        onClick={lambda -> None { handleQuickPriceSearch(); }}
                                        className="btn-add"
                                        disabled={not searchQuery.strip()}
                                        style={{"whiteSpace": "nowrap"}}
                                    >
                                        Search
                                    </button>
                                )}
                                {(
                                    <button
                                        onClick={lambda -> None { clearSearch(); }}
                                        style={{
                                            "whiteSpace": "nowrap",
                                            "background": "transparent",
                                            "border": "1px solid rgba(0,0,0,0.15)",
                                            "color": "rgba(44,32,16,0.45)",
                                            "borderRadius": "6px",
                                            "padding": "0.5rem 0.75rem",
                                            "cursor": "pointer",
                                            "fontSize": "0.85rem"
                                        }}
                                    >
                                        × Clear
                                    </button>
                                ) if (searchResults or searchError) and not searchLoading else None}
                            </div>
                            <div style={{"marginTop": "0.75rem", "display": "flex", "alignItems": "center", "gap": "0.5rem"}}>
                                <label style={{"display": "flex", "alignItems": "center", "gap": "0.4rem", "cursor": "pointer", "fontSize": "0.85rem", "color": "rgba(44,32,16,0.6)"}}>
                                    <input
                                        type="checkbox"
                                        checked={useSelectedStores}
                                        onChange={lambda e: any -> None { useSelectedStores = e.target.checked; }}
                                        style={{"accentColor": "#3b82f6"}}
                                    />
                                    Only show prices from my stores
                                    {(" (" + str(storeEntries.length) + " stores)") if storeEntries.length > 0 else " (none added yet)"}
                                </label>
                            </div>

                            {(
                                <div style={{
                                    "marginTop": "1rem",
                                    "padding": "0.75rem 1rem",
                                    "background": "rgba(248,113,113,0.1)",
                                    "border": "1px solid rgba(248,113,113,0.3)",
                                    "borderRadius": "8px",
                                    "color": "#f87171",
                                    "fontSize": "0.9rem"
                                }}>
                                    {searchError}
                                </div>
                            ) if searchError else None}

                            {(
                                <div style={{"marginTop": "0.5rem", "textAlign": "center", "color": "rgba(44,32,16,0.4)", "fontSize": "0.85rem", "padding": "1.5rem 0"}}>
                                    Searching...
                                </div>
                            ) if searchLoading else None}

                            {(
                                <CrossProductResults results={searchResults} />
                            ) if searchResults and not searchLoading else None}
                        </div>

                        <div className="two-column-layout">
                            <div className="column-left">
                                <div className="card">
                                    <h2 className="panel-title">Stores</h2>
                                    <p className="panel-subtitle">
                                        Add stores you want to track. Click a store to manage its products.
                                    </p>
                                    <div className="add-row">
                                        <input
                                            type="text"
                                            value={newStoreEntryName}
                                            onChange={lambda e: any -> None { newStoreEntryName = e.target.value; }}
                                            onKeyPress={handleStoreEntryKeyPress}
                                            placeholder="Enter store name (e.g. Amazon)..."
                                            className="todo-input"
                                        />
                                        <button
                                            onClick={lambda -> None { addStoreEntry(); }}
                                            className="btn-add"
                                        >
                                            Add
                                        </button>
                                    </div>
                                </div>
                                <div className="card">
                                    {(
                                        <div className="loading-message">Loading stores...</div>
                                    ) if storeEntriesLoading else (
                                        <div>
                                            {(
                                                <div className="empty-message">
                                                    No stores yet. Add one above!
                                                </div>
                                            ) if storeEntries.length == 0 else (
                                                <div>
                                                    {[
                                                        <StoreEntryItem
                                                            key={store.id}
                                                            store={store}
                                                            onDelete={deleteStoreEntry}
                                                            onSelect={navigateToStoreProducts}
                                                        /> for store in storeEntries
                                                    ]}
                                                </div>
                                            )}
                                        </div>
                                    )}
                                </div>
                            </div>

                            <div className="column-right">
                                <div className="card">
                                    <h2 className="panel-title">Find Nearby Stores</h2>
                                    <p className="panel-subtitle">
                                        Enter your city or address to find stores near you
                                    </p>
                                    <div className="add-row" style={{"gap": "0.5rem", "flexWrap": "wrap"}}>
                                        <input
                                            type="text"
                                            value={locationQuery}
                                            onChange={lambda e: any -> None { locationQuery = e.target.value; }}
                                            onKeyPress={handleLocationKeyPress}
                                            placeholder="Enter your location (e.g. Austin, TX)..."
                                            className="todo-input"
                                            style={{"flex": "1"}}
                                        />
                                        <button
                                            onClick={lambda -> None { getUserLocation(); }}
                                            className="btn-add"
                                            style={{"whiteSpace": "nowrap", "background": "#3b82f6", "borderColor": "#2563eb"}}
                                            title="Use my current location"
                                        >
                                            📍 GPS
                                        </button>
                                        <button
                                            onClick={lambda -> None { searchNearbyStores(); }}
                                            className="btn-add"
                                            disabled={locationLoading}
                                        >
                                            {("Searching..." if locationLoading else "Search")}
                                        </button>
                                    </div>
                                    {(
                                        <div className="error-message" style={{"marginTop": "0.5rem"}}>
                                            {locationError}
                                        </div>
                                    ) if locationError else None}

                                {(
                                    <div style={{"marginTop": "1rem"}}>
                                        {[
                                            <div
                                                key={nearbyStore.place_id}
                                                className="ingredient-item"
                                                style={{"flexDirection": "column", "alignItems": "flex-start", "gap": "0.25rem"}}
                                            >
                                                <div style={{"display": "flex", "justifyContent": "space-between", "width": "100%", "alignItems": "center"}}>
                                                    <div>
                                                        <span className="ingredient-name">{nearbyStore.name}</span>
                                                        <span style={{
                                                            "fontSize": "0.75rem",
                                                            "color": "rgba(44,32,16,0.45)",
                                                            "marginLeft": "0.5rem"
                                                        }}>
                                                            {nearbyStore.store_type}
                                                        </span>
                                                    </div>
                                                    <div style={{"display": "flex", "alignItems": "center", "gap": "0.75rem"}}>
                                                        <span style={{"fontSize": "0.85rem", "color": "#4ade80", "fontWeight": "600", "whiteSpace": "nowrap"}}>
                                                            {nearbyStore.distance} mi
                                                        </span>
                                                        <button
                                                            onClick={lambda -> None { addStoreEntryDirect(nearbyStore.name); }}
                                                            className="btn-add"
                                                            style={{
                                                                "fontSize": "0.75rem",
                                                                "padding": "0.3rem 0.65rem",
                                                                "whiteSpace": "nowrap",
                                                                "background": "#3b82f6",
                                                                "border": "1px solid #2563eb"
                                                            }}
                                                            title={"Add " + nearbyStore.name + " to your store list"}
                                                        >
                                                            + Add Store
                                                        </button>
                                                    </div>
                                                </div>
                                                <span style={{"fontSize": "0.75rem", "color": "rgba(44,32,16,0.5)"}}>
                                                    {nearbyStore.address}
                                                </span>
                                            </div> for nearbyStore in nearbyStores
                                        ]}
                                    </div>
                                ) if nearbyStores.length > 0 else None}
                                </div>

                                {selectedProductId and (
                                    <div>
                                        <div className="card">
                                            <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "center", "marginBottom": "1rem"}}>
                                                <div>
                                                    <h2 className="panel-title">{selectedProductName}</h2>
                                                    <p className="panel-subtitle">Add stores and prices</p>
                                                </div>
                                                <button
                                                    onClick={lambda -> None { compareAllPrices(); }}
                                                    disabled={comparisonLoading or stores.length < 2}
                                                    className="btn-generate"
                                                    style={{"fontSize": "0.9rem", "padding": "0.5rem 1rem"}}
                                                >
                                                    {("Analyzing..." if comparisonLoading else "Compare All")}
                                                </button>
                                            </div>
                                            <div className="add-row" style={{"gap": "0.5rem", "flexWrap": "wrap"}}>
                                                <input
                                                    type="text"
                                                    value={newStoreName}
                                                    onChange={lambda e: any -> None { newStoreName = e.target.value; }}
                                                    placeholder="Store name"
                                                    className="todo-input"
                                                    style={{"flex": "1", "minWidth": "120px"}}
                                                />
                                                <input
                                                    type="number"
                                                    step="0.01"
                                                    value={newStorePrice}
                                                    onChange={lambda e: any -> None { newStorePrice = e.target.value; }}
                                                    onKeyPress={handleStoreKeyPress}
                                                    placeholder="Price"
                                                    className="todo-input"
                                                    style={{"width": "100px"}}
                                                />
                                                <input
                                                    type="text"
                                                    value={newStoreUrl}
                                                    onChange={lambda e: any -> None { newStoreUrl = e.target.value; }}
                                                    placeholder="URL (optional)"
                                                    className="todo-input"
                                                    style={{"flex": "1", "minWidth": "150px"}}
                                                />
                                                <button
                                                    onClick={lambda -> None { addStore(); }}
                                                    className="btn-add"
                                                >
                                                    Add
                                                </button>
                                            </div>
                                        </div>
                                        {(
                                            <div className="card">
                                                <div className="comparison-panel">
                                                    <h3 style={{"margin": "0 0 1rem 0", "fontSize": "1.1rem", "color": "#2c2010"}}>
                                                        AI Analysis
                                                    </h3>
                                                    <div style={{"display": "grid", "gap": "0.75rem"}}>
                                                        <div className="stat-item">
                                                            <span className="stat-label">Best Deal:</span>
                                                            <span className="stat-value" style={{"color": "#4ade80"}}>{comparison.best_store}</span>
                                                        </div>
                                                        <div className="stat-item">
                                                            <span className="stat-label">Worst Deal:</span>
                                                            <span className="stat-value" style={{"color": "#f87171"}}>{comparison.worst_store}</span>
                                                        </div>
                                                        <div className="stat-item">
                                                            <span className="stat-label">Average Price:</span>
                                                            <span className="stat-value">${comparison.avg_price.toFixed(2)}</span>
                                                        </div>
                                                        <div style={{"marginTop": "0.5rem", "padding": "1rem", "background": "rgba(255,255,255,0.05)", "borderRadius": "8px", "borderLeft": "3px solid #3b82f6"}}>
                                                            <div style={{"fontSize": "0.85rem", "color": "rgba(44,32,16,0.6)", "marginBottom": "0.5rem"}}>
                                                                Recommendation
                                                            </div>
                                                            <div style={{"color": "#2c2010", "lineHeight": "1.5"}}>
                                                                {comparison.recommendation}
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        ) if comparison else None}
                                        <div className="card">
                                            {(
                                                <div className="loading-message">Loading stores...</div>
                                            ) if storesLoading else (
                                                <div>
                                                    {(
                                                        <div className="empty-message">
                                                            No stores added yet. Add prices above!
                                                        </div>
                                                    ) if stores.length == 0 else (
                                                        <div>
                                                            {(bestPrice) and (
                                                                <div className="best-price-banner">
                                                                    <div style={{"display": "flex", "alignItems": "center", "gap": "0.5rem"}}>
                                                                        <span style={{"fontSize": "1.5rem"}}>🏆</span>
                                                                        <div>
                                                                            <div style={{"fontWeight": "600", "color": "#2c2010"}}>
                                                                                Best Price: {bestPrice.name}
                                                                            </div>
                                                                            <div style={{"fontSize": "0.85rem", "color": "rgba(44,32,16,0.6)"}}>
                                                                                ${bestPrice.price.toFixed(2)}
                                                                            </div>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            )}
                                                            <div style={{"marginTop": "1rem"}}>
                                                                {[
                                                                    <StoreItem
                                                                        key={store.name}
                                                                        store={store}
                                                                        onDelete={deleteStore}
                                                                        isBest={bestPrice and store.name == bestPrice.name}
                                                                    /> for store in stores
                                                                ]}
                                                            </div>
                                                        </div>
                                                    )}
                                                </div>
                                            )}
                                        </div>
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>
                </div>
            )}
            <footer style={{
                "textAlign": "center",
                "padding": "1.25rem 2rem",
                "fontSize": "0.8rem",
                "color": "rgba(44,32,16,0.45)",
                "borderTop": "1px solid rgba(0,0,0,0.07)",
                "marginTop": "2rem"
            }}>
                © 2026 PriceComparator · University of Michigan ·{" "}
                <button
                    onClick={lambda -> None { eulaOpen = True; }}
                    style={{"background": "none", "border": "none", "color": "#3b82f6", "cursor": "pointer", "textDecoration": "underline", "fontSize": "0.8rem", "padding": "0"}}
                >
                    Terms of Use (EULA)
                </button>
            </footer>
            {eulaOpen and (
                <div style={{
                    "position": "fixed",
                    "top": "0", "left": "0", "right": "0", "bottom": "0",
                    "background": "rgba(0,0,0,0.45)",
                    "zIndex": "2000",
                    "display": "flex",
                    "alignItems": "center",
                    "justifyContent": "center",
                    "padding": "1.5rem"
                }}>
                    <div style={{
                        "background": "#fdf8f0",
                        "borderRadius": "16px",
                        "padding": "2rem 2.5rem",
                        "maxWidth": "680px",
                        "width": "100%",
                        "maxHeight": "82vh",
                        "overflowY": "auto",
                        "boxShadow": "0 20px 60px rgba(0,0,0,0.25)",
                        "border": "1px solid rgba(0,0,0,0.08)"
                    }}>
                        <div style={{"display": "flex", "justifyContent": "space-between", "alignItems": "flex-start", "marginBottom": "1.5rem"}}>
                            <div>
                                <h2 style={{"fontSize": "1.4rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.25rem"}}>End User License Agreement</h2>
                                <p style={{"fontSize": "0.8rem", "color": "rgba(44,32,16,0.5)"}}>Last Updated: April 13, 2026</p>
                            </div>
                            <button onClick={lambda -> None { eulaOpen = False; }} style={{"background": "transparent", "border": "none", "fontSize": "1.5rem", "cursor": "pointer", "color": "rgba(44,32,16,0.4)", "lineHeight": "1", "padding": "0.25rem"}}>×</button>
                        </div>
                        <p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.7)", "marginBottom": "1.25rem", "lineHeight": "1.6"}}>PLEASE READ THIS AGREEMENT CAREFULLY BEFORE USING THIS SOFTWARE. By accessing or using this software ("the Service"), you agree to be bound by the terms of this End User License Agreement. If you do not agree, do not use the Service.</p>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>Educational Context</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>This software was developed by students as part of an academic course at the University of Michigan. It is provided for demonstration and educational purposes only and may not meet the standards of commercially released software.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>Use at Your Own Risk</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>THE SERVICE IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, RELIABILITY, OR NON-INFRINGEMENT. YOUR USE OF THE SERVICE IS SOLELY AT YOUR OWN RISK.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>Limitation of Liability</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, NEITHER THE STUDENT DEVELOPERS, THE UNIVERSITY OF MICHIGAN, ITS FACULTY, INSTRUCTORS, REGENTS, EMPLOYEES, NOR ANY AFFILIATED PARTIES SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF — OR INABILITY TO USE — THE SERVICE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>No Guarantees of Availability</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>The Service may be discontinued, modified, or taken offline at any time without notice. No guarantee of uptime, continued access, or future development is made.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>Data</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>Do not submit sensitive, confidential, or personal data to this Service. The student developers make no guarantees regarding data security, storage, or privacy.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>Indemnification</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>You agree to indemnify and hold harmless the student developers, the University of Michigan, its faculty, instructors, and Regents from any claims, damages, or expenses arising from your use of the Service or your violation of this Agreement.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>Governing Law</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>This Agreement shall be governed by the laws of the State of Michigan, without regard to conflict of law principles. Any disputes shall be subject to the exclusive jurisdiction of the courts located in Washtenaw County, Michigan.</p></div>
                        <div style={{"marginBottom": "1.25rem"}}><h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>Acceptance</h3><p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>By using the Service, you acknowledge that you have read, understood, and agree to be bound by this Agreement.</p></div>
                        <div style={{"marginTop": "1.5rem", "textAlign": "right"}}>
                            <button onClick={lambda -> None { eulaOpen = False; }} className="btn-add" style={{"padding": "0.6rem 1.5rem"}}>Close</button>
                        </div>
                    </div>
                </div>
            )};
        </div>;
}