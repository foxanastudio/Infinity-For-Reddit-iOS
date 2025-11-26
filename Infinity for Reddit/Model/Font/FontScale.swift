//
//  FontScale.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-15.
//

import Foundation

enum FontScale: Int {
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
}

enum ContentFontScale: Int {
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
}
