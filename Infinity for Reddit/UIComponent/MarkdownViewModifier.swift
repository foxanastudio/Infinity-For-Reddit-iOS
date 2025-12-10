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
            }.code {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor))
                BackgroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor).mix(with: Color(hex: themeViewModel.currentCustomTheme.backgroundColor), by: 0.8))
            }.codeBlock { codeBlockConfiguration in
                codeBlockConfiguration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor))
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(
                            Color(hex: themeViewModel.currentCustomTheme.primaryTextColor).mix(with: Color(hex: themeViewModel.currentCustomTheme.backgroundColor), by: 0.8)
                        )
                    )
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
            }.code {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.postContentColor))
                BackgroundColor(Color(hex: themeViewModel.currentCustomTheme.postContentColor).mix(with: Color(hex: themeViewModel.currentCustomTheme.backgroundColor), by: 0.8))
            }.codeBlock { codeBlockConfiguration in
                codeBlockConfiguration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.postContentColor))
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(
                            Color(hex: themeViewModel.currentCustomTheme.postContentColor).mix(with: Color(hex: themeViewModel.currentCustomTheme.backgroundColor), by: 0.8)
                        )
                    )
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
            }.code {
                ForegroundColor(Color(hex: themeViewModel.currentCustomTheme.commentColor))
                BackgroundColor(Color(hex: themeViewModel.currentCustomTheme.commentColor).mix(with: Color(hex: themeViewModel.currentCustomTheme.backgroundColor), by: 0.8))
            }.codeBlock { codeBlockConfiguration in
                codeBlockConfiguration.label
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.commentColor))
                    .background(
                        RoundedRectangle(cornerRadius: 12).fill(
                            Color(hex: themeViewModel.currentCustomTheme.commentColor).mix(with: Color(hex: themeViewModel.currentCustomTheme.backgroundColor), by: 0.8)
                        )
                    )
            })
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
