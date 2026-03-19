//
//  AccountRepository.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-03-09.
//

import Foundation
import AuthenticationServices
import Alamofire
import GRDB
import SwiftyJSON

class AccountRepository: AccountRepositoryProtocol {
    private let sessionForLogin: Session
    private let session: Session
    private let accountDao: AccountDao
    private var authenticationSession: ASWebAuthenticationSession?
    
    enum AccountError: LocalizedError {
        case internalError
        case failedToGetAccessTokenNetworkError
        case failedToGetAccessTokenEmptyResponse
        case failedToGetAccessToken
        case noAccessTokenInResponse
        case failedToParseAccessToken
        case failedToGetMyInfoNetworkError
        case failedToGetMyInfoEmptyResponse
        case failedToGetMyInfo
        case failedToParseAccountInfo
        case failedToSaveAccountInfo
        case failedToGetRedditSettings
        
        var errorDescription: String? {
            switch self {
            case .internalError:
                return "Internal error."
            case .failedToGetAccessTokenNetworkError:
                return "Failed to get access token: network error."
            case .failedToGetAccessTokenEmptyResponse:
                return "Failed to get access token: empty response."
            case .failedToGetAccessToken:
                return "Failed to get access token."
            case .noAccessTokenInResponse:
                return "Failed to get access token: invalid response."
            case .failedToParseAccessToken:
                return "Failed to parse access token."
            case .failedToGetMyInfoNetworkError:
                return "Failed to get my info: network error."
            case .failedToGetMyInfoEmptyResponse:
                return "Failed to get my info: empty response."
            case .failedToGetMyInfo:
                return "Failed to get my info."
            case .failedToParseAccountInfo:
                return "Failed to parse account info."
            case .failedToSaveAccountInfo:
                return "Failed to save account info."
            case .failedToGetRedditSettings:
                return "Failed to get Reddit settings."
            }
        }
    }
    
    init() {
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        
        self.sessionForLogin = ProxyUtils.makeSession()
        self.session = resolvedSession
        self.accountDao = AccountDao(dbPool: resolvedDBPool)
    }
    
