//
// AppDeepLink.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-18

import Foundation

struct AppDeepLink {
    static let scheme = "infinity"
    static let inboxHost = "inbox"
    static let linkHost = "linkToView"
    static let accountNameKey = "accountName"
    static let fullnameKey = "fullname"
    static let contextKey = "context"
    static let kindKey = "kind"
    static let viewMessageKey = "viewMessage"
    static let urlKey = "url"
    
    static func getInboxURL(account: String, viewMessage: Bool, fullname: String?) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = inboxHost
        var items: [URLQueryItem] = [
            URLQueryItem(name: accountNameKey, value: account),
            URLQueryItem(name: viewMessageKey, value: viewMessage ? "1" : "0")
        ]
        if let fullname { items.append(URLQueryItem(name: fullnameKey, value: fullname)) }
        components.queryItems = items
        return components.url
    }
    
    static func getContextURL(context: String, account: String, fullname: String?) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = linkHost
        var items: [URLQueryItem] = [
            URLQueryItem(name: accountNameKey, value: account),
            URLQueryItem(name: contextKey, value: context)
        ]
        if let fullname {
            items.append(URLQueryItem(name: fullnameKey, value: fullname))
        }
        components.queryItems = items
        return components.url
    }
    
    static func getAppDeepLinkType(_ url: URL) -> AppDeepLinkType? {
        guard url.scheme == scheme else {
            return .url(url)
        }
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .url(url)
        }
        
        func query(_ name: String) -> String? {
            urlComponents.queryItems?.first(where: { $0.name == name })?.value
        }
        
        switch url.host {
        case inboxHost:
            guard let account = query(accountNameKey) else {
                break
            }
            return .inbox(
                account: account,
                viewMessage: query(viewMessageKey) == "1",
                fullname: query(fullnameKey)
            )
        case linkHost:
            guard let account = query(accountNameKey),
                  let context = query(contextKey) else {
                break
            }
            return .context(
                account: account,
                context: context,
                fullname: query(fullnameKey)
            )
        default:
            return .url(url)
        }
        return nil
    }
}

enum AppDeepLinkType {
    case url(URL)
    case inbox(account: String, viewMessage: Bool, fullname: String?)
    case context(account: String, context: String, fullname: String?)
}
