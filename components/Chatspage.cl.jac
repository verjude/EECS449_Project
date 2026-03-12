"""Chats page for interacting with the AI."""

sv import from main { AskAI }

def:pub Chatspage() -> obj {
    has prompt: str = "",
        messages: list = [{"role": "ai", "text": "Hi! Ask me anything about products, pricing, or general shopping advice."}],
        loading: bool = False;

    async def handleSend -> None;
    def handleKeyPress(e: any) -> None;

    return
        <div className="app-container">
            <div className="app-content">
                <div className="card chat-container" style={{"display": "flex", "flexDirection": "column", "height": "75vh"}}>
                    <h2 className="panel-title">Product Assistant</h2>
                    <p className="panel-subtitle">Ask questions about product recommendations, specifications, or market trends.</p>
                    
                    <div className="chat-messages" style={{"flex": "1", "overflowY": "auto", "padding": "1rem", "display": "flex", "flexDirection": "column", "gap": "1rem", "border": "1px solid rgba(255,255,255,0.1)", "borderRadius": "8px", "background": "rgba(0,0,0,0.2)"}}>
                        {[
                            <div className={("message " + ("message-user" if msg.role == "user" else "message-ai"))} style={{
                                "padding": "0.75rem 1rem",
                                "borderRadius": "8px",
                                "maxWidth": "80%",
                                "alignSelf": ("flex-end" if msg.role == "user" else "flex-start"),
                                "background": ("rgba(59, 130, 246, 0.2)" if msg.role == "user" else "rgba(255, 255, 255, 0.05)"),
                                "border": ("1px solid rgba(59, 130, 246, 0.4)" if msg.role == "user" else "1px solid rgba(255, 255, 255, 0.1)")
                            }}>
                                {msg.text}
                            </div> for msg in messages
                        ]}
                        {(
                            <div style={{"alignSelf": "flex-start", "color": "rgba(255,255,255,0.5)", "fontStyle": "italic"}}>AI is thinking...</div>
                        ) if loading else None}
                    </div>
                    
                    <div className="chat-input-area" style={{"display": "flex", "gap": "0.5rem", "marginTop": "1rem"}}>
                        <input
                            type="text"
                            value={prompt}
                            onChange={lambda e: any -> None { prompt = e.target.value; }}
                            onKeyPress={handleKeyPress}
                            placeholder="Type your question..."
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
    
    # 1. Update the local state with the user's new message
    currentHistory = messages.concat([{"role": "user", "text": userText}]);
    messages = currentHistory;
    prompt = "";
    loading = True;

    # 2. Spawn the walker with the FULL conversation history
    response = root spawn AskAI(history=currentHistory);
    
    # 3. Extract the response and append it to the chat
    aiText = response.reports[0].response if response.reports else "Sorry, I couldn't process that request right now.";
    messages = messages.concat([{"role": "ai", "text": aiText}]);
    
    loading = False;
}

impl Chatspage.handleKeyPress(e: any) -> None {
    if e.key == "Enter" { handleSend(); }
}