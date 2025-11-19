//
//  FontSize.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-15.
//

import Foundation

enum InterfaceFontSize: Int {
    case extraSmall = 0
    case small = 1
    case normal = 2
    case large = 3
    case extraLarge = 4

    var displayName: String {
        switch self {
        case .extraSmall:
            return "Extra Small"
        case .small:
            return "Small"
        case .normal:
            return "Normal"
        case .large:
            return "Large"
        case .extraLarge:
            return "Extra Large"
        }
    }

    var size: CGFloat {
        switch self {
        case .extraSmall: return 12  // Caption 1
        case .small: return 13       // Footnote
        case .normal: return 17      // Body
        case .large: return 20       // Title 3
        case .extraLarge: return 22  // Title 2
        }
    }

    var postTitleSize: CGFloat {
        switch self {
        case .extraSmall: return 18  // Compact layout default
        case .small: return 20       // Title 3
        case .normal: return 24      // Card layout default
        case .large: return 28       // Title 1
        case .extraLarge: return 34  // Large Title
        }
    }
}

enum InterfaceContentFontSize: Int {
    case extraSmall = 0
    case small = 1
    case normal = 2
    case large = 3
    case extraLarge = 4
    case enormouslyLarge = 5

    var displayName: String {
        switch self {
        case .extraSmall:
            return "Extra Small"
        case .small:
            return "Small"
        case .normal:
            return "Normal"
        case .large:
            return "Large"
        case .extraLarge:
            return "Extra Large"
        case .enormouslyLarge:
            return "Enormously Large"
        }
    }

    var contentSize: CGFloat {
        switch self {
        case .extraSmall: return 12      // Caption 1
        case .small: return 13           // Footnote
        case .normal: return 17          // Body
        case .large: return 20           // Title 3
        case .extraLarge: return 22      // Title 2
        case .enormouslyLarge: return 28 // Title 1
        }
    }
}
