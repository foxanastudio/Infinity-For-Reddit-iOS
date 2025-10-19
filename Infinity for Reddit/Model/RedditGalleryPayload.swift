//
//  RedditGalleryPayload.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-19.
//

import Foundation

struct RedditGalleryPayload: Codable {
    enum CodingKeys: String, CodingKey {
        case subredditName = "sr"
        case submitType = "submit_type"
        case apiType = "api_type"
        case showErrorList = "show_error_list"
        case title
        case text
        case isSpoiler = "spoiler"
        case isNSFW = "nsfw"
        case kind
        case originalContent = "original_content"
        case postToTwitter = "post_to_twitter"
        case sendReplies = "sendreplies"
        case validateOnSubmit = "validate_on_submit"
        case flairId = "flair_id"
        case flairText = "flair_text"
        case items
    }

    var subredditName: String
    var submitType: String
    var apiType: String = "json"
    var showErrorList: Bool = true
    var title: String
    var text: String
    var isSpoiler: Bool
    var isNSFW: Bool
    var kind: String = "self"
    var originalContent: Bool = false
    var postToTwitter: Bool = false
    var sendReplies: Bool
    var validateOnSubmit: Bool = true
    var flairId: String?
    var flairText: String?
    var items: [Item]

    init(
        subredditName: String,
        submitType: String,
        title: String,
        text: String,
        isSpoiler: Bool,
        isNSFW: Bool,
        sendReplies: Bool,
        flair: Flair?,
        items: [Item]
    ) {
        self.subredditName = subredditName
        self.submitType = submitType
        self.title = title
        self.text = text
        self.isSpoiler = isSpoiler
        self.isNSFW = isNSFW
        self.sendReplies = sendReplies
        self.flairId = flair?.id
        self.flairText = flair?.text
        self.items = items
    }
    
    struct Item: Codable {
        enum CodingKeys: String, CodingKey {
            case caption
            case outboundUrl = "outbound_url"
            case mediaId = "media_id"
        }

        var caption: String?
        var outboundUrl: String?
        var mediaId: String?
    }
}
