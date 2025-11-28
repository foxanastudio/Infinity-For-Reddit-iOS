//
//  ProxySettingsView.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-25.
//

import SwiftUI

struct ProxySettingsView: View {
    @AppStorage(ProxyUserDefaultsUtils.enableProxyKey, store: .proxy) private var enableProxy: Bool = false
    @AppStorage(ProxyUserDefaultsUtils.proxyTypeKey, store: .proxy) private var proxyType: Int = 0
    @AppStorage(ProxyUserDefaultsUtils.proxyHostnameKey, store: .proxy) private var proxyHostname: String = ""
    @AppStorage(ProxyUserDefaultsUtils.proxyPortKey, store: .proxy) private var proxyPort: String = ""
    
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
                        title: "Proxy Enabled"
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
                        fieldType: .port,
                        focusedField: $focusedField
                    )
                case nil:
                    EmptyView()
                }
            } onConfirm: {
                if let alert = activeAlert {
                    switch alert {
                    case .hostname:
                        proxyHostname = proxyHostnameString
                    case .port:
                        proxyPort = proxyPortString
                    }
                }
            }
        )
        .onChange(of: enableProxy, initial: false) { _, _ in
            VideoProxyManager.shared.reloadConfiguration()
        }
        .onChange(of: proxyType, initial: false) { _, _ in
            VideoProxyManager.shared.reloadConfiguration()
        }
        .onChange(of: proxyHostname, initial: false) { _, _ in
            VideoProxyManager.shared.reloadConfiguration()
        }
        .onChange(of: proxyPort, initial: false) { _, _ in
            VideoProxyManager.shared.reloadConfiguration()
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
