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

public class PostListingRepository: PostListingRepositoryProtocol {
    enum PostListingRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
    }
    
    private var account: Account?
    private let session: Session
    
    public init(session: Session) {
        self.session = session
    }
    
    public func setAccount(_ account: Account) {
        self.account = account
    }
    
    public func fetchPosts(
        postListingType: PostListingType,
        pathComponents: [String: String]? = nil,
        queries: [String: String]? = [:],
        params: [String: String]? = [:]
    ) -> AnyPublisher<ListingData, any Error> {
        
        let apiRequest: URLRequestConvertible
        switch postListingType {
        case .frontPage:
            apiRequest = RedditOAuthAPI.getFrontPagePosts(pathComponents: pathComponents!, queries: queries!)
        case .subreddit:
            apiRequest = RedditOAuthAPI.getSubredditPosts(pathComponents: pathComponents!, queries: queries!)
        case .user:
            apiRequest = RedditOAuthAPI.getUserPosts(pathComponents: pathComponents!, queries: queries!)
        case .search:
            apiRequest = RedditOAuthAPI.getSearchPosts(queries: queries!)
        case .multireddit:
            apiRequest = RedditOAuthAPI.getMultiredditPosts(pathComponents: pathComponents!, queries: queries!)
        case .subredditConcat:
            apiRequest = RedditOAuthAPI.getSubredditConcatPosts(pathComponents: pathComponents!, queries: queries!)
        }
        
        return Future<ListingData, any Error> { promise in
            self.session.request(
                apiRequest
            )
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let json = JSON(data)
                            if let error = json.error {
                                throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
                            } else {
                                let postListingRootClass = PostListingRootClass(fromJson: json)
                                print(postListingRootClass)
                                promise(.success(postListingRootClass.data))
                            }
                        } catch {
                            promise(.failure(error))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}
