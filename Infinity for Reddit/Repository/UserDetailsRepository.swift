//
//  UserDetailsRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-04.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation
import GRDB

public class UserDetailsRepository: UserDetailsRepositoryProtocol {
    enum UserDetailsRepositoryError: LocalizedError {
        case NetworkError(String)
        case JSONDecodingError(String)
        case userDataLoadFailed
        
        var errorDescription: String? {
            switch self {
            case .NetworkError(let message):
                return message
            case .JSONDecodingError(let message):
                return message
            case .userDataLoadFailed:
                return "Failed to load user data"
            }
        }
    }
    
    private let session: Session
    private let userDao: UserDao
    private let subscribedUserDao: SubscribedUserDao
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in UserDetailsRepository")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool in UserDetailsRepository")
        }
        self.session = resolvedSession
        self.userDao = UserDao(dbPool: resolvedDBPool)
        self.subscribedUserDao = SubscribedUserDao(dbPool: resolvedDBPool)
    }
    
    public func fetchUserDetails(username: String) async throws -> UserData {
        var userData = try? userDao.getUserData(username: username)
        if userData == nil {
            let data = try await self.session.request(
                RedditAPI.getUserData(username: username)
            )
            .validate()
            .serializingData()
            .value
            
            try Task.checkCancellation()
            
            let json = JSON(data)
            if let error = json.error {
                throw UserDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
            }
            
            userData = try UserDetailRootClass(fromJson: json).toUserData()
            
            try? userDao.insert(userData: userData!)
        }
        
        if let ud = userData {
            userData?.isSubscribed = (try? subscribedUserDao.getSubscribedUser(name: ud.name, accountName: AccountViewModel.shared.account.username)) != nil
        }
        
        if let userData = userData {
            return userData
        }
        
        throw UserDetailsRepositoryError.userDataLoadFailed
    }
    
    public func followUser(userData: UserData, action: String) async throws {
        guard !AccountViewModel.shared.account.isAnonymous() else {
            try await anonymoustFollowUser(userData: userData)
            return
        }
        
        let params = ["action": action, "sr_name": "u_\(userData.name)"]
        
        _ = try await self.session.request(RedditOAuthAPI.subsrcribeToSubreddit(params: params))
            .validate()
            .serializingDecodable(Empty.self)
            .value

        if action == "unsub" {
            try? subscribedUserDao.deleteSubscribedUser(name: userData.name, accountName: AccountViewModel.shared.account.username)
        } else {
            let subscribedUserData = userData.toSubscribedUserData()
            try? subscribedUserDao.insert(subscribedUserData: subscribedUserData)
        }
    }
    
    private func anonymoustFollowUser(userData: UserData) async throws {
        if userData.isSubscribed {
            try subscribedUserDao.deleteSubscribedUser(name: userData.name, accountName: AccountViewModel.shared.account.username)
        } else {
            try subscribedUserDao.insert(subscribedUserData: userData.toSubscribedUserData())
        }
    }
}
