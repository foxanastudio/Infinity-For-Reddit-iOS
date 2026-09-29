//
//  CreateThemeSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-09-28.
//

import SwiftUI

struct CreateThemeSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onCreateLightTheme: () -> Void
    let onCreateDarkTheme: () -> Void
    let onCreateAmoledTheme: () -> Void
    let onImportTheme: () -> Void
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 0) {
                    IconTextButton(
                        startIconUrl: "sun.max",
                        text: "Create Light Theme"
                    ) {
                        onCreateLightTheme()
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                    
                    IconTextButton(
                        startIconUrl: "moon",
                        text: "Create Dark Theme"
                    ) {
                        onCreateDarkTheme()
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                    
                    IconTextButton(
                        startIconUrl: "moon",
                        text: "Create Amoled Theme"
                    ) {
                        onCreateAmoledTheme()
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                    
                    IconTextButton(
                        startIconUrl: "document.on.document",
                        text: "Import Theme"
                    ) {
                        onImportTheme()
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                }
                .padding(.top, 24)
            }
        }
    }
}
