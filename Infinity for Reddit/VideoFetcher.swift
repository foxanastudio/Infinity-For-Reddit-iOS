//
//  VideoFetcher.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-15.
//

import Foundation
import Alamofire
import SwiftyJSON

class VideoFetcher {
    static let shared = VideoFetcher()
    
    enum VideoFetcherError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
    }
    
    private let redgifsSession: Session
    private let streamableSession: Session
    
    private init() {
        guard let resolvedRedgifsSession = DependencyManager.shared.container.resolve(Session.self, name: "redgifs") else {
            fatalError("Failed to resolve redgifs Session in VideoFetcher")
        }
        guard let resolvedStreamableSession = DependencyManager.shared.container.resolve(Session.self, name: "streamable") else {
            fatalError("Failed to resolve streamable Session in VideoFetcher")
        }
        redgifsSession = resolvedRedgifsSession
        streamableSession = resolvedStreamableSession
    }
    
    func fetchRedgifsVideo(id: String) async throws -> URL? {
        let data = try await redgifsSession.request(RedgifsAPI.getRedgifsData(id: id))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw VideoFetcherError.JSONDecodingError(error.localizedDescription)
        }
        
        return parseRedgifsURL(json)
    }
    
    private func parseRedgifsURL(_ json: JSON) -> URL? {
        let gif = json["gif"]
        let urls = gif["urls"]
        
        // Try HD first, fall back to SD if not available
        if urls["hd"].exists() {
            return URL(string: urls["hd"].stringValue)
        } else if urls["sd"].exists() {
            return URL(string: urls["sd"].stringValue)
        } else {
            return nil
        }
    }
    
    func fetchStreamableVideo(shortCode: String) async throws -> Streamable {
        let data = try await streamableSession.request(StreamableAPI.getStreamableData(shortCode: shortCode))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw VideoFetcherError.JSONDecodingError(error.localizedDescription)
        }
        
        return try Streamable(fromJson: json)
    }
}
