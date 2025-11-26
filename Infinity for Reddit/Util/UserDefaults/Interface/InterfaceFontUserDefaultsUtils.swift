//
//  InterfaceFontUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-12.
//

import Foundation

class InterfaceFontUserDefaultsUtils {
    static let fontFamilies = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
    static let fontFamiliesText = fontFamilies.map {
        FontFamily(rawValue: $0)?.displayName ?? ""
    }
    static let fontScales = [0, 1, 2, 3, 4]
    static let fontScalesText = fontScales.map {
        FontScale(rawValue: $0)?.displayName ?? ""
    }
    static let contentFontSizes = [0, 1, 2, 3, 4, 5]
    static let contentFontSizesText = contentFontSizes.map {
        ContentFontScale(rawValue: $0)?.displayName ?? ""
    }

    static let fontFamilyKey = "font_family"
    static let fontScaleKey = "font_scale"
    static let postTitleFontFamilyKey = "post_title_font_family"
    static let postTitleFontScaleKey = "post_title_font_scale"
    static let contentFontFamilyKey = "content_font_family"
    static let contentFontScaleKey = "content_font_scale"

    static let customFontPostScriptNameKey = "custom_font_postscript_name"
    static var customFontPostScriptName: String? {
        return UserDefaults.interfaceFont.string(forKey: customFontPostScriptNameKey)
    }

    static let customFontFileNameKey = "custom_font_filename"
    static var customFontFileName: String? {
        return UserDefaults.interfaceFont.string(forKey: customFontFileNameKey)
    }

    static let customFontDisplayNameKey = "custom_font_display_name"
    static var customFontDisplayName: String? {
        return UserDefaults.interfaceFont.string(forKey: customFontDisplayNameKey)
    }

    static var hasCustomFont: Bool {
        return customFontPostScriptName != nil
    }
}
