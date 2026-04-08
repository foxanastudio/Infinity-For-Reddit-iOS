//
//  PostListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation
import GRDB

public class PostListingRepository: PostListingRepositoryProtocol {
    enum PostListingRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            }
        }
    }
    
    private let session: Session
    private let subredditDao: SubredditDao
    private let postFilterDao: PostFilterDao
    private let subscribedSubredditDao: SubscribedSubredditDao
    private let anonymousCustomFeedSubredditDao: AnonymousCustomFeedSubredditDao
    private let postHistoryDao: PostHistoryDao
    private let partialUserDao: PartialUserDao
    private let userDao: UserDao
    private let subscribedUserDao: SubscribedUserDao
    private var subredditOrUserIcons: [String: String] = [:]
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in PostListingRepository")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool in PostListingRepository")
        }
        self.session = resolvedSession
        self.subredditDao = SubredditDao(dbPool: resolvedDBPool)
        self.postFilterDao = PostFilterDao(dbPool: resolvedDBPool)
        self.subscribedSubredditDao = SubscribedSubredditDao(dbPool: resolvedDBPool)
        self.anonymousCustomFeedSubredditDao = AnonymousCustomFeedSubredditDao(dbPool: resolvedDBPool)
        self.postHistoryDao = PostHistoryDao(dbPool: resolvedDBPool)
        self.partialUserDao = PartialUserDao(dbPool: resolvedDBPool)
        self.userDao = UserDao(dbPool: resolvedDBPool)
        self.subscribedUserDao = SubscribedUserDao(dbPool: resolvedDBPool)
    }
    
    public func fetchPosts(
        postListingType: PostListingType,
        pathComponents: [String: String]? = nil,
        queries: [String: String]? = [:],
        params: [String: String]? = [:]
    ) async throws -> PostListing {
        let apiRequest: URLRequestConvertible
        switch postListingType {
        case .frontPage:
            apiRequest = RedditOAuthAPI.getFrontPagePosts(pathComponents: pathComponents!, queries: queries!)
        case .subreddit:
            apiRequest = RedditOAuthAPI.getSubredditPosts(pathComponents: pathComponents!, queries: queries!)
        case .user:
            apiRequest = RedditOAuthAPI.getUserPosts(pathComponents: pathComponents!, queries: queries!)
        case .search(_, let searchInSubredditOrUserName, let searchInMultiReddit, let searchInThingType):
            switch searchInThingType {
            case .all:
                apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
            case .subreddit:
                if let name = searchInSubredditOrUserName {
                    apiRequest = RedditOAuthAPI.getSearchPostsInSpecificThing(pathComponents: ["name" : "r/\(name)"], queries: queries!)
                } else {
                    apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
                }
            case .user:
                if let name = searchInSubredditOrUserName {
                    apiRequest = RedditOAuthAPI.getSearchPostsInSpecificThing(pathComponents: ["name" : "r/u_\(name)"], queries: queries!)
                } else {
                    apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
                }
            case .customFeed:
                if let path = searchInMultiReddit {
                    apiRequest = RedditOAuthAPI.getSearchPostsInSpecificThing(pathComponents: ["name" : path], queries: queries!)
                } else {
                    apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
                }
            }
        case .customFeed:
            apiRequest = RedditOAuthAPI.getCustomFeedPosts(pathComponents: pathComponents!, queries: queries!)
        case .anonymousFrontPage:
            apiRequest = RedditOAuthAPI.getSubredditConcatPosts(pathComponents: pathComponents!, queries: queries!)
        case .anonymousCustomFeed:
            apiRequest = RedditOAuthAPI.getSubredditConcatPosts(pathComponents: pathComponents!, queries: queries!)
        }
        
        try Task.checkCancellation()
        
        let data = try await self.session.request(apiRequest)
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        return try PostListingRootClass(fromJson: json).data
    }
    
    public func getAnonymousSubscriptionsConcatenated() async -> String {
        do {
            let subscribedSubreddits = try await subscribedSubredditDao.getAllSubscribedSubredditsList(accountName: Account.ANONYMOUS_ACCOUNT.username)
            return subscribedSubreddits.shuffled().prefix(20).map {
                $0.name
            }.joined(separator: "+")
        } catch {
            return ""
        }
    }
    
    public func getAnonymousCustomThemeSubredditsConcatenated(myCustomFeed: MyCustomFeed) async -> String {
        do {
            let subscribedSubreddits = try await anonymousCustomFeedSubredditDao.getAllAnonymousMultiRedditSubreddits(path: myCustomFeed.path)
            return subscribedSubreddits.shuffled().prefix(20).map {
                $0.subredditName
            }.joined(separator: "+")
        } catch {
            return ""
        }
    }
    
    public func getPostFilter(postListingType: PostListingType, externalPostFilter: PostFilter?) async -> PostFilter {
        do {
            var postFilters = try await postFilterDao.getValidPostFilters(usage: postListingType.postFilterUsageType.rawValue, nameOfUsage: postListingType.postFilterNameOfUsage)
            if let externalPostFilter = externalPostFilter {
                postFilters.append(externalPostFilter)
            }
            return PostFilter.mergePostFilter(postFilters)
        } catch {
            return PostFilter()
        }
    }
    
    public func loadIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.userIconUrlString == nil else { return }
        
        if "u/\(post.author ?? "")" == post.subredditNamePrefixed {
            // User's own subreddit
            if subredditOrUserIcons[post.author] != nil {
                await MainActor.run {
                    post.userIconUrlString = subredditOrUserIcons[post.author]
                }
            } else {
                try await loadUserIcon(post: post)
            }
        }
