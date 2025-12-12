//
//  InterfacePostUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-09.
//

import Foundation

class InterfacePostUserDefaultsUtils {
    static let defaultPostLayoutKey = "default_post_layout"
    static var defaultPostLayout: Int {
        return UserDefaults.interfacePost.integer(forKey: defaultPostLayoutKey)
    }
    static let defaultPostLayouts = [0, 1]
    static let defaultPostLayoutsText = ["Card Layout", "Compact Layout"]
    
    static let defaultLinkPostLayoutKey = "default_link_post_layout"
    static var defaultLinkPostLayout: Int {
        return UserDefaults.interfacePost.integer(forKey: defaultLinkPostLayoutKey)
    }
    static let defaultLinkPostLayouts = [0, 1, 2]
    static let defaultLinkPostLayoutsText = ["Auto", "Card Layout", "Compct Layout"]
    
    static let hidePostTypeKey = "hide_post_type"
    static var hidePostType: Bool {
        return UserDefaults.interfacePost.bool(forKey: hidePostTypeKey)
    }
    
    static let hidePostFlairKey = "hide_post_flair"
    static var hidePostFlair: Bool {
        return UserDefaults.interfacePost.bool(forKey: hidePostFlairKey)
    }
    
    static let hideSubredditAndUserPrefixKey = "hide_subreddit_and_user_prefix"
    static var hideSubredditAndUserPrefix: Bool {
        return UserDefaults.interfacePost.bool(forKey: hideSubredditAndUserPrefixKey)
    }
    
    static let hideNVotesKey = "hide_n_votes"
    static var hideNVotes: Bool {
        return UserDefaults.interfacePost.bool(forKey: hideNVotesKey)
    }
    
    static let hideNCommentsKey = "hide_n_comments"
    static var hideNComments: Bool {
        return UserDefaults.interfacePost.bool(forKey: hideNCommentsKey)
    }
    
    static let hideTextPostContentKey = "hide_text_post_content"
    static var hideTextPostContent: Bool {
        return UserDefaults.interfacePost.bool(forKey: hideTextPostContentKey)
    }
    
    static let limitMediaHeightKey = "limit_media_height"
    static var limitMediaHeight: Bool {
        return UserDefaults.interfacePost.bool(forKey: limitMediaHeightKey)
    }
}
