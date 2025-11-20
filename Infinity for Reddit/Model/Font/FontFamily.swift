//
//  FontFamily.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-15.
//

import Foundation
import SwiftUI
import MarkdownUI

enum FontFamily: Int {
    case system = 0
    case atkinsonHyperlegibleBold = 1
    case atkinsonHyperlegibleRegular = 2
    case balsamiqSansBold = 3
    case balsamiqSansRegular = 4
    case harmoniaSansBold = 5
    case harmoniaSansRegular = 6
    case interBold = 7
    case interRegular = 8
    case manropeBold = 9
    case manropeRegular = 10
    case notoSansBold = 11
    case notoSansRegular = 12
    case robotoCondensedBold = 13
    case robotoCondensedRegular = 14
    case srirachaRegular = 15
    case customFontFamily = 16

    var displayName: String {
        switch self {
        case .system:
            return "Default"
        case .atkinsonHyperlegibleBold:
            return "Atkinson Hyperlegible Bold"
        case .atkinsonHyperlegibleRegular:
            return "Atkinson Hyperlegible Regular"
        case .balsamiqSansBold:
            return "Balsamiq Sans Bold"
        case .balsamiqSansRegular:
            return "Balsamiq Sans Regular"
        case .harmoniaSansBold:
            return "Harmonia Sans Bold"
        case .harmoniaSansRegular:
            return "Harmonia Sans Regular"
        case .interBold:
            return "Inter Bold"
        case .interRegular:
            return "Inter Regular"
        case .manropeBold:
            return "Manrope Bold"
        case .manropeRegular:
            return "Manrope Regular"
        case .notoSansBold:
            return "Noto Sans Bold"
        case .notoSansRegular:
            return "Noto Sans Regular"
        case .robotoCondensedBold:
            return "Roboto Condensed Bold"
        case .robotoCondensedRegular:
            return "Roboto Condensed Regular"
        case .srirachaRegular:
            return "Sriracha"
        case .customFontFamily:
            return "Custom Font Family"
        }
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size)
        case .atkinsonHyperlegibleBold:
            return .custom("AtkinsonHyperlegible-Bold", size: size)
        case .atkinsonHyperlegibleRegular:
            return .custom("AtkinsonHyperlegible-Regular", size: size)
        case .balsamiqSansBold:
            return .custom("BalsamiqSans-Bold", size: size)
        case .balsamiqSansRegular:
            return .custom("BalsamiqSans-Regular", size: size)
        case .harmoniaSansBold:
            return .custom("HarmoniaSansW01-Bold", size: size)
        case .harmoniaSansRegular:
            return .custom("HarmoniaSansW01-Regular", size: size)
        case .interBold:
            return .custom("Inter18pt-Bold", size: size)
        case .interRegular:
            return .custom("Inter18pt-Regular", size: size)
        case .manropeBold:
            return .custom("Manrope-Bold", size: size)
        case .manropeRegular:
            return .custom("Manrope-Regular", size: size)
        case .notoSansBold:
            return .custom("NotoSans-Bold", size: size)
        case .notoSansRegular:
            return .custom("NotoSans-Regular", size: size)
        case .robotoCondensedBold:
            return .custom("RobotoCondensed-Bold", size: size)
        case .robotoCondensedRegular:
            return .custom("RobotoCondensed-Regular", size: size)
        case .srirachaRegular:
            return .custom("Sriracha-Regular", size: size)
        case .customFontFamily:
            if let postScriptName = InterfaceFontUserDefaultsUtils.customFontPostScriptName {
                return .custom(postScriptName, size: size)
            }
            return .system(size: size)
        }
    }

    var markdownFontFamily: MarkdownUI.FontProperties.Family {
        switch self {
        case .system:
            return .system()
        case .atkinsonHyperlegibleBold:
            return .custom("AtkinsonHyperlegible-Bold")
        case .atkinsonHyperlegibleRegular:
            return .custom("AtkinsonHyperlegible-Regular")
        case .balsamiqSansBold:
            return .custom("BalsamiqSans-Bold")
        case .balsamiqSansRegular:
            return .custom("BalsamiqSans-Regular")
        case .harmoniaSansBold:
            return .custom("HarmoniaSansW01-Bold")
        case .harmoniaSansRegular:
            return .custom("HarmoniaSansW01-Regular")
        case .interBold:
            return .custom("Inter18pt-Bold")
        case .interRegular:
            return .custom("Inter18pt-Regular")
        case .manropeBold:
            return .custom("Manrope-Bold")
        case .manropeRegular:
            return .custom("Manrope-Regular")
        case .notoSansBold:
            return .custom("NotoSans-Bold")
        case .notoSansRegular:
            return .custom("NotoSans-Regular")
        case .robotoCondensedBold:
            return .custom("RobotoCondensed-Bold")
        case .robotoCondensedRegular:
            return .custom("RobotoCondensed-Regular")
        case .srirachaRegular:
            return .custom("Sriracha-Regular")
        case .customFontFamily:
            if let postScriptName = InterfaceFontUserDefaultsUtils.customFontPostScriptName {
                return .custom(postScriptName)
            }
            return .system()
        }
    }
}
