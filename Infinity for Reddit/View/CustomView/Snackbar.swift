//
//  Snackbar.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-27.
//

import SwiftUI

struct Snackbar: View {
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @State private var dragOffset: CGSize = .zero
    @State private var isVisible = true
    
    private let dismissThreadshold: CGFloat = 80
    
    var body: some View {
        if snackbarManager.showSnackbar {
            VStack {
                Spacer()
                
                HStack(spacing: 8) {
                    RowText(snackbarManager.text)
                        .foregroundStyle(Color.white)
                    
                    if let actionText = snackbarManager.actionText, !actionText.isEmpty {
                        Button(action: {
                            withAnimation(.linear(duration: 0.3)) {
                                isVisible = false
                            } completion: {
                                snackbarManager.action?()
                                snackbarManager.dismiss()
                            }
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
                .offset(x: dragOffset.width)
                // To make the animation smoother
                .opacity(isVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isVisible)
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
    }
}
