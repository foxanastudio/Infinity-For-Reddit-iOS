//
//  RedditAccessTokenInterceptor.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-13.
//

import Alamofire
import Combine
import Foundation

final class RedditAccessTokenInterceptor: RequestInterceptor {
    private let lock = NSLock()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard urlRequest.url?.absoluteString.hasPrefix("https://oauth.reddit.com") == true && urlRequest.headers["Authorization"] == nil else {
            return completion(.success(urlRequest))
        }
        var urlRequest = urlRequest
        
        urlRequest.setValue("bearer \(AccountViewModel.shared.account.accessToken ?? "")", forHTTPHeaderField: "Authorization")
        urlRequest.setValue(APIUtils.USER_AGENT, forHTTPHeaderField: APIUtils.USER_AGENT_KEY)
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount == 0 else { return completion(.doNotRetry) }
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            return completion(.doNotRetryWithError(error))
        }
        
        if let afError = error as? AFError {
            switch afError {
            case .responseValidationFailed:
                break
            default:
                return completion(.doNotRetry)
            }
        }
        
        lock.lock()
        
        if request.request?.value(forHTTPHeaderField: "Authorization")?.contains(AccountViewModel.shared.account.accessToken ?? "") != true {
            lock.unlock()
            return completion(.retry)
        }
        
        refreshAccessToken { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                do {
                    try AccountViewModel.shared.updateTokens(accessToken: token.0, refreshToken: token.1)
                    /// After updating the token we can safely retry the original request.
                    completion(.retry)
                    self.lock.unlock()
                } catch {
                    // TODO should we really care about the result of database operation?
                    completion(.retry)
                    self.lock.unlock()
                }
            case .failure(let error):
                completion(.doNotRetryWithError(error))
                self.lock.unlock()
            }
        }
    }
    
    // MARK: - Refresh the access token
    func refreshAccessToken(completion: @escaping (Result<(String, String?), Error>) -> Void) {
        guard let refreshToken = AccountViewModel.shared.account.refreshToken else {
            completion(.failure(NSError(domain: "TokenManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No refresh token found"])))
            return
        }
        
        // Call your API to refresh the token using the refresh token
        let parameters: [String: String] = ["grant_type": "refresh_token", "refresh_token": refreshToken]
        
        AF.request("https://www.reddit.com/api/v1/access_token", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: APIUtils.getHttpBasicAuthHeader())
            .validate()
            .responseDecodable(of: AccessTokenResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
                    // Use the decoded AccessTokenResponse struct
                    completion(.success((tokenResponse.accessToken, tokenResponse.refreshToken)))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    struct AccessTokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String?
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
        }
    }
}
