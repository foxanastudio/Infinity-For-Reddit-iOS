//
//  ProxyManager.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-25.
//

import Foundation
import GCDWebServer

final class ProxyManager {
    static let shared = ProxyManager()
    
    enum State: Equatable {
        case disabled
        case configured
        case running
        case error(ProxyManagerError)
    }
    
    enum ProxyManagerError: LocalizedError {
        case invalidConfiguration
        case serverNotConfigured
        case serverStartFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidConfiguration:
                return "Proxy configuration is missing or malformed."
            case .serverNotConfigured:
                return "Proxy server was not configured before start/stop."
            case .serverStartFailed:
                return "Proxy server failed to start."
            }
        }
    }
    
    private(set) var state: State = .disabled {
        didSet {
            if case .error(let error) = state {
                print("Proxy: State changed from \(oldValue) to \(state) – \(error.errorDescription ?? "Unknown error")")
            } else {
                print("Proxy: State changed from \(oldValue) to \(state)")
            }
        }
    }

    private let controlQueue = DispatchQueue(label: "com.foxanastudio.infinity.proxymanager.control", qos: .default)
    private var configuration: ProxyConfiguration?
    private var proxyServer: ProxyServer?
    
    private func updateStateLocked(_ newState: State) {
        guard state != newState else { return }
        state = newState
    }
    
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
        _ = ProxyManager.ensureGCDWebServerInitialized
        controlQueue.sync {
            guard let proxyConfiguration = resolveConfiguration() else {
                self.configuration = nil
                return
            }

            self.configuration = proxyConfiguration
            _ = configureProxyServer(with: proxyConfiguration)
        }
    }

    private func resolveConfiguration() -> ProxyConfiguration? {
        guard ProxyUserDefaultsUtils.enableProxy else {
            updateStateLocked(.disabled)
            print("Proxy: Proxy disabled")
            return nil
        }

        guard let configuration = ProxyConfiguration() else {
            updateStateLocked(.error(.invalidConfiguration))
            print("Proxy: Invalid proxy configuration")
            return nil
        }

        return configuration
    }

    @discardableResult
    private func configureProxyServer(with configuration: ProxyConfiguration) -> Bool {
        proxyServer?.stop()
        proxyServer = nil

        guard let proxyDictionary = configuration.connectionProxyDictionary,
              let host = configuration.host,
              let port = configuration.port else {
            print("Proxy: Proxy enabled but missing host/port configuration")
            updateStateLocked(.error(.invalidConfiguration))
            return false
        }

        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.connectionProxyDictionary = proxyDictionary
        sessionConfiguration.timeoutIntervalForRequest = ProxyUtils.timeoutRequest
        sessionConfiguration.timeoutIntervalForResource = ProxyUtils.timeoutResource

        print("Proxy: URLSession configured with proxy: \(host):\(port) (\(configuration.type.description))")

        let delegateQueue = OperationQueue()
        delegateQueue.qualityOfService = .userInteractive

        let session = URLSession(configuration: sessionConfiguration,
                                 delegate: nil,
                                 delegateQueue: delegateQueue)
        let service = URLSessionProxyService(session: session)
        proxyServer = ProxyServer(service: service)
        updateStateLocked(.configured)
        return true
    }

    private func startLocked() {
        guard let configuration else {
            updateStateLocked(.disabled)
            return
        }

        guard let proxyServer else {
            updateStateLocked(.error(.serverNotConfigured))
            return
        }

        proxyServer.start()
        if proxyServer.isRunning {
            updateStateLocked(.running)
        } else {
            updateStateLocked(.error(.serverStartFailed))
        }
    }

    private func stopLocked() {
        guard let configuration else {
            proxyServer?.stop()
            updateStateLocked(.disabled)
            return
        }

        guard let proxyServer else {
            updateStateLocked(.error(.serverNotConfigured))
            return
        }

        if proxyServer.isRunning {
            proxyServer.stop()
        }
        updateStateLocked(.configured)
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
        controlQueue.sync {
            guard let configuration else {
                return url
            }

            guard let proxyServer, state == .running else {
                print("ProxyManager bypassing proxy because server is not running. State: \(state)")
                return url
            }

            let ext = url.pathExtension.lowercased()
            guard ProxyResourceFormat(rawValue: ext) != nil,
                  let proxied = proxyServer.reverseProxyURL(from: url) else {
                #if DEBUG
                print("ProxyManager bypassing proxy for extension:", ext.isEmpty ? "<none>" : ext, url.absoluteString)
                #endif
                return url
            }

            print("Proxy: Proxied URL:\n   Original: \(url.absoluteString)\n   Proxied:  \(proxied.absoluteString)")

            return proxied
        }
    }
}
