//
//  Snackbar.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-27.
//

import SwiftUI

struct Snackbar: View {
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @State private var dragOffset: CGSize = .zero
    @State private var isVisible = true
    
    private let dismissThreadshold: CGFloat = 80
    
    var body: some View {
        if snackbarManager.showSnackbar {
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    RowText(snackbarManager.text)
                        .foregroundStyle(Color(hex: customThemeViewModel.currentCustomTheme.snackbarTextColor))
                        .lineLimit(5)
                    
                    if let actionText = snackbarManager.actionText, !actionText.isEmpty {
                        Button(action: {
                            snackbarManager.action?()
                            snackbarManager.dismiss()
                        }) {
                            Text(actionText)
                                .foregroundStyle(Color(hex: customThemeViewModel.currentCustomTheme.snackbarActionTextColor))
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: customThemeViewModel.currentCustomTheme.snackbarBackgroundColor))
                )
                .padding(16)
                .applyIf(snackbarManager.canDismissByGesture) {
                    $0.offset(x: dragOffset.width)
                    // To make the animation smoother
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                }
                                .onEnded { value in
                                    if abs(value.translation.width) > dismissThreadshold {
                                        withAnimation(.snappy(duration: 0.3)) {
                                            dragOffset = CGSize(width: value.translation.width * 3, height: 0)
                                            isVisible = false
                                        } completion: {
                                            snackbarManager.dismiss()
                                            dragOffset = .zero
                                            isVisible = true
                                        }
                                    } else {
                                        withAnimation(.spring()) {
                                            dragOffset = .zero
                                        }
                                    }
                                }
                        )
                }
            }
            .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.2)))
        }
    }
}
