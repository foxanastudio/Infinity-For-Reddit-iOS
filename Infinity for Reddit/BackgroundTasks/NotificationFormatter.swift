//
// NotificationFormatter.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-11
        
import Foundation

struct NotificationFormatter {
    static func titleSubtitle(for inbox: Inbox) -> (title: String, subtitle: String) {
        let subject = (inbox.subject ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let fallback = subject.isEmpty ? "New message" : subject
        
        switch inbox.messageKind {
        case .t1, .t3:
            let title = (inbox.author?.isEmpty == false) ? inbox.author! : "New comment"
            let subtitle = subject.isEmpty ? "New activity" : subject.capitalizedFirst
            return (title, subtitle)
        case .t2:
            return ((inbox.linkTitle?.isEmpty == false) ? inbox.linkTitle! : fallback, "Account")
        case .t4:
            return ((inbox.linkTitle?.isEmpty == false) ? inbox.linkTitle! : fallback, "New Message")
        case .t5:
            return ((inbox.linkTitle?.isEmpty == false) ? inbox.linkTitle! : fallback, "Subreddit")
        case .t6, .unknown:
            return ((inbox.linkTitle?.isEmpty == false) ? inbox.linkTitle! : fallback, "Award")
        }
    }
}

private extension String {
    var capitalizedFirst: String { guard let f = first else { return self }; return f.uppercased() + dropFirst() }
}
