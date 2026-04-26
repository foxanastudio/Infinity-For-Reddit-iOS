//
//  CustomFontModifiers.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-15.
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    @AppStorage(InterfaceFontUserDefaultsUtils.fontFamilyKey, store: .interfaceFont) private var fontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.fontScaleKey, store: .interfaceFont) private var fontScale: Int = 2

    let fontSize: AppFontSize
    
    func body(content: Content) -> some View {
        content.font(
            (FontFamily(rawValue: fontFamily) ?? .system)
                .font(
                    size: fontSize.scaledInterfaceFontSize(
                        FontScale(rawValue: fontScale),
                        uiFontMetrics: UIFontMetrics(forTextStyle: .body)
                    )
                )
        )
    }
}

struct CustomPostTitleFontModifier: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontFamilyKey, store: .interfaceFont) private var postTitleFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontScaleKey, store: .interfaceFont) private var postTitleFontScale: Int = 2

    let fontSize: AppFontSize
    
    func body(content: Content) -> some View {
        content.font(
            (FontFamily(rawValue: postTitleFontFamily) ?? .system)
                .font(
                    size: fontSize.scaledPostTitleFontSize(
                        FontScale(rawValue: postTitleFontScale),
                        uiFontMetrics: UIFontMetrics(forTextStyle: .body)
                    )
                )
        )
    }
}

struct CustomContentFontModifier: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontScaleKey, store: .interfaceFont) private var contentFontScale: Int = 2

    let fontSize: AppFontSize
    let respectFontMetrics: Bool
    
    func body(content: Content) -> some View {
        content.font(
            (FontFamily(rawValue: contentFontFamily) ?? .system)
                .font(
                    size: fontSize.scaledContentFontSize(
                        ContentFontScale(rawValue: contentFontScale),
                        uiFontMetrics: UIFontMetrics(forTextStyle: .body)
                    )
                )
        )
    }
}
