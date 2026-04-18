//
//  CommentTapAction.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-12.
//

enum CommentTapAction: Int {
    case toggleToolbar = 0
    case expandCollapseComment = 1
    
    var title: String {
        switch self {
        case .toggleToolbar:
            return "Toggle toolbar"
        case .expandCollapseComment:
            return "Expand/collapse comment"
        }
    }
}
