//
//  Snackbar.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-27.
//

import SwiftUI

struct Snackbar: View {
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    var body: some View {
        if snackbarManager.showSnackbar {
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    RowText(snackbarManager.text)
                        .foregroundStyle(Color.white)
                    
                    if let actionText = snackbarManager.actionText {
                        Button(action: {
                            snackbarManager.action?()
                            snackbarManager.dismiss()
                        }) {
                            Text(actionText)
                                .foregroundStyle(Color.white)
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "#353E41"))
                )
                .padding(16)
            }
        }
    }
}
