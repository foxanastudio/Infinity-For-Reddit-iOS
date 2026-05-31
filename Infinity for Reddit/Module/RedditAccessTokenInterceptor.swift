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
    private let refreshTokenSession: Session = ProxyUtils.makeSession()
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        guard let url = urlRequest.url else {
            return completion(.success(urlRequest))
        }
        
        var urlRequest = urlRequest
        if url.absoluteString.hasPrefix("https://oauth.reddit.com") {
            if urlRequest.headers["Authorization"] == nil {
                urlRequest.setValue("bearer \((try? RedditAccessTokenKeychainManager.shared.getAccessToken(accountName: AccountViewModel.shared.account.username)) ?? "")", forHTTPHeaderField: "Authorization")
                urlRequest.setValue(APIUtils.USER_AGENT, forHTTPHeaderField: APIUtils.USER_AGENT_KEY)
            }
        } else if url.absoluteString.hasPrefix("https://www.reddit.com") {
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.host = "www.reddit.com"
            
            if let newURL = components?.url {
                urlRequest.url = newURL
                
                if urlRequest.headers["Authorization"] == nil {
                    urlRequest.setValue("bearer \((try? RedditAccessTokenKeychainManager.shared.getAccessToken(accountName: AccountViewModel.shared.account.username)) ?? "")", forHTTPHeaderField: "Authorization")
                    urlRequest.setValue(APIUtils.USER_AGENT, forHTTPHeaderField: APIUtils.USER_AGENT_KEY)
                }
            }
        }
        
        printInDebugOnly(urlRequest.url?.absoluteString ?? "Empty URL?")
        
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount == 0 else { return completion(.doNotRetry) }
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 || response.statusCode == 403 else {
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
        
        if !AccountViewModel.shared.account.isAnonymous()
            && request.request?.value(forHTTPHeaderField: "Authorization")?.contains((try? RedditAccessTokenKeychainManager.shared.getAccessToken(accountName: AccountViewModel.shared.account.username)) ?? "") != true {
            lock.unlock()
            return completion(.retry)
        }
        
        refreshAccessToken { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let token):
                do {
                    try RedditAccessTokenKeychainManager.shared.saveAccessToken(accountName: AccountViewModel.shared.account.username, accessToken: token.0)
                    if let refreshToken = token.1, !refreshToken.isEmpty {
                        try RedditAccessTokenKeychainManager.shared.saveRefreshToken(accountName: AccountViewModel.shared.account.username, refreshToken: refreshToken)
                    }
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
    private func refreshAccessToken(completion: @escaping (Result<(String, String?), Error>) -> Void) {
        let parameters: [String: String]
        if AccountViewModel.shared.account.isAnonymous() {
            parameters = ["grant_type": "https://oauth.reddit.com/grants/installed_client", "device_id": "DO_NOT_TRACK_THIS_DEVICE"]
        } else {
            guard let refreshToken = try? RedditAccessTokenKeychainManager.shared.getRefreshToken(accountName: AccountViewModel.shared.account.username) else {
                completion(.failure(NSError(domain: "TokenManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No refresh token found"])))
                return
            }
            
            parameters = ["grant_type": "refresh_token", "refresh_token": refreshToken]
        }
        
        refreshTokenSession.request("https://www.reddit.com/api/v1/access_token", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: APIUtils.getHttpBasicAuthHeader())
            .validate()
            .responseDecodable(of: AccessTokenResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
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
