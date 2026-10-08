//
//  ModMailRecipientType.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-08.
//

import Foundation

enum ModMailRecipientType: Int, CaseIterable {
    case moderators
    case user
    case community
    
    var title: String {
        switch self {
        case .moderators:
            return "Moderators"
        case .user:
            return "User"
        case .community:
            return "Community"
        }
    }
}
