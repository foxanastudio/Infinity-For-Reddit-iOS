//
// RedditPerAccountAccessTokenInterceptor.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-14
        
import Alamofire
import Foundation

final class RedditPerAccountAccessTokenInterceptor: RequestInterceptor {
    private let getToken: @Sendable() -> String?
    private let refreshToken: @Sendable() async throws -> String
    
    init(getToken: @escaping @Sendable() -> String?, refreshToken: @escaping @Sendable () async throws -> String) {
        self.getToken = getToken
        self.refreshToken = refreshToken
    }
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var req = urlRequest
        if req.url?.host?.contains("oauth.reddit.com") == true, req.headers["Authorization"] == nil, let accessToken = getToken(), !accessToken.isEmpty {
            req.headers.add(name: "Authorization", value: "bearer \(accessToken)")
        }
        if req.headers[APIUtils.USER_AGENT_KEY] == nil {
            req.headers.add(name: APIUtils.USER_AGENT_KEY, value: APIUtils.USER_AGENT)
        }
        completion(.success(req))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard request.retryCount == 0, let http = request.response, http.statusCode == 401 else {
            return completion(.doNotRetryWithError(error))
        }
        
        Task {
            do {
                _ = try await refreshToken()
                completion(.retry)
            } catch {
                completion(.doNotRetryWithError(error))
            }
        }
    }
}