//        } else {
//            if subredditOrUserIcons[post.subreddit] != nil {
//                await MainActor.run {
//                    post.subredditOrUserIcon = subredditOrUserIcons[post.subreddit]
//                }
//            } else {
//                try await loadSubredditIcon(post: post)
//            }
//        }
    }
    
//    private func loadSubredditIcon(post: Post) async throws {
//        try Task.checkCancellation()
//        
//        guard post.subredditOrUserIcon == nil else { return }
//        
//        let subredditData = try? await subredditDao.getSubredditDataByName(subredditName: post.subreddit)
//        if let subredditData {
//            await MainActor.run {
//                post.subredditOrUserIcon = subredditData.iconUrl ?? ""
//                subredditOrUserIcons[post.subreddit] = post.subredditOrUserIcon
//            }
//            return
//        }
//        let subscribedSubredditData = try? await subscribedSubredditDao.getSubscribedSubreddit(subredditName: post.subreddit, accountName: AccountViewModel.shared.account.username)
//        if let subscribedSubredditData {
//            await MainActor.run {
//                post.subredditOrUserIcon = subscribedSubredditData.iconUrl ?? ""
//                subredditOrUserIcons[post.subreddit] = post.subredditOrUserIcon
//            }
//            return
//        }
//        
//        let data = try await self.session.request(
//            RedditOAuthAPI.getSubredditData(subredditName: post.subreddit)
//        )
//            .validate()
//            .serializingData(automaticallyCancelling: true)
//            .value
//        
//        try Task.checkCancellation()
//        
//        let json = JSON(data)
//        if let error = json.error {
//            throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
//        }
//        let fetchedSubredditData = try? SubredditDetailRootClass(fromJson: json).toSubredditData()
//        if let fetchedSubredditData {
//            try? await subredditDao.insert(subredditData: fetchedSubredditData)
//        }
//        
//        await MainActor.run {
//            post.subredditOrUserIcon = fetchedSubredditData?.iconUrl ?? ""
//            subredditOrUserIcons[post.subreddit] = post.subredditOrUserIcon
//        }
//    }
    
    private func loadUserIcon(post: Post) async throws {
        try Task.checkCancellation()
        
        guard post.userIconUrlString == nil else { return }
        
        let partialUserData = try? await partialUserDao.getPartialUserData(username: post.author)
        if let partialUserData {
            await MainActor.run {
                post.userIconUrlString = partialUserData.profileImageUrlString
                subredditOrUserIcons[post.subreddit] = post.userIconUrlString
            }
            return
        }
        let userData = try? await userDao.getUserData(username: post.author)
        if let userData {
            await MainActor.run {
                post.userIconUrlString = userData.iconUrl ?? ""
                subredditOrUserIcons[post.subreddit] = post.userIconUrlString
            }
            return
        }
        let subscribedUserData = try? await subscribedUserDao.getSubscribedUser(name: post.author, accountName: AccountViewModel.shared.account.username)
        if let subscribedUserData {
            await MainActor.run {
                post.userIconUrlString = subscribedUserData.iconUrl ?? ""
                subredditOrUserIcons[post.subreddit] = post.userIconUrlString
            }
            return
        }
        
        let data = try await self.session.request(
            RedditAPI.getUserData(username: post.author)
        )
        .validate()
        .serializingData()
        .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        try await MainActor.run {
            post.userIconUrlString = try UserDetailRootClass(fromJson: json).toUserData().iconUrl ?? ""
            subredditOrUserIcons[post.author] = post.userIconUrlString
        }
    }
    
    public func toggleHidePost(_ post: Post) async throws {
        let params = ["id": post.name]
        
        try Task.checkCancellation()
        
        _ = try await self.session.request(post.hidden ? RedditOAuthAPI.unhidePost(params: params) : RedditOAuthAPI.hidePost(params: params))
            .validate()
            .serializingDecodable(Empty.self, automaticallyCancelling: true)
            .value
    }
    
    public func toggleHidePostAnonymous(_ post: Post) async throws {
        do {
            if !post.hidden {
                try await postHistoryDao.insert(
                    postHistory: PostHistory(
                        username: Account.ANONYMOUS_ACCOUNT.username,
                        postId: post.id,
                        postHistoryType: .hidden,
                        time: Int64(Date().timeIntervalSince1970)
                    )
                )
            } else {
                try await postHistoryDao.deletePostHistory(username: Account.ANONYMOUS_ACCOUNT.username, postId: post.id, postHistoryType: .hidden)
            }
        }
    }
}
