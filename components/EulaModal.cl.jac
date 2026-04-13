"""EULA modal — displays the End User License Agreement in a scrollable overlay."""

def:pub EulaModal(onClose: any) -> obj {
    return
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
                        <h2 style={{"fontSize": "1.4rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.25rem"}}>
                            End User License Agreement
                        </h2>
                        <p style={{"fontSize": "0.8rem", "color": "rgba(44,32,16,0.5)"}}>Last Updated: April 13, 2026</p>
                    </div>
                    <button
                        onClick={onClose}
                        style={{
                            "background": "transparent",
                            "border": "none",
                            "fontSize": "1.5rem",
                            "cursor": "pointer",
                            "color": "rgba(44,32,16,0.4)",
                            "lineHeight": "1",
                            "padding": "0.25rem"
                        }}
                    >×</button>
                </div>

                <p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.7)", "marginBottom": "1.25rem", "lineHeight": "1.6"}}>
                    PLEASE READ THIS AGREEMENT CAREFULLY BEFORE USING THIS SOFTWARE. By accessing or using this software ("the Service"), you agree to be bound by the terms of this End User License Agreement. If you do not agree, do not use the Service.
                </p>

                {[
                    ("Educational Context",
                     "This software was developed by students as part of an academic course at the University of Michigan. It is provided for demonstration and educational purposes only and may not meet the standards of commercially released software."),
                    ("Use at Your Own Risk",
                     "THE SERVICE IS PROVIDED \"AS IS\" AND \"AS AVAILABLE\" WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, ACCURACY, RELIABILITY, OR NON-INFRINGEMENT. YOUR USE OF THE SERVICE IS SOLELY AT YOUR OWN RISK."),
                    ("Limitation of Liability",
                     "TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, NEITHER THE STUDENT DEVELOPERS, THE UNIVERSITY OF MICHIGAN, ITS FACULTY, INSTRUCTORS, REGENTS, EMPLOYEES, NOR ANY AFFILIATED PARTIES SHALL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR EXEMPLARY DAMAGES ARISING OUT OF OR IN CONNECTION WITH YOUR USE OF — OR INABILITY TO USE — THE SERVICE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. THIS INCLUDES, WITHOUT LIMITATION, LOSS OF DATA, REVENUE, PROFITS, OR BUSINESS."),
                    ("No Guarantees of Availability",
                     "The Service may be discontinued, modified, or taken offline at any time without notice. No guarantee of uptime, continued access, or future development is made."),
                    ("Data",
                     "Do not submit sensitive, confidential, or personal data to this Service. The student developers make no guarantees regarding data security, storage, or privacy."),
                    ("Indemnification",
                     "You agree to indemnify and hold harmless the student developers, the University of Michigan, its faculty, instructors, and Regents from any claims, damages, or expenses arising from your use of the Service or your violation of this Agreement."),
                    ("Governing Law",
                     "This Agreement shall be governed by the laws of the State of Michigan, without regard to conflict of law principles. Any disputes shall be subject to the exclusive jurisdiction of the courts located in Washtenaw County, Michigan."),
                    ("Acceptance",
                     "By using the Service, you acknowledge that you have read, understood, and agree to be bound by this Agreement.")
                ].map(lambda section: any -> obj {
                    return
                        <div style={{"marginBottom": "1.25rem"}}>
                            <h3 style={{"fontSize": "0.95rem", "fontWeight": "700", "color": "#2c2010", "marginBottom": "0.4rem"}}>
                                {section[0]}
                            </h3>
                            <p style={{"fontSize": "0.875rem", "color": "rgba(44,32,16,0.75)", "lineHeight": "1.6"}}>
                                {section[1]}
                            </p>
                        </div>;
                })}

                <div style={{"marginTop": "1.5rem", "textAlign": "right"}}>
                    <button
                        onClick={onClose}
                        className="btn-add"
                        style={{"padding": "0.6rem 1.5rem"}}
                    >
                        Close
                    </button>
                </div>
            </div>
        </div>;
}
