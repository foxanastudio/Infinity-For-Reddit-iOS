//
//  CreateThemeSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-09-28.
//

import SwiftUI

struct CreateThemeSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let onCreateTheme: () -> Void
    let onImportTheme: () -> Void
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 0) {
                    IconTextButton(
                        startIconUrl: "pencil",
                        text: "Create Theme"
                    ) {
                        onCreateTheme()
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
