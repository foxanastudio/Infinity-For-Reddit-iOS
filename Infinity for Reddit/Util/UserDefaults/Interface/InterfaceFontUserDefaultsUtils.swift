//
//  InterfaceFontUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-12.
//

import Foundation

class InterfaceFontUserDefaultsUtils {
    static let fontFamilies = [0, 1]
    static let fontFamiliesText = fontFamilies.map { FontFamily(rawValue: $0)?.displayName ?? "" }
    static let fontSizes = [0, 1, 2, 3, 4]
    static let fontSizesText = fontSizes.map { InterfaceFontSize(rawValue: $0)?.displayName ?? "" }
    static let contentFontSizes = [0, 1, 2, 3, 4, 5]
    static let contentFontSizesText = contentFontSizes.map { InterfaceContentFontSize(rawValue: $0)?.displayName ?? "" }

    static let fontFamilyKey = "font_family"
    static let fontSizeKey = "font_size"
    static let postTitleFontFamilyKey = "post_title_font_family"
    static let postTitleFontSizeKey = "post_title_font_size"
    static let contentFontFamilyKey = "content_font_family"
    static let contentFontSizeKey = "content_font_size"
}
