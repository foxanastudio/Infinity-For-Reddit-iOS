//
//  AppNavigation.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-03.
//

enum AppNavigation: Hashable {
    case login
    case postDetails(postDetailsInput: PostDetailsInput, isFromSubredditPostListing: Bool)
    case postDetailsWithId(postId: String, commentId: String? = nil, isContinueThread: Bool = false)
    case subredditDetails(subredditName: String)
    case userDetails(username: String)
    case search
    case searchResults(query: String, searchInSubredditOrUserName: String?, searchInMultiReddit: String?, searchInThingType: SearchInThingType, searchResultTab: Int)
    case customFeed(customFeed: CustomFeedWrapper)
    case inboxConversation(inbox: Inbox)
    case submitComment(commentParent: CommentParent)
    case editComment(commentToBeEdited: Comment)
    case submitTextPost
    case submitLinkPost
    case submitImagePost
    case submitVideoPost
    case submitGalleryPost
    case submitPollPost
    case filterPosts(postListingMetadata: PostListingMetadata)
    case filterHistoryPosts(historyPostListingMetadata: HistoryPostListingMetadata)
    case filteredPosts(postListingMetadata: PostListingMetadata, postFilter: PostFilter)
    case filteredHistoryPosts(historyPostListingMetadata: HistoryPostListingMetadata, postFilter: PostFilter)
    case editPost(post: Post)
    case crosspost(postToBeCrossposted: Post)
    case sendChatMessage(recipient: String? = nil)
    case createCustomFeed
    case editCustomFeed(customFeedToEdit: CustomFeedWrapper)
    case copyCustomFeed(path: String)
    case report(subredditName: String, thingFullname: String)
}
