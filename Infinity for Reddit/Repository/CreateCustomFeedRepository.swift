//
//  CreateCustomFeedRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-19.
//

import Alamofire
import IdentifiedCollections
import SwiftyJSON
import Foundation
import GRDB

class CreateCustomFeedRepository: CreateCustomFeedRepositoryProtocol {
    enum CreateCustomFeedRepositoryError: LocalizedError {
        case failedToCreateCustomFeedModel
        
        var errorDescription: String? {
            switch self {
            case .failedToCreateCustomFeedModel:
                return "Failed to create a model of the custom feed"
            }
        }
    }
    
    private let session: Session
    private let myCustomFeedDao: MyCustomFeedDao
    private let anonymousCustomFeedSubredditDao: AnonymousCustomFeedSubredditDao
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in SendChatMessageRepository")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError( "Failed to resolve DatabasePool")
        }
        self.session = resolvedSession
        self.myCustomFeedDao = MyCustomFeedDao(dbPool: resolvedDBPool)
        self.anonymousCustomFeedSubredditDao = AnonymousCustomFeedSubredditDao(dbPool: resolvedDBPool)
    }
    
    func createCustomFeed(name: String, description: String, isPrivate: Bool, subredditsAndUsersInCustomFeed: IdentifiedArrayOf<SubredditAndUserInCustomFeed>) async throws -> MyCustomFeed {
        guard !AccountViewModel.shared.account.isAnonymous() else {
            return try await createCustomFeedAnonymous(name: name, description: description, subredditsAndUsersInCustomFeed: subredditsAndUsersInCustomFeed)
        }
        
        let payload = CustomFeedModelPayload(
            name: name, description: description, visibility: isPrivate ? "private" : "public", subreddits: subredditsAndUsersInCustomFeed.map {
                ["name": $0.name]
            }
        )
        let model = try JSONEncoder().encode(payload)

        if let modelString = String(data: model, encoding: .utf8) {
            let multipathName: String
            if let spaceIndex = name.firstIndex(of: " ") {
                multipathName = String(name[..<spaceIndex])
            } else {
                multipathName = name
            }
            
            let params: [String: String] = [
                "multipath": "/user/\(AccountViewModel.shared.account.username)/m/\(multipathName)",
                "model": String(format: modelString)
            ]
            
            let response = await self.session.request(RedditOAuthAPI.createCustomFeed(params: params))
                .serializingData(automaticallyCancelling: true)
                .response
            
            guard let statusCode = response.response?.statusCode, let data = response.data else {
                throw APIError.networkError("Cannot create this custom feed.")
            }

            if (200...299).contains(statusCode) {
                let json = JSON(data)
                if let error = json.error {
                    throw APIError.jsonDecodingError(error.localizedDescription)
                }
                
                let createdMyCustomFeed = try CustomFeed(fromJson: json["data"]).toMyCustomFeed()
                
                try? myCustomFeedDao.insert(myCustomFeed: createdMyCustomFeed)
                
                return createdMyCustomFeed
            } else {
                if let customFeedCreationError = try? CustomFeedCreationError(fromJson: JSON(data)) {
                    throw APIError.invalidResponse(customFeedCreationError.explanation.capitalizedFirst)
                } else {
                    throw APIError.networkError("Cannot create this custom feed.")
                }
            }
        } else {
            throw CreateCustomFeedRepositoryError.failedToCreateCustomFeedModel
        }
    }
    
    func createCustomFeedAnonymous(name: String, description: String, subredditsAndUsersInCustomFeed: IdentifiedArrayOf<SubredditAndUserInCustomFeed>) async throws -> MyCustomFeed {
        let myCustomFeed = MyCustomFeed(
            path: "/user/-/m/\(name)",
            displayName: name,
            name: name,
            description: description,
            owner: "-",
            nSubscribers: 0,
            createdUTC: Utils.getCurrentTimeEpoch(),
            over18: false,
            isSubscriber: false,
            isFavorite: false
        )
        try myCustomFeedDao.insert(myCustomFeed: myCustomFeed)
        
        let anonymousCustomFeedSubreddits: [AnonymousCustomFeedSubreddit] = subredditsAndUsersInCustomFeed.map {
            AnonymousCustomFeedSubreddit(
                path: myCustomFeed.path,
                subredditName: $0.name,
                iconUrlString: $0.iconUrlString ?? ""
            )
        }
        
        do {
            try anonymousCustomFeedSubredditDao.insertAll(anonymousMultiredditSubreddits: anonymousCustomFeedSubreddits)
        } catch {
            // Ugly
            print(error)
            try myCustomFeedDao.anonymousDeleteMyCustomFeed(path: myCustomFeed.path)
        }
        
        return myCustomFeed
    }
    
    private struct CustomFeedModelPayload: Codable {
        var name: String
        var description: String
        var visibility: String
        var subreddits: [[String: String]]
        
        enum CodingKeys: String, CodingKey {
            case name = "display_name"
            case description = "description_md"
            case visibility
            case subreddits = "subreddits"
        }
    }
    
    class CustomFeedCreationError {
        var explanation : String!
        var fields : [String]!
        var message : String!
        var reason : String!

        init(fromJson json: JSON!) throws {
            if json.isEmpty {
                throw JSONError.invalidData
            }
            explanation = json["explanation"].stringValue
            fields = [String]()
            let fieldsArray = json["fields"].arrayValue
            for fieldsJson in fieldsArray{
                fields.append(fieldsJson.stringValue)
            }
            message = json["message"].stringValue
            reason = json["reason"].stringValue
        }
    }
}
