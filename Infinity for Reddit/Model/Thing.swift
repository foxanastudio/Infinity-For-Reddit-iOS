//
//  Thing.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

enum Thing: Identifiable {
    case subscribedSubreddit(SubscribedSubredditData)
    case subreddit(SubredditData)
    case subredditInCustomFeed(SubredditInCustomFeed)
    case subredditInAnonymousCustomFeed(AnonymousCustomFeedSubreddit)
    case subscribedUser(SubscribedUserData)
    case user(UserData)
    case myCustomFeed(MyCustomFeed)
    
    var id: String {
        switch self {
        case .subscribedSubreddit(let subscribedSubredditData):
            return subscribedSubredditData.name
        case .subreddit(let subredditData):
            return subredditData.name
        case .subredditInCustomFeed(let subredditInCustomFeed):
            return subredditInCustomFeed.name
        case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
            return anonymousCustomFeedSubreddit.subredditName
        case .subscribedUser(let subscribedUserData):
            return subscribedUserData.name
        case .user(let userData):
            return userData.name
        case .myCustomFeed(let myCustomFeed):
            return myCustomFeed.path
        }
    }
    
    var name: String {
        switch self {
        case .subscribedSubreddit(let subscribedSubredditData):
            return subscribedSubredditData.name
        case .subreddit(let subredditData):
            return subredditData.name
        case .subredditInCustomFeed(let subredditInCustomFeed):
            return subredditInCustomFeed.name
        case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
            return anonymousCustomFeedSubreddit.subredditName
        case .subscribedUser(let subscribedUserData):
            return "u_\(subscribedUserData.name)"
        case .user(let userData):
            return "u_\(userData.name)"
        case .myCustomFeed(let myCustomFeed):
            return myCustomFeed.displayName
        }
    }
    
    var iconUrlString: String? {
        switch self {
        case .subscribedSubreddit(let subscribedSubredditData):
            return subscribedSubredditData.iconUrl
        case .subreddit(let subredditData):
            return subredditData.iconUrl
        case .subredditInCustomFeed:
            return nil
        case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
            return anonymousCustomFeedSubreddit.iconUrlString
        case .subscribedUser(let subscribedUserData):
            return subscribedUserData.iconUrl
        case .user(let userData):
            return userData.iconUrl
        case .myCustomFeed:
            return nil
        }
    }
    
    var displayName: String {
        switch self {
        case .subscribedSubreddit(let subscribedSubredditData):
            return "r/\(subscribedSubredditData.name)"
        case .subreddit(let subredditData):
            return "r/\(subredditData.name)"
        case .subredditInCustomFeed(let subredditInCustomFeed):
            return "r/\(subredditInCustomFeed.name)"
        case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
            return "r/\(anonymousCustomFeedSubreddit.subredditName)"
        case .subscribedUser(let subscribedUserData):
            return "u/\(subscribedUserData.name)"
        case .user(let userData):
            return "u/\(userData.name)"
        case .myCustomFeed(let myCustomFeed):
            return myCustomFeed.displayName
        }
    }
    
    var searchInSubredditOrUserName: String {
        switch self {
        case .subscribedSubreddit(let subscribedSubredditData):
            return subscribedSubredditData.name
        case .subreddit(let subredditData):
            return subredditData.name
        case .subredditInCustomFeed(let subredditInCustomFeed):
            return subredditInCustomFeed.name
        case .subredditInAnonymousCustomFeed(let anonymousCustomFeedSubreddit):
            return anonymousCustomFeedSubreddit.subredditName
        case .subscribedUser(let subscribedUserData):
            return subscribedUserData.name
        case .user(let userData):
            return userData.name
        case .myCustomFeed:
            return ""
        }
    }
    
    var searchInCustomFeed: String {
        switch self {
        case .myCustomFeed(let myCustomFeed):
            return myCustomFeed.path
        default:
            return ""
        }
    }
    
    var searchInThingType: SearchInThingType {
        switch self {
        case .subscribedSubreddit:
            return SearchInThingType.subreddit
        case .subreddit:
            return SearchInThingType.subreddit
        case .subredditInCustomFeed:
            return SearchInThingType.subreddit
        case .subredditInAnonymousCustomFeed:
            return SearchInThingType.subreddit
        case .subscribedUser:
            return SearchInThingType.user
        case .user:
            return SearchInThingType.user
        case .myCustomFeed:
            return SearchInThingType.customFeed
        }
    }
}
