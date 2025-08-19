//
// InboxDeepLink.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-18
        
import Foundation

extension Notification.Name {
    static let inboxDeepLink = Notification.Name("inboxDeepLink")
}

struct AppDeepLink {
    static let scheme = "infinity"
    
    static func wrap(_ external: URL) -> URL? {
        var c = URLComponents()
        c.scheme = scheme
        c.host   = "open"
        c.queryItems = [URLQueryItem(name: "url", value: external.absoluteString)]
        return c.url
    }
    
    static func toInbox(account: String, viewMessage: Bool, fullname: String?) -> URL? {
        var c = URLComponents()
        c.scheme = scheme
        c.host   = "inbox"
        var items: [URLQueryItem] = [
            URLQueryItem(name: "account",     value: account),
            URLQueryItem(name: "viewMessage", value: viewMessage ? "1" : "0")
        ]
        if let fullname { items.append(URLQueryItem(name: "fullname", value: fullname)) }
        c.queryItems = items
        return c.url
    }
    
    static func unwrap(_ deep: URL) -> URL? {
        guard deep.scheme == scheme, deep.host == "open" else { return nil }
        let items = URLComponents(url: deep, resolvingAgainstBaseURL: false)?.queryItems
        if let s = items?.first(where: { $0.name == "url" })?.value {
            return URL(string: s)
        }
        return nil
    }
    
    enum Parsed {
        case external(URL)
        case inbox(account: String, viewMessage: Bool, fullname: String?)
    }
    
    static func parse(_ url: URL) -> Parsed? {
        guard url.scheme == scheme else { return nil }
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
        
        switch url.host {
        case "open":
            if let s = comps.queryItems?.first(where: { $0.name == "url" })?.value,
               let u = URL(string: s) {
                return .external(u)
            }
        case "inbox":
            func query(_ name: String) -> String? {
                comps.queryItems?.first(where: { $0.name == name })?.value
            }
            let account = query("account") ?? ""
            let viewMsg = (query("viewMessage") == "1")
            let fullname = query("fullname")
            return .inbox(account: account, viewMessage: viewMsg, fullname: fullname)
        default:
            break
        }
        return nil
    }
}
