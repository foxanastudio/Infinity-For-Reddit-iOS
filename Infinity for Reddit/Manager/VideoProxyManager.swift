//
//  VideoProxyManager.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-25.
//

import Foundation
import GCDWebServer

final class VideoProxyManager {
    static let shared = VideoProxyManager()

    private let controlQueue = DispatchQueue(label: "com.infinity.VideoProxyManager.control", qos: .default)
    private var configuration: ProxyConfiguration?
    private var proxyServer: VideoProxyServer?

    private static let ensureGCDWebServerInitialized: Void = {
        let initialize = {
            _ = GCDWebServer()
        }

        if Thread.isMainThread {
            initialize()
        } else {
            DispatchQueue.main.sync(execute: initialize)
        }
    }()

    private init() {
        _ = VideoProxyManager.ensureGCDWebServerInitialized
        controlQueue.sync {
            if let configuration = ProxyConfiguration() {
                self.configuration = configuration
                configureProxyServer(with: configuration)
            } else {
                self.configuration = nil
                print("VideoProxy: Proxy disabled or misconfigured")
            }
        }
    }

    private func configureProxyServer(with configuration: ProxyConfiguration) {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.connectionProxyDictionary = configuration.connectionProxyDictionary
        sessionConfiguration.timeoutIntervalForRequest = ProxyUtils.timeoutRequest
        sessionConfiguration.timeoutIntervalForResource = ProxyUtils.timeoutResource

        print("VideoProxy: URLSession configured with proxy: \(configuration.host):\(configuration.port) (\(configuration.type.rawValueString))")

        let delegateQueue = OperationQueue()
        delegateQueue.qualityOfService = .userInteractive

        let session = URLSession(configuration: sessionConfiguration,
                                 delegate: nil,
                                 delegateQueue: delegateQueue)
        let service = URLSessionVideoProxyService(session: session)
        proxyServer = VideoProxyServer(service: service)
    }

    private func startLocked() {
        guard configuration != nil else {
            return
        }
        proxyServer?.start()
    }

    private func stopLocked() {
        proxyServer?.stop()
    }

    func start() {
        controlQueue.async { [weak self] in
            self?.startLocked()
        }
    }

    func stop() {
        controlQueue.async { [weak self] in
            self?.stopLocked()
        }
    }

    func proxyURL(_ url: URL) -> URL {
        return controlQueue.sync {
            guard configuration != nil,
                  let proxied = proxyServer?.reverseProxyURL(from: url) else {
                return url
            }

            print("VideoProxy: Proxied URL:\n   Original: \(url.absoluteString)\n   Proxied:  \(proxied.absoluteString)")

            return proxied
        }
    }

    func reloadConfiguration() {
        controlQueue.async { [weak self] in
            guard let self else {
                return
            }

            self.stopLocked()
            self.proxyServer = nil

            guard let newConfiguration = ProxyConfiguration() else {
                self.configuration = nil
                print("VideoProxy: Proxy disabled or misconfigured")
                return
            }

            self.configuration = newConfiguration
            self.configureProxyServer(with: newConfiguration)
            self.startLocked()
        }
    }
}

private struct ProxyConfiguration {
    enum ProxyType: Int {
        case http = 0
        case socks = 1

        var rawValueString: String {
            switch self {
            case .http: return "HTTP"
            case .socks: return "SOCKS"
            }
        }
    }

    let host: String
    let port: Int
    let type: ProxyType

    var connectionProxyDictionary: [AnyHashable: Any] {
        switch type {
        case .http:
            return [
                kCFNetworkProxiesHTTPEnable as String: true,
                kCFNetworkProxiesHTTPProxy as String: host,
                kCFNetworkProxiesHTTPPort as String: port,
                ProxyKey.httpsEnable: true,
                ProxyKey.httpsProxy: host,
                ProxyKey.httpsPort: port
            ]
        case .socks:
            return [
                ProxyKey.socksEnable: true,
                ProxyKey.socksProxy: host,
                ProxyKey.socksPort: port
            ]
        }
    }

    init?() {
        guard ProxyUserDefaultsUtils.enableProxy else {
            return nil
        }

        let rawHost = ProxyUserDefaultsUtils.proxyHostname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rawHost.isEmpty else {
            return nil
        }

        let rawPort = ProxyUserDefaultsUtils.proxyPort.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let port = Int(rawPort), port > 0 else {
            return nil
        }

        guard let proxyType = ProxyType(rawValue: ProxyUserDefaultsUtils.proxyType) else {
            return nil
        }

        self.host = rawHost
        self.port = port
        self.type = proxyType
    }
}

private enum ProxyKey {
    static let httpsEnable = "HTTPSEnable"
    static let httpsProxy = "HTTPSProxy"
    static let httpsPort = "HTTPSPort"
    static let socksEnable = "SOCKSEnable"
    static let socksProxy = "SOCKSProxy"
    static let socksPort = "SOCKSPort"
}
