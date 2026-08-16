function checkOpenInInfinity(urlString) {
    const url = new URL(urlString);
    const hostname = url.hostname;
    
    if (/(^|\.)reddit\.com$/.test(hostname) ||
        /(^|\.)redd\.it$/.test(hostname) ||
        /(^|\.)reddit\.app$/.test(hostname)) {
        browser.runtime.sendMessage({ type: "getEnabled" }).then((response) => {
            if (response.enabled === true) {
                browser.runtime.sendMessage({ type: "openInInfinityIfPossible", urlString: urlString });
            }
        });
    }
}

navigation.addEventListener('navigate', (event) => {
    checkOpenInInfinity(event.destination.url);
});

checkOpenInInfinity(window.location.href);
