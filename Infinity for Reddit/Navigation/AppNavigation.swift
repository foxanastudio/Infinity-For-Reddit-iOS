//
//  AppNavigation.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-03.
//

enum AppNavigation: Hashable {
    case login
    case postDetails(postDetailsInput: PostDetailsInput, isFromSubredditPostListing: Bool)
    case postDetailsWithId(postId: String, commentId: String?)
    case subredditDetails(subredditName: String)
    case userDetails(username: String)
    case search(query: String, searchInSubredditOrUserName: String?, searchInMultiReddit: String?, searchInThingType: Int)
    case customFeed(myCustomFeed: MyCustomFeed)
    case inboxConversation(inbox: Inbox)
    case submitComment(commentParent: CommentParent)
}
