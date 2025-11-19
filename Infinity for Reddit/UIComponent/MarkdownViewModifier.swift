//
//  MarkdownViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import SwiftUI
import MarkdownUI

struct MarkdownViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    @AppStorage(InterfaceFontUserDefaultsUtils.fontFamilyKey, store: .interfaceFont) private var fontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.fontSizeKey, store: .interfaceFont) private var fontSize: Int = 2

    func body(content: Content) -> some View {
        let family = FontFamily(rawValue: fontFamily) ?? .system
        let size = InterfaceFontSize(rawValue: fontSize) ?? .normal

        return content
            .markdownTextStyle {
                MarkdownUI.FontFamily(family.markdownFontFamily)
                FontSize(size.size)
            }
            .markdownTheme(.gitHub.link {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.colorAccent))
            }.text {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor))
            })
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct PostContentMarkdownViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontSizeKey, store: .interfaceFont) private var contentFontSize: Int = 2

    func body(content: Content) -> some View {
        let family = FontFamily(rawValue: contentFontFamily) ?? .system
        let size = InterfaceContentFontSize(rawValue: contentFontSize) ?? .normal

        return content
            .markdownTextStyle {
                MarkdownUI.FontFamily(family.markdownFontFamily)
                FontSize(size.contentSize)
            }
            .markdownTheme(.gitHub.link {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.colorAccent))
            }.text {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.postContentColor))
            })
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CommentMarkdownViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontSizeKey, store: .interfaceFont) private var contentFontSize: Int = 2

    func body(content: Content) -> some View {
        let family = FontFamily(rawValue: contentFontFamily) ?? .system
        let size = InterfaceContentFontSize(rawValue: contentFontSize) ?? .normal

        return content
            .markdownTextStyle {
                MarkdownUI.FontFamily(family.markdownFontFamily)
                FontSize(size.contentSize)
            }
            .markdownTheme(.gitHub.link {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.colorAccent))
            }.text {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.commentColor))
            })
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
