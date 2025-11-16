//
//  CustomFontModifiers.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-15.
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    @AppStorage(InterfaceFontUserDefaultsUtils.fontFamilyKey, store: .interfaceFont) private var fontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.fontSizeKey, store: .interfaceFont) private var fontSize: Int = 2

    func body(content: Content) -> some View {
        content.font(font)
    }

    private var font: Font {
        let family = FontFamily(rawValue: fontFamily) ?? .system
        let size = InterfaceFontSize(rawValue: fontSize) ?? .normal
        return family.font(size: size.size)
    }
}

struct CustomPostTitleFontModifier: ViewModifier {
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontFamilyKey, store: .interfaceFont) private var postTitleFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontSizeKey, store: .interfaceFont) private var postTitleFontSize: Int = 2

    func body(content: Content) -> some View {
        content.font(font)
    }

    private var font: Font {
        let family = FontFamily(rawValue: postTitleFontFamily) ?? .system
        let size = InterfaceFontSize(rawValue: postTitleFontSize) ?? .normal
        return family.font(size: size.postTitleSize)
    }
}

struct CustomContentFontModifier: ViewModifier {
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontSizeKey, store: .interfaceFont) private var contentFontSize: Int = 2

    func body(content: Content) -> some View {
        content.font(font)
    }

    private var font: Font {
        let family = FontFamily(rawValue: contentFontFamily) ?? .system
        let size = InterfaceContentFontSize(rawValue: contentFontSize) ?? .normal
        return family.font(size: size.contentSize)
    }
}
