//
// SubredditDetailsRepository.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-05-02
        
import Combine
import Alamofire
import SwiftyJSON
import Foundation
import GRDB

public class SubredditDetailsRepository: SubredditDetailsRepositoryProtocol {
    enum SubredditDetailsRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case subredditDataLoadFailed
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .subredditDataLoadFailed:
                return "Failed to load subreddit data"
            }
        }
    }
    
    private let session: Session
    private let subredditDao: SubredditDao
    private let subscribedSubredditDao: SubscribedSubredditDao
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in SubredditDetailsRepository")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool in SubredditDetailsRepository")
        }
        self.session = resolvedSession
        self.subredditDao = SubredditDao(dbPool: resolvedDBPool)
        self.subscribedSubredditDao = SubscribedSubredditDao(dbPool: resolvedDBPool)
    }
    
    public func fetchSubredditDetails(subredditName: String) async throws -> SubredditData {
        var subredditData = try? subredditDao.getSubredditDataByName(subredditName: subredditName)
        if subredditData == nil {
            let data = try await self.session.request(
                RedditAPI.getSubredditData(subredditName: subredditName)
            )
            .validate()
            .serializingData()
            .value
            
            try Task.checkCancellation()
            
            let json = JSON(data)
            if let error = json.error {
                throw SubredditDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
            }
            
            subredditData = try? SubredditDetailRootClass(fromJson: json).toSubredditData()
            if let subredditData {
                try? subredditDao.insert(subredditData: subredditData)
            }
        }
        
        if let sd = subredditData {
            subredditData?.isSubscribed = (try? subscribedSubredditDao.getSubscribedSubreddit(subredditName: sd.name, accountName: AccountViewModel.shared.account.username)) != nil
        }
        
        if let subredditData {
            return subredditData
        }
        
        throw SubredditDetailsRepositoryError.subredditDataLoadFailed
    }
    
    public func subsribeSubreddit(subredditData: SubredditData, action: String) async throws {
        let params = ["action": action, "sr_name": "\(subredditData.name)"]
        
        _ = try await self.session.request(RedditOAuthAPI.subsrcribeToSubreddit(params: params))
            .validate()
            .serializingDecodable(Empty.self)
            .value
        
        if action == "unsub" {
            try? subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: subredditData.name, accountName: AccountViewModel.shared.account.username)
        } else {
            let subscribedSubredditData = SubscribedSubredditData(
                name: subredditData.name,
                iconUrl: subredditData.iconUrl,
                username: AccountViewModel.shared.account.username,
                isFavorite: false
            )
            try? subscribedSubredditDao.insert(subscribedSubredditData: subscribedSubredditData)
        }
    }
}
