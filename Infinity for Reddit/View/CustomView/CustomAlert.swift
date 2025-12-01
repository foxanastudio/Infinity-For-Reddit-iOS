//
//  CustomAlert.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-19.
//

import SwiftUI

struct CustomAlert<Content: View>: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    @Binding var isPresented: Bool
    
    @State private var buttonHStackMaxHeight: CGFloat = 0
    
    var title: String
    var subtitle: String?
    var content: Content?
    var dismissButtonText: String
    var confirmButtonText: String
    var buttonStyle: AlertButtonStyle
    var showDismissButton: Bool
    var onDismiss: (() -> Void)?
    var onConfirm: (() -> Void)?
    
    init(
        title: String,
        subtitle: String? = nil,
        dismissButtonText: String = "Cancel",
        confirmButtonText: String = "Yes",
        buttonStyle: AlertButtonStyle = .info,
        showDismissButton: Bool = true,
        isPresented: Binding<Bool>,
        @ViewBuilder content: () -> Content? = { nil },
        onDismiss: (() -> Void)? = nil,
        onConfirm: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.dismissButtonText = dismissButtonText
        self.confirmButtonText = confirmButtonText
        self.buttonStyle = buttonStyle
        self.showDismissButton = showDismissButton
        self._isPresented = isPresented
        self.content = content()
        self.onDismiss = onDismiss
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onDismiss?()
                        withAnimation(.linear(duration: 0.2)) {
                            isPresented = false
                        }
                    }
                
                VStack(spacing: 0) {
                    Text(title)
                        .primaryText()
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 16)
                        .padding(.horizontal, 16)
                    
                    if let subtitle {
                        Text(subtitle)
                            .secondaryText()
                            .padding(.top, 16)
                            .padding(.horizontal, 16)
                    }
                    
                    Spacer()
                        .frame(height: 16)
                    
                    if let content {
                        content
                            .padding(.horizontal, 16)
                            .padding(.bottom, 20)
                    }
                    
                    Divider()
                    
                    HStack(spacing: 0) {
                        if showDismissButton {
                            TouchRipple(action: {
                                onDismiss?()
                                withAnimation(.linear(duration: 0.2)) {
                                    isPresented = false
                                }
                            }) {
                                Text(dismissButtonText)
                                    .neutralTextButton()
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                                    .contentShape(Rectangle())
                            }
                            .background(GeometryReader { geo in
                                Color.clear.preference(key: MaxHeightKey.self, value: geo.size.height)
                            })
                            
                            Divider()
                        }
                        
                        TouchRipple(action: {
                            onConfirm?()
                            withAnimation(.linear(duration: 0.2)) {
                                isPresented = false
                            }
                        }) {
                            Text(confirmButtonText)
                                .applyIf(buttonStyle == .info) {
                                    $0.positiveTextButton()
                                }
                                .applyIf(buttonStyle == .warning) {
                                    $0.warningTextButton()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(16)
                                .contentShape(Rectangle())
                        }
                        .background(GeometryReader { geo in
                            Color.clear.preference(key: MaxHeightKey.self, value: geo.size.height)
                        })
                    }
                    .frame(height: buttonHStackMaxHeight)
                }
                .frame(maxWidth: 300)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: customThemeViewModel.currentCustomTheme.cardViewBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: -1)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.vertical, 16)
                .onPreferenceChange(MaxHeightKey.self) { value in
                    buttonHStackMaxHeight = value
                }
            }
        }
    }
}

struct MaxHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

enum AlertButtonStyle {
    case info
    case warning
}
