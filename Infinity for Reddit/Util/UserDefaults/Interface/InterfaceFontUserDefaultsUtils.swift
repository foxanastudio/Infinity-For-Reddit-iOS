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
    static let fontSizes = [0, 1, 2, 3, 4]
    static let fontSizesText = fontSizes.map {
        InterfaceFontSize(rawValue: $0)?.displayName ?? ""
    }
    static let contentFontSizes = [0, 1, 2, 3, 4, 5]
    static let contentFontSizesText = contentFontSizes.map {
        InterfaceContentFontSize(rawValue: $0)?.displayName ?? ""
    }

    static let fontFamilyKey = "font_family"
    static let fontSizeKey = "font_size"
    static let postTitleFontFamilyKey = "post_title_font_family"
    static let postTitleFontSizeKey = "post_title_font_size"
    static let contentFontFamilyKey = "content_font_family"
    static let contentFontSizeKey = "content_font_size"

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
