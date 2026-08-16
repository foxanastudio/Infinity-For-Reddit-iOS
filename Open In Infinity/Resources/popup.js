let switchInput = document.getElementById("switchInput");

function toggleEnabled() {
    browser.runtime.sendMessage({ type: "toggleEnabled" });
}

switchInput.addEventListener("click", toggleEnabled);

browser.runtime.sendMessage({ type: "getEnabled" }).then((response) => {
    switchInput.checked = response.enabled;
});
