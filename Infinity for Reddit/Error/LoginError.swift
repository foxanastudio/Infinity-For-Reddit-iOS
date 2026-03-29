//
//  LoginError.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-03-29.
//

import Foundation

enum LoginError: LocalizedError {
    case failedToLogin
    case failedToLoginNoCodeInCallbackURL
    case failedToLoginNoNSErrorCode
    case failedToLoginCanceled
    case failedToLoginUnknownError
    
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
    
    var errorDescription: String? {
        switch self {
        case .failedToLogin:
            return "Failed to log in."
        case .failedToLoginNoCodeInCallbackURL:
            return "Failed to log in. No code in callback URL."
        case .failedToLoginNoNSErrorCode:
            return "Failed to log in. No NSError code received."
        case .failedToLoginCanceled:
            return "Failed to log in. Canceled."
        case .failedToLoginUnknownError:
            return "Failed to log in. Unknown error."
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
        }
    }
}
