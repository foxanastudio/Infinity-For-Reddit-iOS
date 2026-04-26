//
//  ChatBubble.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-07-22.
//

import SwiftUI

struct ChatBubble<Content: View>: View {
    @EnvironmentObject var customThemeViewModel: CustomThemeViewModel
    
    let isSentMessage: Bool
    let shouldShowTail: Bool
    let tailWidth: CGFloat = 8
    let padding: CGFloat = 12
    let content: () -> Content

    var body: some View {
        HStack {
            if isSentMessage { Spacer() }

            content()
                .padding(.vertical, 12)
                .padding(.leading, isSentMessage ? 12 : 12 + tailWidth)
                .padding(.trailing, isSentMessage ? 12 + tailWidth : 12)
                .applyIf(shouldShowTail) {
                    $0.background(
                        ChatBubbleWithTailShape(isSentMessage: isSentMessage, tailWidth: tailWidth)
                            .fill(isSentMessage ? Color(hex: customThemeViewModel.currentCustomTheme.sentMessageBackgroundColor) : Color(hex: customThemeViewModel.currentCustomTheme.receivedMessageBackgroundColor))
                    )
                }
                .applyIf(!shouldShowTail) {
                    $0.background(
                        ChatBubbleShape(isSentMessage: isSentMessage)
                            .fill(isSentMessage ? Color(hex: customThemeViewModel.currentCustomTheme.sentMessageBackgroundColor) : Color(hex: customThemeViewModel.currentCustomTheme.receivedMessageBackgroundColor))
                    )
                }
                .customFont()
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .frame(maxWidth: 300, alignment: isSentMessage ? .trailing : .leading)

            if !isSentMessage { Spacer() }
        }
    }
}

struct AnyShape: Shape, @unchecked Sendable {
    private let _path: @Sendable (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        _path = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        _path(rect)
    }
}
