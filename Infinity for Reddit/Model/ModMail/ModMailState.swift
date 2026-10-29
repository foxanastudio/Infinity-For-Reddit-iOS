//
//  ModMailState.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-28.
//

import Foundation

enum ModMailState: String, CaseIterable {
    case all
    case new
    case inProgress = "inprogress"
    case archived
    case appeals
    case joinRequests = "join_requests"
    case filtered
    case highlighted
    case mod
    case notifications
    case admin
    
    var title: String {
        switch self {
        case .all:
            return "Mod Mail"
        case .new:
            return "New"
        case .inProgress:
            return "In Progress"
        case .archived:
            return "Archived"
        case .appeals:
            return "Appeals"
        case .joinRequests:
            return "Join Requests"
        case .filtered:
            return "Filtered"
        case .highlighted:
            return "Highlighted"
        case .mod:
            return "Mod Discussions"
        case .notifications:
            return "Notifications"
        case .admin:
            return "Admin"
        }
    }
    
    var icon: String {
        switch self {
        case .all:
            return "tray.full"
        case .new:
            return "envelope.badge"
        case .inProgress:
            return "pencil"
        case .archived:
            return "archivebox"
        case .appeals:
            return "hammer"
        case .joinRequests:
            return "plus.circle"
        case .filtered:
            return "exclamationmark.triangle"
        case .highlighted:
            return "star"
        case .mod:
            return "shield"
        case .notifications:
            return "bell"
        case .admin:
            return "person.badge.shield.checkmark"
        }
    }
    
    func contains(_ conversation: ModMailConversation) -> Bool {
        switch self {
        case .all:
            return conversation.isInternal != true
        case .new:
            return conversation.isInternal != true && conversation.isAuto != true && conversation.state == 0
        case .inProgress:
            return conversation.isInternal != true && conversation.state == 1
        case .highlighted:
            return conversation.isHighlighted == true
        case .mod:
            return conversation.isInternal == true
        case .archived, .appeals, .joinRequests, .filtered, .notifications, .admin:
            return false
        }
    }
}
