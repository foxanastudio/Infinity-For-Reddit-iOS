//
//  VideoProxyServer.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-25.
//

import Combine
import Foundation
import GCDWebServer

enum VideoProxyFormat: String, CaseIterable {
    case m3u8
    case ts
    case mp4
    case m4s
    case m4a
    case m4v
    case mpd
}

final class VideoProxyServer {
    private let service: VideoProxyService
    private let webServer: GCDWebServer
    private let originURLKey = ProxyUtils.serverOriginURLKey
    private let port: UInt = ProxyUtils.serverDefaultPort
    private var cancellables = Set<AnyCancellable>()
    private let workerQueue = DispatchQueue(label: ProxyUtils.serverWorkerQueueLabel, qos: .userInteractive)

    init(service: VideoProxyService) {
        self.service = service
        self.webServer = GCDWebServer()
        addRequestHandler()
    }

    deinit {
        stop()
    }

    func start() {
        let startWork = { [weak self] in
            guard let self else {
                return
            }
            guard !self.webServer.isRunning else {
                print("VideoProxy: Server already running")
                return
            }
            self.webServer.start(withPort: self.port, bonjourName: nil)
            print("VideoProxy: Server started on port \(self.port)")
        }

        if Thread.isMainThread {
            startWork()
        } else {
            DispatchQueue.main.sync(execute: startWork)
        }
    }

    func stop() {
        let stopWork = { [weak self] in
            guard let self else {
                return
            }
            guard self.webServer.isRunning else {
                return
            }
            self.webServer.stop()
            print("VideoProxy: Server stopped")
        }

        if Thread.isMainThread {
            stopWork()
        } else {
            DispatchQueue.main.sync(execute: stopWork)
        }
    }

    var isRunning: Bool {
        webServer.isRunning
    }

    private func originURL(from request: GCDWebServerRequest) -> URL? {
        guard let encoded = request.query?[originURLKey],
              let decoded = encoded.removingPercentEncoding,
              let url = URL(string: decoded) else {
            return nil
        }

        guard VideoProxyFormat(rawValue: url.pathExtension) != nil else {
            return nil
        }

        return url
    }

    func reverseProxyURL(from originURL: URL) -> URL? {
        guard var components = URLComponents(url: originURL, resolvingAgainstBaseURL: false) else {
            return nil
        }

        components.scheme = "http"
        components.host = ProxyUtils.serverLoopbackHost
        components.port = Int(port)

        let originItem = URLQueryItem(name: originURLKey, value: originURL.absoluteString)
        components.queryItems = (components.queryItems ?? []) + [originItem]

        return components.url
    }

    private func addRequestHandler() {
        webServer.addHandler(forMethod: "GET",
                             pathRegex: "^/.*\\.*$",
                             request: GCDWebServerRequest.self) { [weak self] (request: GCDWebServerRequest, completion) in
            self?.workerQueue.async { [weak self] in
                guard let self else {
                    return completion(GCDWebServerErrorResponse(statusCode: 500))
                }

                self.logIncomingRequest(request)

                guard let originURL = self.originURL(from: request) else {
                    return completion(GCDWebServerErrorResponse(statusCode: 400))
                }

                let originRequest = self.originURLRequest(originURL, originalRequest: request)
                let publisher: AnyPublisher<GCDWebServerResponse, Never>

                if originURL.pathExtension == VideoProxyFormat.m3u8.rawValue {
                    publisher = self.playlistResponse(originRequest, originURL: originURL)
                } else {
                    publisher = self.mediaResponse(originRequest)
                }

                publisher
                    .receive(on: self.workerQueue)
                    .sink { response in
                        self.logOutgoingResponse(response)
                        completion(response)
                    }
                    .store(in: &self.cancellables)
            }
        }
    }

    private func mediaResponse(_ request: URLRequest) -> AnyPublisher<GCDWebServerResponse, Never> {
        service.dataTaskPublisher(request)
            .subscribe(on: workerQueue)
            .map { item -> GCDWebServerResponse in
                let response = GCDWebServerDataResponse(data: item.data, contentType: item.mimeType ?? "application/octet-stream")
                self.applyMetadata(from: item, to: response)
                return response
            }
            .catch { _ in
                Just(GCDWebServerErrorResponse(statusCode: 500))
            }
            .eraseToAnyPublisher()
    }

