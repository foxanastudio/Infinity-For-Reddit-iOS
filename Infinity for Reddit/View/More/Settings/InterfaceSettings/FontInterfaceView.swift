//
// FontInterfaceView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-05
//

import SwiftUI
import Swinject
import GRDB
import UniformTypeIdentifiers

struct FontInterfaceView: View {
    @EnvironmentObject private var navigationManager: NavigationManager

    @AppStorage(InterfaceFontUserDefaultsUtils.fontFamilyKey, store: .interfaceFont) private var fontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.fontSizeKey, store: .interfaceFont) private var fontSize: Int = 2
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontFamilyKey, store: .interfaceFont) private var postTitleFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.postTitleFontSizeKey, store: .interfaceFont) private var postTitleFontSize: Int = 2
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontFamilyKey, store: .interfaceFont) private var contentFontFamily: Int = 0
    @AppStorage(InterfaceFontUserDefaultsUtils.contentFontSizeKey, store: .interfaceFont) private var contentFontSize: Int = 2

    @State private var showFontPicker = false
    @State private var showUploadError = false
    @State private var uploadErrorMessage = ""
    @State private var customFontDisplayName: String?
    
    
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

                if fontFamily == 16 {
                    PreferenceEntry(
                        title: "Custom Font Family",
                        subtitle: InterfaceFontUserDefaultsUtils.hasCustomFont ? (customFontDisplayName ?? "Font Uploaded") : "Tap to upload font"
                    ) {
                        showFontPicker = true
                    }
                    .listPlainItemNoInsets()
                }

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

                if postTitleFontFamily == 16 {
                    PreferenceEntry(
                        title: "Custom Font Family",
                        subtitle: InterfaceFontUserDefaultsUtils.hasCustomFont ? (customFontDisplayName ?? "Font Uploaded") : "Tap to upload font"
                    ) {
                        showFontPicker = true
                    }
                    .listPlainItemNoInsets()
                }

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

                if contentFontFamily == 16 {
                    PreferenceEntry(
                        title: "Custom Font Family",
                        subtitle: InterfaceFontUserDefaultsUtils.hasCustomFont ? (customFontDisplayName ?? "Font Uploaded") : "Tap to upload font"
                    ) {
                        showFontPicker = true
                    }
                    .listPlainItemNoInsets()
                }

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
        .id(customFontDisplayName)
        .fileImporter(
            isPresented: $showFontPicker,
            allowedContentTypes: [UTType(filenameExtension: "ttf")!, UTType(filenameExtension: "otf")!],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }

                guard url.startAccessingSecurityScopedResource() else {
                    uploadErrorMessage = "Failed to access the font file"
                    showUploadError = true
                    return
                }

                defer { url.stopAccessingSecurityScopedResource() }

                if FontUtils.uploadCustomFontFamily(from: url) {
                    customFontDisplayName = InterfaceFontUserDefaultsUtils.customFontDisplayName
                } else {
                    uploadErrorMessage = "Failed to upload font. Please make sure it's a valid TTF or OTF file."
                    showUploadError = true
                }

            case .failure(let error):
                uploadErrorMessage = "Failed to select font: \(error.localizedDescription)"
                showUploadError = true
            }
        }
        .alert("Custom font family upload error.", isPresented: $showUploadError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(uploadErrorMessage)
        }
        .onAppear {
            customFontDisplayName = InterfaceFontUserDefaultsUtils.customFontDisplayName
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Font")
    }
}
