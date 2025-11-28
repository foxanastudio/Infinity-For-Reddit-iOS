//
//  ProxyParameters.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-26.
//

import Foundation

enum ProxyUtils {
    static let serverDefaultPort: UInt = 9876
    static let serverLoopbackHost = "127.0.0.1"
    static let serverOriginURLKey = "__video_origin_url"
    static let serverWorkerQueueLabel = "com.infinity.VideoProxyServer.worker"

    static let timeoutRequest: TimeInterval = 30
    static let timeoutResource: TimeInterval = 300
}
