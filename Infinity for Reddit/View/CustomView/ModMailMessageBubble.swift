//
//  ModMailMessageBubble.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-05-16.
//

import SwiftUI

struct ModMailMessageBubble<Content: View>: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    let isSentMessage: Bool
    let shouldShowTail: Bool
    let modMailSenderLabel: String?
    let isInternal: Bool
    let content: () -> Content

    private var bubbleBackgroundColor: Color {
        if isSentMessage {
            Color(hex: customThemeViewModel.currentCustomTheme.sentMessageBackgroundColor)
        } else {
            Color(hex: customThemeViewModel.currentCustomTheme.receivedMessageBackgroundColor)
        }
    }

    var body: some View {
        HStack {
            if isSentMessage {
                Spacer()
            }
            
            VStack(alignment: isSentMessage ? .trailing : .leading, spacing: 4) {
                if let modMailSenderLabel {
                    Text(modMailSenderLabel)
                        .padding(.leading, isSentMessage ? 6 : 16)
                        .padding(.trailing, isSentMessage ? 16 : 6)
                        .secondaryText()
                }
                
                if isInternal {
                    Text("Mods only")
                        .padding(.leading, isSentMessage ? 6 : 16)
                        .padding(.trailing, isSentMessage ? 16 : 6)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: customThemeViewModel.currentCustomTheme.moderator))
                }
                
                content()
                    .padding(.vertical, 12)
                    .padding(.leading, isSentMessage ? 12 : 20)
                    .padding(.trailing, isSentMessage ? 20 : 12)
                    .applyIf(shouldShowTail) {
                        $0.background(
                            ChatBubbleWithTailShape(isSentMessage: isSentMessage, tailWidth: 8)
                                .fill(bubbleBackgroundColor)
                        )
                    }
                    .applyIf(!shouldShowTail) {
                        $0.background(
                            ChatBubbleShape(isSentMessage: isSentMessage)
                                .fill(bubbleBackgroundColor)
                        )
                    }
                    .customFont()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .frame(maxWidth: 300, alignment: isSentMessage ? .trailing : .leading)
            
            if !isSentMessage {
                Spacer()
            }
        }
    }
}
