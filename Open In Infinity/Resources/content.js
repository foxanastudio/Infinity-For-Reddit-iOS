browser.runtime.sendMessage({ type: "getEnabled" }).then((response) => {
    if (response.enabled === true) {
        window.location.href = "infinityredirect://open-from-safari?url=" + window.location.href;
    }
});
