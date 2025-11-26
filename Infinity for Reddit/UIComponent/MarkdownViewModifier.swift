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
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontScaleKey, store: .interfaceFont) private var contentFontScale: Int = 2
    
    let fontSize: AppFontSize
    
    func body(content: Content) -> some View {
        return content
            .markdownTextStyle {
                MarkdownUI.FontFamily((FontFamily(rawValue: contentFontFamily) ?? .system).markdownFontFamily)
                FontSize(fontSize.scaledContentFontSize(ContentFontScale(rawValue: contentFontScale)))
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
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontScaleKey, store: .interfaceFont) private var contentFontScale: Int = 2

    let fontSize: AppFontSize
    
    func body(content: Content) -> some View {
        return content
            .markdownTextStyle {
                MarkdownUI.FontFamily((FontFamily(rawValue: contentFontFamily) ?? .system).markdownFontFamily)
                FontSize(fontSize.scaledContentFontSize(ContentFontScale(rawValue: contentFontScale)))
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
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontScaleKey, store: .interfaceFont) private var contentFontScale: Int = 2

    let fontSize: AppFontSize
    
    func body(content: Content) -> some View {
        return content
            .markdownTextStyle {
                MarkdownUI.FontFamily((FontFamily(rawValue: contentFontFamily) ?? .system).markdownFontFamily)
                FontSize(fontSize.scaledContentFontSize(ContentFontScale(rawValue: contentFontScale)))
            }
            .markdownTheme(.gitHub.link {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.colorAccent))
            }.text {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.commentColor))
            })
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