    private func playlistResponse(_ request: URLRequest, originURL: URL) -> AnyPublisher<GCDWebServerResponse, Never> {
        service.dataTaskPublisher(request)
            .subscribe(on: workerQueue)
            .tryMap { item in
                let playlistData = try self.reverseProxyPlaylist(with: item, originURL: originURL)
                let response = GCDWebServerDataResponse(data: playlistData, contentType: item.mimeType ?? "application/x-mpegurl")
                self.applyMetadata(from: item, to: response, skipContentLength: true)
                return response
            }
            .map { $0 as GCDWebServerResponse }
            .catch { _ in
                Just(GCDWebServerErrorResponse(statusCode: 500))
            }
            .eraseToAnyPublisher()
    }

    private func applyMetadata(from item: VideoProxyResponseItem, to response: GCDWebServerResponse, skipContentLength: Bool = false) {
        response.statusCode = item.statusCode
        item.headers.forEach { key, value in
            if skipContentLength && key.caseInsensitiveCompare("Content-Length") == .orderedSame {
                return
            }
            if key.caseInsensitiveCompare("Transfer-Encoding") == .orderedSame {
                return
            }
            if key.caseInsensitiveCompare("Content-Encoding") == .orderedSame {
                return
            }
            response.setValue(value, forAdditionalHeader: key)
        }
    }

    private func reverseProxyPlaylist(with item: VideoProxyResponseItem, originURL: URL) throws -> Data {
        guard let original = String(data: item.data, encoding: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }

        let rewritten = original
            .components(separatedBy: .newlines)
            .map { processPlaylistLine($0, originURL: originURL) }
            .joined(separator: "\n")

        guard let data = rewritten.data(using: .utf8) else {
            throw URLError(.cannotDecodeRawData)
        }

        return data
    }

    private func processPlaylistLine(_ line: String, originURL: URL) -> String {
        guard !line.isEmpty else {
            return line
        }

        if line.hasPrefix("#") {
            return lineByReplacingURI(line: line, originURL: originURL)
        }

        if let absolute = absoluteURL(from: line, originURL: originURL),
           let proxied = reverseProxyURL(from: absolute) {
            return proxied.absoluteString
        }

        return line
    }

    private func lineByReplacingURI(line: String, originURL: URL) -> String {
        guard let pattern = try? NSRegularExpression(pattern: "URI=\"([^\"]*)\"") else {
            return line
        }

        let range = NSRange(location: 0, length: line.count)
        guard let match = pattern.firstMatch(in: line, options: [], range: range) else {
            return line
        }

        let uri = (line as NSString).substring(with: match.range(at: 1))
        guard let absolute = absoluteURL(from: uri, originURL: originURL),
              let proxied = reverseProxyURL(from: absolute) else {
            return line
        }

        return pattern.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "URI=\"\(proxied.absoluteString)\"")
    }

    private func absoluteURL(from line: String, originURL: URL) -> URL? {
        if let absolute = URL(string: line), absolute.scheme != nil {
            return absolute
        }

        if line.hasPrefix("/") {
            var components = URLComponents()
            components.scheme = originURL.scheme
            components.host = originURL.host
            components.path = line
            return components.url
        }

        return URL(string: line, relativeTo: originURL.deletingLastPathComponent())?.absoluteURL
    }

    private func originURLRequest(_ originURL: URL, originalRequest: GCDWebServerRequest) -> URLRequest {
        var request = URLRequest(url: originURL)
        request.httpMethod = originalRequest.method

        if let dataRequest = originalRequest as? GCDWebServerDataRequest {
            let body = dataRequest.data
            if !body.isEmpty {
                request.httpBody = body
            }
        }

        originalRequest.headers.forEach { key, value in
            guard shouldForwardHeader(key) else { return }
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func shouldForwardHeader(_ header: String) -> Bool {
        let excluded = ["Host", "Connection", "Content-Length"]
        return !excluded.contains { $0.caseInsensitiveCompare(header) == .orderedSame }
    }

    private func logIncomingRequest(_ request: GCDWebServerRequest) {
        print("VideoProxy AVPlayer requested: \(request.method) \(request.path)")

        let headers = request.headers
        if !headers.isEmpty {
            print("Request headers: \(headers)")
        }
    }

    private func logOutgoingResponse(_ response: GCDWebServerResponse) {
        print("VideoProxy Responding with status: \(response.statusCode)")
    }
}
