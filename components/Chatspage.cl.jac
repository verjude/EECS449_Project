"""Chats page for interacting with the AI."""
sv import from main { AskAI, LivePriceSearch }

def:pub Chatspage() -> obj {
    has prompt: str = "",
        messages: list = [{"role": "ai", "text": "Hi! Ask me anything about products, pricing, or general shopping advice. You can also type something like 'search prices for iPhone 15' to get live price comparisons!"}],
        loading: bool = False;

    async def handleSend -> None;
    def handleKeyPress(e: any) -> None;

    return
    <div className="app-container">
        <div className="app-content">
            <div className="card chat-container" style={{"display": "flex", "flexDirection": "column", "height": "75vh"}}>
                <h2 className="panel-title">Product Assistant</h2>
                <p className="panel-subtitle">Ask questions or search for live prices across Amazon, Walmart, Best Buy and more.</p>

                <div className="chat-messages" style={{
                    "flex": "1",
                    "overflowY": "auto",
                    "padding": "1rem",
                    "display": "flex",
                    "flexDirection": "column",
                    "gap": "1rem",
                    "border": "1px solid rgba(255,255,255,0.1)",
                    "borderRadius": "8px",
                    "background": "rgba(0,0,0,0.2)"
                }}>
                    {[
                        <div className={("message " + ("message-user" if msg.role == "user" else "message-ai"))}
                            style={{
                                "padding": "0.75rem 1rem",
                                "borderRadius": "8px",
                                "maxWidth": "80%",
                                "alignSelf": ("flex-end" if msg.role == "user" else "flex-start"),
                                "background": ("rgba(59, 130, 246, 0.2)" if msg.role == "user" else "rgba(255, 255, 255, 0.05)"),
                                "border": ("1px solid rgba(59, 130, 246, 0.4)" if msg.role == "user" else "1px solid rgba(255, 255, 255, 0.1)")
                            }}>
                            {msg.text}
                            {(
                                <div style={{"marginTop": "0.5rem"}}>
                                    {[
                                        <div style={{
                                            "background": "rgba(255,255,255,0.05)",
                                            "border": "1px solid rgba(255,255,255,0.15)",
                                            "borderRadius": "6px",
                                            "padding": "0.5rem 0.75rem",
                                            "marginTop": "0.4rem",
                                            "fontSize": "0.9rem"
                                        }}>
                                            <strong>{p.store}</strong> — {p.currency} {p.price}
                                            {(" ✅" if p.available else " ❌ Out of stock")}
                                            <a href={p.url} target="_blank" style={{"marginLeft": "0.5rem", "color": "rgba(59,130,246,0.8)"}}>View →</a>
                                        </div> for p in msg.prices
                                    ]}
                                    {(
                                        <div style={{"marginTop": "0.5rem", "fontSize": "0.85rem", "color": "rgba(255,255,255,0.6)"}}>
                                            📊 {msg.analysis.recommendation}
                                        </div>
                                    ) if msg.analysis else None}
                                </div>
                            ) if msg.prices else None}
                        </div> for msg in messages
                    ]}
                    {(
                        <div style={{"alignSelf": "flex-start", "color": "rgba(255,255,255,0.5)", "fontStyle": "italic"}}>
                            AI is thinking...
                        </div>
                    ) if loading else None}
                </div>

                <div className="chat-input-area" style={{"display": "flex", "gap": "0.5rem", "marginTop": "1rem"}}>
                    <input
                        type="text"
                        value={prompt}
                        onChange={lambda e: any -> None { prompt = e.target.value; }}
                        onKeyPress={handleKeyPress}
                        placeholder="Ask anything, or type 'search prices for <product>'..."
                        className="todo-input"
                        disabled={loading}
                    />
                    <button onClick={lambda -> None { handleSend(); }} className="btn-add" disabled={loading or not prompt.trim()}>
                        Send
                    </button>
                </div>
            </div>
        </div>
    </div>;
}

impl Chatspage.handleSend -> None {
    if not prompt.trim() { return; }
    userText = prompt;

    # Add user message to chat
    currentHistory = messages.concat([{"role": "user", "text": userText}]);
    messages = currentHistory;
    prompt = "";
    loading = True;

    # Detect if user wants a live price search
    lowerText = userText.lower();
    isPriceSearch = (
        lowerText.startswith("search prices for") or
        lowerText.startswith("find prices for") or
        lowerText.startswith("compare prices for") or
        lowerText.startswith("how much is") or
        lowerText.startswith("how much does") or
        lowerText.startswith("price of") or
        lowerText.startswith("price for")
    );

    if isPriceSearch {
        # Extract product name from the prompt
        productName = userText
            .replace("search prices for", "")
            .replace("find prices for", "")
            .replace("compare prices for", "")
            .replace("how much is", "")
            .replace("how much does", "")
            .replace("price of", "")
            .replace("price for", "")
            .trim();

        try {
            # Spawn the live price search walker
            response = root spawn LivePriceSearch(product_name=productName);

            if response.reports and not response.reports[0].get("error") {
                data = response.reports[0];
                summaryText = (
                    "Here are the live prices I found for **" + data.product + "**:\n" +
                    "Best store: " + data.analysis.best_store + "\n" +
                    "Average price: $" + str(data.analysis.avg_price)
                );
                messages = messages.concat([{
                    "role": "ai",
                    "text": summaryText,
                    "prices": data.prices,
                    "analysis": data.analysis
                }]);
            } else {
                errorMsg = response.reports[0].get("error", "Unknown error") if response.reports else "No response";
                messages = messages.concat([{
                    "role": "ai",
                    "text": "Sorry, I couldn't find prices for that product. " + errorMsg
                }]);
            }
        } except Exception as e {
            messages = messages.concat([{
                "role": "ai",
                "text": "Sorry, the price search failed. Please try again."
            }]);
        }
    } else {
        # Regular AI chat
        response = root spawn AskAI(history=currentHistory);
        aiText = response.reports[0].response if response.reports else "Sorry, I couldn't process that request right now.";
        messages = messages.concat([{"role": "ai", "text": aiText}]);
    }

    loading = False;
}

impl Chatspage.handleKeyPress(e: any) -> None {
    if e.key == "Enter" { handleSend(); }
}
