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
    
    @AppStorage(InterfaceFontUserDefaultsUtils.fontFamilyKey, store: .interfacePost) private var fontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.fontSizeKey, store: .interfacePost) private var fontSize: Int = 2
    @AppStorage(InterfaceFontUserDefaultsUtils.titleFontFamilyKey, store: .interfacePost) private var titleFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.titleFontSizeKey, store: .interfacePost) private var titleFontSize: Int = 2
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfacePost) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontSizeKey, store: .interfacePost) private var contentFontSize: Int = 2
    
    
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
                    selected: $titleFontFamily,
                    items: InterfaceFontUserDefaultsUtils.fontFamilies,
                    title: "Title Font Family"
                ) { family in
                    InterfaceFontUserDefaultsUtils.fontFamiliesText[family]
                }
                .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $titleFontSize,
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
