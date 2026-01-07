//
//  APIUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-01.
//

import Alamofire

class APIUtils {
    // Base URIs
    static let OAUTH_URL = "https://www.reddit.com/api/v1/authorize.compact"
    static let OAUTH_API_BASE_URI = "https://oauth.reddit.com"
    static let API_BASE_URI = "https://www.reddit.com"
    static let API_UPLOAD_MEDIA_URI = "https://reddit-uploaded-media.s3-accelerate.amazonaws.com"
    static let API_UPLOAD_VIDEO_URI = "https://reddit-uploaded-video.s3-accelerate.amazonaws.com"
    static let REDGIFS_API_BASE_URI = "https://api.redgifs.com"
    static let IMGUR_API_BASE_URI = "https://api.imgur.com/3/"
    static let STREAMABLE_API_BASE_URI = "https://api.streamable.com"
    static let SERVER_API_BASE_URI = "http://127.0.0.1"
    
    // Keys and Constants
    static let CLIENT_ID_KEY = "client_id"
    static let CLIENT_SECRET_KEY = "client_secret"
    static let CLIENT_ID = "NOe2iKrPPzwscA"
    static let IMGUR_CLIENT_ID = "Client-ID cc671794e0ab397"
    static let REDGIFS_CLIENT_ID = "1828d0bcc93-15ac-bde6-0005-d2ecbe8daab3"
    static let REDGIFS_CLIENT_SECRET = "TJBlw7jRXW65NAGgFBtgZHu97WlzRXHYybK81sZ9dLM="
    static let GIPHY_GIF_API_KEY = ""
    static let RESPONSE_TYPE_KEY = "response_type"
    static let RESPONSE_TYPE = "code"
    static let STATE_KEY = "state"
    static let STATE = "23ro8xlxvzp4asqd"
    static let REDIRECT_URI_KEY = "redirect_uri"
    static let REDIRECT_URI = "infinity://localhost"
    static let DURATION_KEY = "duration"
    static let DURATION = "permanent"
    static let SCOPE_KEY = "scope"
    static let SCOPE = "identity edit flair history modconfig modflair modlog modposts modwiki mysubreddits privatemessages read report save submit subscribe vote wikiedit wikiread creddits modcontributors modmail modothers livemanage account modself"
    static let ACCESS_TOKEN_KEY = "access_token"
    
    static let AUTHORIZATION_KEY = "Authorization"
    static let AUTHORIZATION_BASE = "bearer "
    static let USER_AGENT_KEY = "User-Agent"
    static let USER_AGENT = "ios:com.foxanastudio.infinity:1.0.0 (by /u/Hostilenemy)"
    static let USERNAME_KEY = "username"
    
    static let GRANT_TYPE_KEY = "grant_type"
    static let GRANT_TYPE_REFRESH_TOKEN = "refresh_token"
    static let GRANT_TYPE_CLIENT_CREDENTIALS = "client_credentials"
    static let REFRESH_TOKEN_KEY = "refresh_token"
    
    // Utility Methods
    static func getHttpBasicAuthHeader() -> HTTPHeaders {
        let credentials = "\(CLIENT_ID):"
        guard let encodedCredentials = credentials.data(using: .utf8)?.base64EncodedString() else {
            return [:]
        }
        return [AUTHORIZATION_KEY: "Basic \(encodedCredentials)"]
    }
    
    static func getOAuthHeader(accessToken: String) -> HTTPHeaders {
        return [
            AUTHORIZATION_KEY: "\(AUTHORIZATION_BASE)\(accessToken)",
            USER_AGENT_KEY: USER_AGENT
        ]
    }
    
    static func getServerHeader(serverAccessToken: String, accountName: String, anonymous: Bool) -> [String: String] {
        if accountName == "ANONYMOUS_ACCOUNT" || anonymous {
            return [:]
        }
        return [
            AUTHORIZATION_KEY: "\(AUTHORIZATION_BASE)\(serverAccessToken)",
            USERNAME_KEY: accountName
        ]
    }
    
    static func getRedgifsOAuthHeader(redgifsAccessToken: String) -> HTTPHeaders {
        return [
            AUTHORIZATION_KEY: "\(AUTHORIZATION_BASE)\(redgifsAccessToken)"
        ]
    }
}
