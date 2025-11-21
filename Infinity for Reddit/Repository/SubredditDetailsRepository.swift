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
            try? subscribedSubredditDao.insert(subscribedSubredditData: subredditData.toSubscribedSubredditData())
        }
    }
    
    private func anonymousSubscribeSubreddit(subredditData: SubredditData) async throws {
        if subredditData.isSubscribed {
            try subscribedSubredditDao.deleteSubscribedSubreddit(subredditName: subredditData.name, accountName: Account.ANONYMOUS_ACCOUNT.username)
        } else {
            try subscribedSubredditDao.insert(subscribedSubredditData: subredditData.toSubscribedSubredditData())
        }
    }
    
    public func fetchUserFlairs(subredditName: String) async throws -> [UserFlair] {
        let data = try await self.session.request(RedditOAuthAPI.getUserFlairs(subredditName: subredditName))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw SubredditDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
        }
        
        var result: [UserFlair] = []
        for userFlairJson in json.arrayValue {
            do {
                let userFlair = try UserFlair(fromJson: userFlairJson)
                result.append(userFlair)
            } catch {
                // Ignore
            }
        }
        return result
    }
    
    public func selectUserFlair(subredditName: String, userFlair: UserFlair?) async throws {
        let params: [String: String]
        if let userFlair {
            params = ["api_type": "json", "flair_template_id": userFlair.id, "name": AccountViewModel.shared.account.username, "text": userFlair.text]
        } else {
            params = ["api_type": "json", "name": AccountViewModel.shared.account.username]
        }
        
        _ = await self.session.request(RedditOAuthAPI.selectUserFlair(subredditName: subredditName, params: params))
            .validate()
            .serializingData(automaticallyCancelling: true)
            .response
    }
}
