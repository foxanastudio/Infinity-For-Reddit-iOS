browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    // Message from content.js
    if (request.type === "getEnabled") {
        // Send message to SafariWebExtensionHandler
        browser.runtime.sendNativeMessage({ type: "getEnabled" },
            function (response) {
                // Send message to content.js
                sendResponse({
                    "enabled": response.enabled,
                });
            },
        );
    } else if (request.type === "toggleEnabled") {
        // Message from popup.js
        // Send message to SafariWebExtensionHandler
        browser.runtime.sendNativeMessage({ type: "toggleEnabled" });
    } else if (request.type === "openInInfinityIfPossible" && Object.hasOwn(request, "urlString")) {
        // Message from content.js
        // Send message to SafariWebExtensionHandler
        browser.runtime.sendNativeMessage({ type: "checkIfCanHandle", urlString: request.urlString },
            function (response) {
                if (response.canHandle) {
                    browser.tabs.update({ url: "infinityredirect://open-from-safari?url=" + request.urlString });
                }
            },
        );
    }
    
    return true;
});
