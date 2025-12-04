//
//  ProxySettingsView.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-25.
//

import Network
import SwiftUI

struct ProxySettingsView: View {
    @AppStorage(ProxyUserDefaultsUtils.enableProxyKey, store: .proxy) private var enableProxy: Bool = false
    @AppStorage(ProxyUserDefaultsUtils.proxyTypeKey, store: .proxy) private var proxyType: Int = 0
    @AppStorage(ProxyUserDefaultsUtils.proxyHostnameKey, store: .proxy) private var proxyHostname: String = ""
    @AppStorage(ProxyUserDefaultsUtils.proxyPortKey, store: .proxy) private var proxyPort: String = ""
    
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @State private var activeAlert: ActiveAlert? = nil
    @State private var proxyHostnameString: String = ""
    @State private var proxyPortString: String = ""
    
    @FocusState private var focusedField: FieldType?
    
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 0) {
                    TogglePreference(
                        isEnabled: $enableProxy,
                        title: "Proxy Enabled",
                        subtitle: "Restart the app to see the changes"
                    )
                    .transition(.opacity)
                    
                    BarebonePickerPreference(
                        selected: $proxyType,
                        items: ProxyUserDefaultsUtils.proxyTypes,
                        title: "Proxy Type"
                    ) { index in
                        ProxyUserDefaultsUtils.proxyTypesText[index]
                    }
                    .listPlainItemNoInsets()
                    
                    PreferenceEntry(
                        title: "Hostname",
                        subtitle: proxyHostname
                    ){
                        proxyHostnameString = proxyHostname
                        withAnimation(.linear(duration: 0.2)) {
                            activeAlert = .hostname
                        }
                    }
                    
                    PreferenceEntry(
                        title: "Port",
                        subtitle: proxyPort
                    ){
                        proxyPortString = proxyPort
                        withAnimation(.linear(duration: 0.2)) {
                            activeAlert = .port
                        }
                    }
                }
            }
            .themedList()
        }
        .overlay(
            CustomAlert(title: activeAlert?.title ?? "", isPresented: Binding(
                get: { activeAlert != nil },
                set: { newValue in
                    if !newValue {
                        activeAlert = nil
                    }
                }
            )) {
                switch activeAlert {
                case .hostname:
                    CustomTextField(
                        "Hostname",
                        text: $proxyHostnameString,
                        singleLine: true,
                        fieldType: .hostname,
                        focusedField: $focusedField
                    )
                case .port:
                    CustomTextField(
                        "Port",
                        text: $proxyPortString,
                        singleLine: true,
                        keyboardType: .numberPad,
                        fieldType: .port,
                        focusedField: $focusedField
                    )
                case nil:
                    EmptyView()
                }
            } onConfirm: {
                guard let alert = activeAlert else {
                    return
                }

                switch alert {
                case .hostname:
                    let trimmed = proxyHostnameString.trimmingCharacters(in: .whitespacesAndNewlines)
                    proxyHostnameString = trimmed
                    guard ProxyUtils.isValidHostname(trimmed) else {
                        snackbarManager.showSnackbar(.info("Not a valid IP or host name"))
                        DispatchQueue.main.async {
                            activeAlert = .hostname
                        }
                        return
                    }
                    proxyHostname = trimmed
                case .port:
                    let trimmed = proxyPortString.trimmingCharacters(in: .whitespacesAndNewlines)
                    proxyPortString = trimmed
                    guard let portValue = Int(trimmed) else {
                        snackbarManager.showSnackbar(.info("Not a valid number"))
                        DispatchQueue.main.async {
                            activeAlert = .port
                        }
                        return
                    }
                    guard ProxyUtils.isValidPort(portValue) else {
                        snackbarManager.showSnackbar(.info("Not a valid port (0 - 65535)"))
                        DispatchQueue.main.async {
                            activeAlert = .port
                        }
                        return
                    }
                    proxyPort = trimmed
                }
            }
        )
        .onChange(of: enableProxy, initial: false) { _, _ in
            ProxyManager.shared.reloadConfiguration()
        }
        .onChange(of: proxyType, initial: false) { _, _ in
            ProxyManager.shared.reloadConfiguration()
        }
        .onChange(of: proxyHostname, initial: false) { _, _ in
            ProxyManager.shared.reloadConfiguration()
        }
        .onChange(of: proxyPort, initial: false) { _, _ in
            ProxyManager.shared.reloadConfiguration()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Proxy")
    }
    
    enum FieldType: Hashable {
        case hostname
        case port
    }
}

private enum ActiveAlert: Identifiable {
    case hostname, port
    var id: Int {
        hashValue
    }
    
    var title: String {
        switch self {
        case .hostname: return "Hostname"
        case .port: return "Port"
        }
    }
}
