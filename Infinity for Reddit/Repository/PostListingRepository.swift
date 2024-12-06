//
//  PostListingRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-05.
//

import Combine
import Alamofire
import SwiftyJSON

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
    
    public func fetchPosts(postListingType: PostListingType, limit: Int) -> AnyPublisher<ListingData, any Error> {
        return Future<ListingData, Error> { promise in
            self.session.request(RedditOAuthAPI.getFrongPagePost(headers: APIUtils.getOAuthHeader(accessToken: self.account?.accessToken ?? "")))
                .validate()
                //.publishData()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let json = JSON(data)
                            if let error = json.error {
                                throw PostListingRepositoryError.JSONDecodingError(error.localizedDescription)
                            } else {
                                let postListingRootClass = PostListingRootClass(fromJson: JSON(data))
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
