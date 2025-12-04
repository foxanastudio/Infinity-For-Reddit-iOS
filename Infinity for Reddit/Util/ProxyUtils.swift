//
//  ProxyParameters.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-26.
//

import Alamofire
import Foundation
import Network

enum ProxyUtils {
    static let serverDefaultPort: UInt = 9876
    static let serverLoopbackHost = "127.0.0.1"
    static let serverOriginURLKey = "__video_origin_url"

    static let timeoutRequest: TimeInterval = 30
    static let timeoutResource: TimeInterval = 300

    static func applyProxyIfNeeded(configuration: URLSessionConfiguration) {
        guard let proxyConfiguration = ProxyConfiguration() else {
            configuration.connectionProxyDictionary = nil
            return
        }

        configuration.connectionProxyDictionary = proxyConfiguration.connectionProxyDictionary
        configuration.timeoutIntervalForRequest = timeoutRequest
        configuration.timeoutIntervalForResource = timeoutResource
    }

    static func makeSession(configuration: URLSessionConfiguration = .af.default,
                            interceptor: RequestInterceptor? = nil) -> Session {
        let mutableConfiguration = configuration
        applyProxyIfNeeded(configuration: mutableConfiguration)
        return Session(configuration: mutableConfiguration, interceptor: interceptor)
    }
    
    static func isValidHostname(_ value: String) -> Bool {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return false
        }
        
        if IPv4Address(trimmed) != nil || IPv6Address(trimmed) != nil {
            return true
        }
        
        return trimmed.range(of: hostnameRegex, options: .regularExpression) != nil
    }
    
    static func isValidPort(_ value: Int) -> Bool {
        return (0...65535).contains(value)
    }
    
    private static let hostnameRegex = "^(?=^.{1,253}$)(([a-z\\d]([a-z\\d-]{0,62}[a-z\\d])*[\\.]){1,3}[a-z]{1,61})$"
}