    private func getLoginURL() -> URL {
        // Define the OAuth URL components
        let baseURL = URL(string: APIUtils.OAUTH_URL)!
        
        // Build the query parameters
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: APIUtils.CLIENT_ID_KEY, value: APIUtils.CLIENT_ID),
            URLQueryItem(name: APIUtils.RESPONSE_TYPE_KEY, value: APIUtils.RESPONSE_TYPE),
            URLQueryItem(name: APIUtils.STATE_KEY, value: APIUtils.STATE),
            URLQueryItem(name: APIUtils.REDIRECT_URI_KEY, value: APIUtils.REDIRECT_URI),
            URLQueryItem(name: APIUtils.DURATION_KEY, value: APIUtils.DURATION),
            URLQueryItem(name: APIUtils.SCOPE_KEY, value: APIUtils.SCOPE)
        ]
        
        // Get the final URL with the query parameters
        return components.url!
    }
    
    func startRedditLogin(contextProvider: AuthPresentationContextProvider, onCallback: @escaping (URL?, Error?) -> Void) {
        authenticationSession = ASWebAuthenticationSession(
            url: getLoginURL(),
            callbackURLScheme: "infinity"
        ) { callbackURL, error in
            onCallback(callbackURL, error)
        }
        
        authenticationSession?.presentationContextProvider = contextProvider
        authenticationSession?.prefersEphemeralWebBrowserSession = true
        authenticationSession?.start()
    }
    
    func extractCode(callbackURL: URL) -> String? {
        let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)
        return components?.queryItems?
            .first(where: { $0.name == "code" })?
            .value
    }
    
    func setUpAccount(code: String) async throws {
        var params: [String: String] = [:]
        params[APIUtils.GRANT_TYPE_KEY] = "authorization_code"
        params["code"] = code
        params[APIUtils.REDIRECT_URI_KEY] = APIUtils.REDIRECT_URI
        
        var headers: HTTPHeaders = [:]
        let credentials = "\(APIUtils.CLIENT_ID):"
        
        guard let encodedData = credentials.data(using: .utf8) else {
            throw AccountError.internalError
        }
        
        let base64Credentials = encodedData.base64EncodedString()
        let auth = "Basic \(base64Credentials)"
        headers[APIUtils.AUTHORIZATION_KEY] = auth
        
        let accessTokenResponse: String
        do {
            accessTokenResponse = try await sessionForLogin.request(
                RedditAPI.getAccessToken(queries: nil, headers: headers, params: params)
            )
                .validate()
                .serializingString(automaticallyCancelling: true)
                .value
        } catch {
            throw AccountError.failedToGetAccessTokenNetworkError
        }
        
        guard !accessTokenResponse.isEmpty else {
            throw AccountError.failedToGetAccessTokenEmptyResponse
        }
        
        guard let data = accessTokenResponse.data(using: .utf8) else {
            throw AccountError.failedToGetAccessToken
        }
        
        guard let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            throw AccountError.failedToParseAccessToken
        }
        
        guard let accessToken = responseJSON["access_token"] as? String,
           let refreshToken = responseJSON["refresh_token"] as? String else {
            printInDebugOnly("Error: Tokens not found in response")
            throw AccountError.noAccessTokenInResponse
        }
        
        printInDebugOnly("Access Token: \(accessToken)")
        printInDebugOnly("Refresh Token: \(refreshToken)")
        
        try await getAccountInfo(accessToken: accessToken, refreshToken: refreshToken, code: code)
    }
    
    private func getAccountInfo(accessToken: String, refreshToken: String, code: String) async throws {
        let response: String
        do {
            response = try await sessionForLogin.request(RedditOAuthAPI.getMyInfo(headers: APIUtils.getOAuthHeader(accessToken: accessToken)))
                .validate()
                .serializingString(automaticallyCancelling: true)
                .value
        } catch {
            printInDebugOnly("Error: \(error.localizedDescription)")
            throw AccountError.failedToGetMyInfoNetworkError
        }
        
        guard !response.isEmpty else {
            printInDebugOnly("Error: Empty response from Reddit")
            throw AccountError.failedToGetMyInfoEmptyResponse
        }
        
        guard let myInfo = response.data(using: .utf8) else {
            throw AccountError.failedToGetMyInfo
        }
        
        guard let jsonResponse = try? JSON(data: myInfo) else {
            throw AccountError.failedToParseAccountInfo
        }
        
        let name = jsonResponse[JSONUtils.NAME_KEY].stringValue
        let profileImageUrl = jsonResponse[JSONUtils.ICON_IMG_KEY].stringValue
        let bannerImageUrl = jsonResponse[JSONUtils.SUBREDDIT_KEY][JSONUtils.BANNER_IMG_KEY].string
        let karma = jsonResponse[JSONUtils.TOTAL_KARMA_KEY].intValue
        let isMod = jsonResponse[JSONUtils.IS_MOD_KEY].boolValue
        let createdUTC = jsonResponse[JSONUtils.CREATED_UTC_KEY].doubleValue
        
        let account = Account(
            username: name,
            isCurrentUser: true,
            profileImageUrl: profileImageUrl,
            bannerImageUrl: bannerImageUrl,
            karma: karma,
            isMod: isMod,
            code: code,
            createdUTC: createdUTC
        )
        
        do {
            try accountDao.markAllAccountsNonCurrent()
            try accountDao.insert(account)
            try RedditAccessTokenKeychainManager.shared.saveAccessToken(accountName: name, accessToken: accessToken)
            try RedditAccessTokenKeychainManager.shared.saveRefreshToken(accountName: name, refreshToken: refreshToken)
        } catch {
            printInDebugOnly("Error: Failed to insert account - \(error.localizedDescription)")
            throw AccountError.failedToSaveAccountInfo
        }
    }
    
    func getRedditSettings() async throws -> RedditSettings {
        let data: Data
        do {
            data = try await session.request(RedditOAuthAPI.getRedditSettings)
                .validate()
                .serializingData(automaticallyCancelling: true)
                .value
        } catch {
            printInDebugOnly("Error: \(error.localizedDescription)")
            throw AccountError.failedToGetRedditSettings
        }
        
        let json = JSON(data)
        if let error = json.error {
            throw APIError.jsonDecodingError(error.localizedDescription)
        }
        
        return RedditSettings(fromJson: json)
    }
}
