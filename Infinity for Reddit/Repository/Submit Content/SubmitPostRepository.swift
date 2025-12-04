//
//  SubmitPostRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-13.
//

import Alamofire
import SwiftyJSON
import UIKit

class SubmitPostRepository: SubmitPostRepositoryProtocol {
    private let session: Session
    
    init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self, name: "plain") else {
            fatalError("Failed to resolve plain Session in SubmitPostRepository")
        }
        self.session = resolvedSession
    }
    
    // Returns the ID of the submitted post
    func submitTextPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool,
        embeddedImages: [UploadedImage]
    ) async throws -> String {
        var params = [
            "api_type": "json",
            "sr": subredditName,
            "title": title,
            "kind": "self",
            "spoiler": String(isSpoiler),
            "nsfw": String(isSensitive),
            "sendreplies": String(receivePostReplyNotifications)
        ]
        if !content.isEmpty {
            if !embeddedImages.isEmpty {
                params["richtext_json"] = RichtextJSONConverter(embeddedImages: embeddedImages).constructRichtextJSON(markdownString: content)
            } else {
                params["text"] = content
            }
        }
        if let flair {
            params["flair_text"] = flair.text
            params["flair_id"] = flair.id
        }
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitPost(params: params), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
        
        let id = json["json"]["data"]["id"].stringValue
        if id.isEmpty {
            throw APIError.jsonDecodingError("Failed to get the ID of the submitted post.")
        } else {
            return id
        }
    }
    
    func submitImagePost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        imageUrlString: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws {
        var params = [
            "api_type": "json",
            "sr": subredditName,
            "title": title,
            "kind": "image",
            "url": imageUrlString,
            "spoiler": String(isSpoiler),
            "nsfw": String(isSensitive),
            "sendreplies": String(receivePostReplyNotifications)
        ]
        if !content.isEmpty {
            params["text"] = content
        }
        if let flair {
            params["flair_text"] = flair.text
            params["flair_id"] = flair.id
        }
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitPost(params: params), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
    }
    
    func submitGifPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        gifUrlString: String,
        posterUrlString: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws {
        var params = [
            "api_type": "json",
            "sr": subredditName,
            "title": title,
            "kind": "image",
            "url": gifUrlString,
            "video_poster_url": posterUrlString,
            "spoiler": String(isSpoiler),
            "nsfw": String(isSensitive),
            "sendreplies": String(receivePostReplyNotifications)
        ]
        if !content.isEmpty {
            params["text"] = content
        }
        if let flair {
            params["flair_text"] = flair.text
            params["flair_id"] = flair.id
        }
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitPost(params: params), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
    }
    
    // Returns the ID of the submitted post
    func submitLinkPost(
        account: Account,
        subredditName: String,
        title: String,
        urlString: String,
        content: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws -> String {
        var params = [
            "api_type": "json",
            "sr": subredditName,
            "title": title,
            "kind": "link",
            "url": urlString,
            "spoiler": String(isSpoiler),
            "nsfw": String(isSensitive),
            "sendreplies": String(receivePostReplyNotifications)
        ]
        if !content.isEmpty {
            params["text"] = content
        }
        if let flair {
            params["flair_text"] = flair.text
            params["flair_id"] = flair.id
        }
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitPost(params: params), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
        
        let id = json["json"]["data"]["id"].stringValue
        if id.isEmpty {
            throw APIError.jsonDecodingError("Failed to get the ID of the submitted post.")
        } else {
            return id
        }
    }
    
    // Returns the URL of the submitted post
    func submitGalleryPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        galleryImages: [UploadedImage],
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws -> String {
        let redditGalleryPayload = RedditGalleryPayload(
            subredditName: subredditName,
            submitType: subredditName.hasPrefix("u_") ? "profile" : "subreddit",
            title: title,
            text: content,
            isSpoiler: isSpoiler,
            isNSFW: isSensitive,
            sendReplies: receivePostReplyNotifications,
            flair: flair,
            items: galleryImages.map {
                $0.toRedditGalleryPayloadItem()
            }
        )
        let payloadJSON = try JSONEncoder().encode(redditGalleryPayload)
        let payloadString = String(data: payloadJSON, encoding: .utf8)!
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitGalleryPost(body: payloadString), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
        
        let postUrl = json["json"]["data"]["url"].stringValue
        if postUrl.isEmpty {
            throw APIError.jsonDecodingError("Failed to get the url of the submitted post.")
        } else {
            return postUrl
        }
    }
    
    func submitVideoPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        videoUrlString: String,
        posterUrlString: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws {
        var params = [
            "api_type": "json",
            "sr": subredditName,
            "title": title,
            "kind": "video",
            "url": videoUrlString,
            "video_poster_url": posterUrlString,
            "spoiler": String(isSpoiler),
            "nsfw": String(isSensitive),
            "sendreplies": String(receivePostReplyNotifications)
        ]
        if !content.isEmpty {
            params["text"] = content
        }
        if let flair {
            params["flair_text"] = flair.text
            params["flair_id"] = flair.id
        }
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitPost(params: params), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
    }
    
    // Returns the URL of the submitted post
    func submitPollPost(
        account: Account,
        subredditName: String,
        title: String,
        content: String,
        options: [String],
        duration: Int,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool,
        embeddedImages: [UploadedImage]
    ) async throws -> String {
        let redditPollPayload: RedditPollPayload
        if content.isEmpty {
            redditPollPayload = RedditPollPayload(
                subredditName: subredditName,
                title: title,
                options: options,
                duration: duration,
                isNsfw: isSensitive,
                isSpoiler: isSpoiler,
                flair: flair,
                sendReplies: receivePostReplyNotifications,
                submitType: subredditName.hasPrefix("u_") ? "profile" : "subreddit"
            )
        } else {
            if !embeddedImages.isEmpty {
                redditPollPayload = RedditPollPayload(
                    subredditName: subredditName,
                    title: title,
                    options: options,
                    duration: duration,
                    isNsfw: isSensitive,
                    isSpoiler: isSpoiler,
                    flair: flair,
                    richTextJSON: RichtextJSONConverter(embeddedImages: embeddedImages).constructRichtextJSON(markdownString: content),
                    text: nil,
                    sendReplies: receivePostReplyNotifications,
                    submitType: subredditName.hasPrefix("u_") ? "profile" : "subreddit"
                )
            } else {
                redditPollPayload = RedditPollPayload(
                    subredditName: subredditName,
                    title: title,
                    options: options,
                    duration: duration,
                    isNsfw: isSensitive,
                    isSpoiler: isSpoiler,
                    flair: flair,
                    richTextJSON: nil,
                    text: content,
                    sendReplies: receivePostReplyNotifications,
                    submitType: subredditName.hasPrefix("u_") ? "profile" : "subreddit"
                )
            }
        }
        
        let payloadJSON = try JSONEncoder().encode(redditPollPayload)
        let payloadString = String(data: payloadJSON, encoding: .utf8)!
        
        print(payloadString)
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitPollPost(body: payloadString), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
        
        let postUrl = json["json"]["data"]["url"].stringValue
        if postUrl.isEmpty {
            throw APIError.jsonDecodingError("Failed to get the url of the submitted post.")
        } else {
            return postUrl
        }
    }
    
    func crosspost(
        account: Account,
        subredditName: String,
        title: String,
        crosspostFullname: String,
        flair: Flair?,
        isSpoiler: Bool,
        isSensitive: Bool,
        receivePostReplyNotifications: Bool
    ) async throws -> String {
        var params = [
            "api_type": "json",
            "sr": subredditName,
            "title": title,
            "crosspost_fullname": crosspostFullname,
            "kind": "crosspost",
            "spoiler": String(isSpoiler),
            "nsfw": String(isSensitive),
            "sendreplies": String(receivePostReplyNotifications)
        ]
        if let flair {
            params["flair_text"] = flair.text
            params["flair_id"] = flair.id
        }
        
        let interceptor = await TokenCenter.shared.getRedditPerAccountInterceptor(account: account)
        let data = try await self.session.request(RedditOAuthAPI.submitPost(params: params), interceptor: interceptor)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        try json.throwIfRedditError(defaultErrorMessage: "Failed to submit post.")
        
        let id = json["json"]["data"]["id"].stringValue
        if id.isEmpty {
            throw APIError.jsonDecodingError("Failed to get the ID of the submitted post.")
        } else {
            return id
        }
    }
}
