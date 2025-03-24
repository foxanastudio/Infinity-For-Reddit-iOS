//
//  PostDetailsRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Combine
import Alamofire
import SwiftyJSON
import Foundation

public class PostDetailsRepository: PostDetailsRepositoryProtocol {
    enum PostDetailsRepositoryError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
    }
    private let session: Session
    
    public init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
    }
    
    public func fetchComments(
        postId: String,
        queries: [String: String] = [:]
    ) -> AnyPublisher<PostDetailsRootClass, any Error> {
        return Future<PostDetailsRootClass, any Error> { promise in
            self.session.request(
                RedditOAuthAPI.getPostAndCommentsById(postId: postId, queries: queries)
            )
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let json = JSON(data)
                            if let error = json.error {
                                throw PostDetailsRepositoryError.JSONDecodingError(error.localizedDescription)
                            } else {
                                let postDetails = try PostDetailsRootClass(fromJson: json)
                                postDetails.makeCommentList()
                                print(postDetails.comments.count)
                                promise(.success(postDetails))
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
