//
//  ProxyUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-25.
//

import Foundation

class ProxyUserDefaultsUtils {
    static let enableProxyKey = "enable_proxy"
    static var enableProxy: Bool {
        return UserDefaults.proxy.bool(forKey: enableProxyKey)
    }
    
    static let proxyTypeKey = "proxy_type"
    static var proxyType : Int {
        return UserDefaults.proxy.integer(forKey: proxyTypeKey)
    }
    static let proxyTypes: [Int] = [0, 1, 2]
    static let proxyTypesText: [String] = ["HTTP", "SOCKS", "Direct"]
    
    static let proxyHostKey = "proxy_host"
    static var proxyHost : String {
        return UserDefaults.proxy.string(forKey: proxyHostKey) ?? ""
    }
    
    static let proxyPortKey = "proxy_port"
    static var proxyPort : String {
        return UserDefaults.proxy.string(forKey: proxyPortKey) ?? ""
    }
}
