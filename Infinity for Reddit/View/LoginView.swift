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

struct LoginView: View {
    @Environment(\.dependencyManager) var container: Container
    @Environment(\.dismiss) private var dismiss
    
    private let session: Session
    
    init() {
        // Resolve the session ASAP and store it in a property
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        self.session = resolvedSession
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
        NavigationStack {
            VStack {
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
                                        
                                        session.request(RedditAPI.getAccessToken(headers: headers, params: params))
                                            .validate()
                                            .responseString { response in
                                                switch response.result {
                                                case .success(let accessTokenResponse):
                                                    guard !accessTokenResponse.isEmpty else {
                                                        print("Error: Empty response body")
                                                        return
                                                    }
                                                    if let data = accessTokenResponse.data(using: .utf8) {
                                                        do {
                                                            if let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                                                // Step 3: Extract tokens
                                                                if let accessToken = responseJSON["access_token"] as? String,
                                                                   let refreshToken = responseJSON["refresh_token"] as? String {
                                                                    print("Access Token: \(accessToken)")
                                                                    print("Refresh Token: \(refreshToken)")
                                                                } else {
                                                                    print("Error: Tokens not found in response")
                                                                }
                                                            }
                                                        } catch {
                                                            print("Error: Failed to parse JSON - \(error.localizedDescription)")
                                                        }
                                                    }
                                                case .failure(let error):
                                                    print("Error: \(error.localizedDescription)")
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
            }
            .navigationBarTitle("Login", displayMode: .inline)
        }
    }
}
