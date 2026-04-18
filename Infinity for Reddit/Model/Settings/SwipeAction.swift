//
//  SwipeAction.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-12.
//

import SwiftUI

enum SwipeAction: Int {
    case none = 0
    case upvote = 1
    case downvote = 2
    
    var title: String {
        switch self {
        case .none:
            return "Disabled"
        case .upvote:
            return "Upvote"
        case .downvote:
            return "Downvote"
        }
    }
    
    var icon: String {
        switch self {
        case .none:
            return ""
        case .upvote:
            return "arrowshape.up"
        case .downvote:
            return "arrowshape.down"
        }
    }
    
    func getTint(customThemeViewModel: CustomThemeViewModel) -> Color {
        switch self {
        case .none:
            return .clear
        case .upvote:
            return Color(hex: customThemeViewModel.currentCustomTheme.upvoted)
        case .downvote:
            return Color(hex: customThemeViewModel.currentCustomTheme.downvoted)
        }
    }
}
