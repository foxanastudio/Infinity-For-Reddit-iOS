//
// FontInterfaceView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-05
//

import SwiftUI
import Swinject
import GRDB

struct FontInterfaceView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @AppStorage(InterfaceFontUserDefaultsUtils.fontFamilyKey, store: .interfaceFont) private var fontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.fontSizeKey, store: .interfaceFont) private var fontSize: Int = 2
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontFamilyKey, store: .interfaceFont) private var postTitleFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontSizeKey, store: .interfaceFont) private var postTitleFontSize: Int = 2
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontSizeKey, store: .interfaceFont) private var contentFontSize: Int = 2
    
    
    var body: some View {
        List{
            PreferenceEntry(
                title: "Font Preview"
            ) {
                navigationManager.append(FontSettingsViewNavigation.fontPreview)
            }
            .listPlainItemNoInsets()
            
            CustomListSection("Font") {
                BarebonePickerPreference(
                    selected: $fontFamily,
                    items: InterfaceFontUserDefaultsUtils.fontFamilies,
                    title: "Font Family"
                ) { family in
                    InterfaceFontUserDefaultsUtils.fontFamiliesText[family]
                }
                .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $fontSize,
                    items: InterfaceFontUserDefaultsUtils.fontSizes,
                    title: "Font Size"
                ) { size in
                    InterfaceFontUserDefaultsUtils.fontSizesText[size]
                }
                .listPlainItemNoInsets()
            }
            
            CustomListSection("Title") {
                BarebonePickerPreference(
                    selected: $postTitleFontFamily,
                    items: InterfaceFontUserDefaultsUtils.fontFamilies,
                    title: "Title Font Family"
                ) { family in
                    InterfaceFontUserDefaultsUtils.fontFamiliesText[family]
                }
                .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $postTitleFontSize,
                    items: InterfaceFontUserDefaultsUtils.fontSizes,
                    title: "Title Font Size"
                ) { size in
                    InterfaceFontUserDefaultsUtils.fontSizesText[size]
                }
                .listPlainItemNoInsets()
            }
            
            CustomListSection("Content") {
                BarebonePickerPreference(
                    selected: $contentFontFamily,
                    items: InterfaceFontUserDefaultsUtils.fontFamilies,
                    title: "Content Font Family"
                ) { family in
                    InterfaceFontUserDefaultsUtils.fontFamiliesText[family]
                }
                .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $contentFontSize,
                    items: InterfaceFontUserDefaultsUtils.contentFontSizes,
                    title: "Content Font Size"
                ) { size in
                    InterfaceFontUserDefaultsUtils.contentFontSizesText[size]
                }
                .listPlainItemNoInsets()
            }
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Font")
    }
}
