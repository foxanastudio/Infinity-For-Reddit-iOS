//
//  ProxyConfiguration.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-30.
//

import Foundation

struct ProxyConfiguration {
    enum ProxyType: Int {
        case http = 0
        case socks = 1
        case direct = 2
        
        var description: String {
            switch self {
            case .http: return "HTTP"
            case .socks: return "SOCKS"
            case .direct: return "Direct"
            }
        }
    }
    
    let host: String?
    let port: Int?
    let type: ProxyType
    
    init?() {
        guard ProxyUserDefaultsUtils.enableProxy else {
            return nil
        }
        
        guard let proxyType = ProxyType(rawValue: ProxyUserDefaultsUtils.proxyType) else {
            return nil
        }
        self.type = proxyType
        
        if proxyType == .direct {
            self.host = nil
            self.port = nil
            return
        }
        
        let rawHost = ProxyUserDefaultsUtils.proxyHost.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rawHost.isEmpty else {
            return nil
        }
        
        let rawPort = ProxyUserDefaultsUtils.proxyPort.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let port = Int(rawPort), port > 0 else {
            return nil
        }
        
        self.host = rawHost
        self.port = port
    }
    
    var connectionProxyDictionary: [AnyHashable: Any]? {
        guard let host, let port else {
            return nil
        }
        
        switch type {
        case .http:
            return [
                kCFNetworkProxiesHTTPEnable as String: true,
                kCFNetworkProxiesHTTPProxy as String: host,
                kCFNetworkProxiesHTTPPort as String: port,
                "HTTPSEnable": true,
                "HTTPSProxy": host,
                "HTTPSPort": port
            ]
        case .socks:
            return [
                "SOCKSEnable": true,
                "SOCKSProxy": host,
                "SOCKSPort": port
            ]
        case .direct:
            return nil
        }
    }
}
