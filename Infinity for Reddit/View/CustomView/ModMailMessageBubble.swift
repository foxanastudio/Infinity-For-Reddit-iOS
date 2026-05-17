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
    let content: () -> Content
    
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
                
                content()
                    .padding(.vertical, 12)
                    .padding(.leading, isSentMessage ? 12 : 20)
                    .padding(.trailing, isSentMessage ? 20 : 12)
                    .applyIf(shouldShowTail) {
                        $0.background(
                            ChatBubbleWithTailShape(isSentMessage: isSentMessage, tailWidth: 8)
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
