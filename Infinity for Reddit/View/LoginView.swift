//
//  LoginView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import Foundation
import SwiftUI
import Swinject
import Alamofire
import SwiftyJSON
import GRDB

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject private var loginViewModel: LoginViewModel
    
    private let session: Session
    private let dbPool: DatabasePool
    private let operationQueue: OperationQueue
    
    enum LoginError: LocalizedError {
        case failedToGetAccessToken
        case failedToGetAccessTokenNetworkError
        case noAccessTokenInResponse
        case failedToParseAccessToken
        case failedToGetMyInfo
        case failedToGetMyInfoNetworkError
        case failedToSaveAccountInfo
        case failedToParseAccountInfo
        
        var errorDescription: String? {
            switch self {
            case .failedToGetAccessToken:
                return "Failed to get access token"
            case .failedToGetAccessTokenNetworkError:
                return "Failed to get access token: network error."
            case .noAccessTokenInResponse:
                return "Failed to get access token."
            case .failedToParseAccessToken:
                return "Failed to parse access token."
            case .failedToGetMyInfo:
                return "Failed to get my info."
            case .failedToGetMyInfoNetworkError:
                return "Failed to get my info: network error."
            case .failedToSaveAccountInfo:
                return "Failed to save account info."
            case .failedToParseAccountInfo:
                return "Failed to parse account info."
            }
        }
    }
    
    init() {
        // Resolve the session ASAP and store it in a property
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool")
        }
        guard let resolvedOperationQueue = DependencyManager.shared.container.resolve(OperationQueue.self) else {
            fatalError("Failed to resolve OperationQueue")
        }
        self.session = Session(configuration: URLSessionConfiguration.af.default)
        self.dbPool = resolvedDBPool
        self.operationQueue = resolvedOperationQueue
        
        self._loginViewModel = StateObject(wrappedValue: LoginViewModel())
    }
    
    
    func getLoginURL() -> URL {
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
    
    var body: some View {
        WebView(url: getLoginURL()) { url in
            if url.contains("&code=") || url.contains("?code=") {
                print("login ok")
                
                if let urlComponents = URLComponents(string: url),
                   let queryItems = urlComponents.queryItems,
                   let state = queryItems.first(where: { $0.name == "state" })?.value {
                    
                    if state == APIUtils.STATE {
                        if let authCode = queryItems.first(where: { $0.name == "code" })?.value {
                            var params: [String: String] = [:]
                            params[APIUtils.GRANT_TYPE_KEY] = "authorization_code"
                            params["code"] = authCode
                            params[APIUtils.REDIRECT_URI_KEY] = APIUtils.REDIRECT_URI
                            
                            var headers: HTTPHeaders = [:]
                            let credentials = "\(APIUtils.CLIENT_ID):"
                            if let encodedData = credentials.data(using: .utf8) {
                                let base64Credentials = encodedData.base64EncodedString()
                                let auth = "Basic \(base64Credentials)"
                                headers[APIUtils.AUTHORIZATION_KEY] = auth
                                
                                session.request(RedditAPI.getAccessToken(queries: nil, headers: headers, params: params))
                                    .validate()
                                    .responseString { response in
                                        switch response.result {
                                        case .success(let accessTokenResponse):
                                            guard !accessTokenResponse.isEmpty else {
                                                loginViewModel.error = LoginError.failedToGetAccessToken
                                                return
                                            }
                                            if let data = accessTokenResponse.data(using: .utf8) {
                                                do {
                                                    if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                        if let accessToken = responseJSON["access_token"] as? String,
                                                           let refreshToken = responseJSON["refresh_token"] as? String {
                                                            print("Access Token: \(accessToken)")
                                                            print("Refresh Token: \(refreshToken)")
                                                            
                                                            session.request(RedditOAuthAPI.getMyInfo(headers: APIUtils.getOAuthHeader(accessToken: accessToken)))
                                                                .validate()
                                                                .responseString { response in
                                                                    switch response.result {
                                                                    case .success(let myInfoResponse):
                                                                        guard !myInfoResponse.isEmpty else {
                                                                            print("Error: Empty response from Reddit")
                                                                            loginViewModel.error = LoginError.failedToGetMyInfo
                                                                            return
                                                                        }
                                                                        if let myInfo = myInfoResponse.data(using: .utf8) {
                                                                            operationQueue.addOperation {
                                                                                do {
                                                                                    let jsonResponse = try JSON(data: myInfo)
                                                                                    
                                                                                    // Parse the response
                                                                                    let name = jsonResponse[JSONUtils.NAME_KEY].stringValue
                                                                                    let profileImageUrl = jsonResponse[JSONUtils.ICON_IMG_KEY].stringValue
                                                                                    
                                                                                    var bannerImageUrl: String? = nil
                                                                                    if let subredditData = jsonResponse[JSONUtils.SUBREDDIT_KEY].dictionary {
                                                                                        bannerImageUrl = subredditData[JSONUtils.BANNER_IMG_KEY]?.stringValue
                                                                                    }
                                                                                    
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
                                                                                        accessToken: accessToken,
                                                                                        refreshToken: refreshToken,
                                                                                        code: authCode,
                                                                                        createdUTC: createdUTC
                                                                                    )
                                                                                    
                                                                                    let accountDao = AccountDao(dbPool: dbPool)
                                                                                    do {
                                                                                        try accountDao.markAllAccountsNonCurrent()
                                                                                        try accountDao.insert(account)
                                                                                        
                                                                                        OperationQueue.main.addOperation {
                                                                                            AccountViewModel.shared.switchAccount(newAccount: account)
                                                                                            dismiss()
                                                                                        }
                                                                                    } catch {
                                                                                        print("Error: Failed to insert account - \(error.localizedDescription)")
                                                                                        loginViewModel.error = LoginError.failedToSaveAccountInfo
                                                                                    }
                                                                                } catch {
                                                                                    print("Error: Failed to parse account JSON - \(error.localizedDescription)")
                                                                                    loginViewModel.error = LoginError.failedToParseAccountInfo
                                                                                }
                                                                            }
                                                                        }
                                                                        break
                                                                    case .failure(let error):
                                                                        print("Error: \(error.localizedDescription)")
                                                                        loginViewModel.error = LoginError.failedToGetMyInfoNetworkError
                                                                        break
                                                                    }
                                                                }
                                                        } else {
                                                            print("Error: Tokens not found in response")
                                                            loginViewModel.error = LoginError.noAccessTokenInResponse
                                                        }
                                                    }
                                                } catch {
                                                    print("Error: Failed to parse JSON - \(error.localizedDescription)")
                                                    loginViewModel.error = LoginError.failedToParseAccessToken
                                                }
                                            }
                                            break
                                        case .failure(let error):
                                            print("Error: \(error.localizedDescription)")
                                            loginViewModel.error = LoginError.failedToGetAccessTokenNetworkError
                                            break
                                        }
                                    }
                            }
                        }
                    }
                }
            } else if url.contains("error=access_denied") {
                print("login failed")
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Login")
        .showErrorUsingSnackbar(loginViewModel.$error)
    }
}
