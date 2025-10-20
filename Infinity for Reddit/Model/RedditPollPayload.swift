//
//  RedditPollPayload.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-19.
//

import Foundation

struct RedditPollPayload: Codable {
    enum CodingKeys: String, CodingKey {
        case apiType = "api_type"
        case duration
        case isNsfw = "nsfw"
        case options
        case flairId = "flair_id"
        case flairText = "flair_text"
        case richTextJSON = "raw_rtjson"
        case postToTwitter = "post_to_twitter"
        case sendReplies = "sendreplies"
        case showErrorList = "show_error_list"
        case isSpoiler = "spoiler"
        case subredditName = "sr"
        case submitType = "submit_type"
        case text
        case title
        case validateOnSubmit = "validate_on_submit"
    }
    
    var apiType: String = "json"
    var duration: Int
    var isNsfw: Bool
    var options: [String]
    var flairId: String?
    var flairText: String?
    var richTextJSON: String?
    var postToTwitter: Bool = false
    var sendReplies: Bool
    var showErrorList: Bool = true
    var isSpoiler: Bool
    var subredditName: String
    var submitType: String
    var text: String?
    var title: String
    var validateOnSubmit: Bool = true
    
    init(
        subredditName: String,
        title: String,
        options: [String],
        duration: Int,
        isNsfw: Bool,
        isSpoiler: Bool,
        flair: Flair?,
        sendReplies: Bool,
        submitType: String
    ) {
        self.subredditName = subredditName
        self.title = title
        self.options = options
        self.duration = duration
        self.isNsfw = isNsfw
        self.isSpoiler = isSpoiler
        if let flair = flair {
            self.flairId = flair.id
            self.flairText = flair.text
        }
        self.sendReplies = sendReplies
        self.submitType = submitType
    }
    
    init(
        subredditName: String,
        title: String,
        options: [String],
        duration: Int,
        isNsfw: Bool,
        isSpoiler: Bool,
        flair: Flair?,
        richTextJSON: String?,
        text: String?,
        sendReplies: Bool,
        submitType: String
    ) {
        self.subredditName = subredditName
        self.title = title
        self.options = options
        self.duration = duration
        self.isNsfw = isNsfw
        self.isSpoiler = isSpoiler
        if let flair = flair {
            self.flairId = flair.id
            self.flairText = flair.text
        }
        self.richTextJSON = richTextJSON
        self.text = text
        self.sendReplies = sendReplies
        self.submitType = submitType
    }
}
