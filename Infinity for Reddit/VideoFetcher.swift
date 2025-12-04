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
    
    private let redgifsSession: Session
    private let streamableSession: Session
    private let vReddItSession: Session
    private let session: Session
    
    private init() {
        guard let resolvedRedgifsSession = DependencyManager.shared.container.resolve(Session.self, name: "redgifs") else {
            fatalError("Failed to resolve redgifs Session in VideoFetcher")
        }
        guard let resolvedStreamableSession = DependencyManager.shared.container.resolve(Session.self, name: "streamable") else {
            fatalError("Failed to resolve streamable Session in VideoFetcher")
        }
        guard let resolvedVReddItSession = DependencyManager.shared.container.resolve(Session.self, name: "vReddIt") else {
            fatalError("Failed to resolve vReddIt Session in VideoFetcher")
        }
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in VideoFetcher")
        }
        redgifsSession = resolvedRedgifsSession
        streamableSession = resolvedStreamableSession
        vReddItSession = resolvedVReddItSession
        session = resolvedSession
    }
    
    func fetchRedgifsVideo(id: String) async throws -> URL? {
        let data = try await redgifsSession.request(RedgifsAPI.getRedgifsData(id: id))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
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
    
    func fetchStreamableVideo(shortCode: String) async throws -> URL? {
        let data = try await streamableSession.request(StreamableAPI.getStreamableData(shortCode: shortCode))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        let streamable = try Streamable(fromJson: json)
        if let mp4 = streamable.mp4 {
            return URL(string: mp4.url)
        } else if let mp4Mobile = streamable.mp4mobile {
            return URL(string: mp4Mobile.url)
        }
        
        return nil
    }
    
    func fetchVReddItVideo(url: URL) async throws -> URL? {
        let response = await vReddItSession.request(VReddItAPI.getRedirectUrl(url: url))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .response
        
        if let redirectedUrl = response.response?.url {
            print(redirectedUrl)
            let redirectPath = redirectedUrl.path
            
            if redirectPath.range(of: #"^/r/\w+/comments/\w+/?\w+/?$"#, options: .regularExpression) != nil ||
               redirectPath.range(of: #"^/user/\w+/comments/\w+/?\w+/?$"#, options: .regularExpression) != nil {
                
                let segments = redirectedUrl.pathComponents
                if let commentsIndex = segments.lastIndex(of: "comments"), commentsIndex + 1 < segments.count {
                    let postId = segments[commentsIndex + 1]
                    print("Post id: \(postId)")
                    if let post = try await fetchPost(postId: postId) {
                        switch post.postType {
                        case .redditVideo(let videoUrlString, _):
                            return URL(string: videoUrlString)
                        case .video(let videoUrlString, _):
                            return URL(string: videoUrlString)
                        case .redgifs(let redgifsId):
                            return try await fetchRedgifsVideo(id: redgifsId)
                        case .streamable(let shortCode):
                            return try await fetchStreamableVideo(shortCode: shortCode)
                        default:
                            return nil
                        }
                    }
                }
            }
        }
        
        return nil
    }
    
    private func fetchPost(postId: String) async throws -> Post? {
        let data = try await self.session.request(
            RedditAPI.getPostAndCommentsById(postId: postId, queries: [:])
        )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        let postDetails = try PostDetailsRootClass(fromJson: json, parseComments: false)
        
        return postDetails.postListing.posts.isEmpty ? nil : postDetails.postListing.posts[0]
    }
}
