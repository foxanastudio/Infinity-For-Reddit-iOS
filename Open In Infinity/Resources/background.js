browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    // message from content.js
    if (request.type === "getEnabled") {
        // send message to iOS App Side
        browser.runtime.sendNativeMessage({ type: "getEnabled" },
            function (response) {
                // send message to content.js
                sendResponse({
                    "enabled": response.enabled,
                });
            },
        );
    }
    
    // message from popup.js
    if (request.type === "toggleEnabled") {
        // send message to iOS App Side
        browser.runtime.sendNativeMessage({ type: "toggleEnabled" });
    }
    
    return true;
});
