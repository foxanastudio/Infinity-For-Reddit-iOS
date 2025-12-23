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
    @AppStorage(ProxyUserDefaultsUtils.proxyHostKey, store: .proxy) private var proxyHost: String = ""
    @AppStorage(ProxyUserDefaultsUtils.proxyPortKey, store: .proxy) private var proxyPort: String = ""
    
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @State private var activeAlert: ActiveAlert? = nil
    @State private var proxyHostString: String = ""
    @State private var proxyPortString: String = ""
    
    @FocusState private var focusedField: FieldType?
    
    var body: some View {
        RootView {
            ScrollView {
                VStack(spacing: 0) {
                    InfoPreference(
                        title: "Restart the app to see the changes",
                        icon: "info.circle"
                    )
                    
                    TogglePreference(
                        isEnabled: $enableProxy,
                        title: "Proxy"
                    )
                    .transition(.opacity)
                    
                    if enableProxy {
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
                            subtitle: proxyHost
                        ){
                            proxyHostString = proxyHost
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
                .animation(.easeInOut, value: enableProxy)
            }
        }
        .overlay(
            CustomAlert(title: activeAlert?.title ?? "", confirmButtonText: "OK", isPresented: Binding(
                get: {
                    activeAlert != nil
                },
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
                        text: $proxyHostString,
                        singleLine: true,
                        fieldType: .hostname,
                        focusedField: $focusedField
                    )
                    .submitLabel(.done)
                    .onSubmit {
                        activeAlert = nil
                    }
                case .port:
                    CustomTextField(
                        "Port",
                        text: $proxyPortString,
                        singleLine: true,
                        keyboardType: .numberPad,
                        fieldType: .port,
                        focusedField: $focusedField
                    )
                    .submitLabel(.done)
                    .onSubmit {
                        activeAlert = nil
                    }
                case nil:
                    EmptyView()
                }
            } onConfirm: {
                guard let alert = activeAlert else {
                    return
                }

                switch alert {
                case .hostname:
                    let trimmed = proxyHostString.trimmingCharacters(in: .whitespacesAndNewlines)
                    proxyHostString = trimmed
                    guard ProxyUtils.isValidHostname(trimmed) else {
                        snackbarManager.showSnackbar(.info("Not a valid IP or host name"))
                        DispatchQueue.main.async {
                            activeAlert = .hostname
                        }
                        return
                    }
                    proxyHost = trimmed
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
