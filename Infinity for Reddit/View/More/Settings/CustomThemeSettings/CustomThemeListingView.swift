//
//  CustomThemeListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-20.
//

import SwiftUI
import Swinject
import GRDB

struct CustomThemeListingView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @StateObject private var customThemeListingViewModel: CustomThemeListingViewModel
    
    @State private var showShareSheet: Bool = false
    
    init() {
        _customThemeListingViewModel = StateObject(
            wrappedValue: CustomThemeListingViewModel(
                customThemeListingRepository: CustomThemeListingRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            List {
                ForEach(customThemeListingViewModel.customThemes, id: \.self.id) { customTheme in
                    ThemeListItem(themeName: customTheme.name, primaryColor: Color(hex: customTheme.colorPrimary)) {
                        navigationManager.append(CustomThemeSettingsViewNavigation.customizeCustomTheme(customThemeId: customTheme.id))
                    }
                    .listPlainItemNoInsets()
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            customThemeListingViewModel.deleteTheme(customTheme)
                        } label: {
                            Text("Delete")
                                .foregroundStyle(.white)
                        }
                        .tint(.red)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            customThemeListingViewModel.customThemeToShare = customTheme
                            showShareSheet = true
                        } label: {
                            Text("Share")
                                .foregroundStyle(.white)
                        }
                        .tint(Color(hex: customTheme.colorPrimaryLightTheme))
                    }
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Manage Themes")
        .showErrorUsingSnackbar(customThemeListingViewModel.$error)
        .sheet(isPresented: $showShareSheet) {
            if let document = customThemeListingViewModel.document {
                ShareSheet(json: document)
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let json: String

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: [json],
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
