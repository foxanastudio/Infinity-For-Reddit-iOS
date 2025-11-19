//
//  FontFamily.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-15.
//

import Foundation
import SwiftUI
import MarkdownUI

enum FontFamily: Int {
    case system = 0
    case balsamiqSans = 1

    var displayName: String {
        switch self {
        case .system:
            return "Default"
        case .balsamiqSans:
            return "Balsamiq Sans"
        }
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size)
        case .balsamiqSans:
            return .custom("BalsamiqSans-Regular", size: size)
        }
    }

    var markdownFontFamily: MarkdownUI.FontProperties.Family {
        switch self {
        case .system:
            return .system()
        case .balsamiqSans:
            return .custom("BalsamiqSans-Regular")
        }
    }
}
