//
//  ModMailConversationOptionsSheet.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-11-12.
//

import SwiftUI

struct ModMailConversationOptionsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let conversation: ModMailConversation
    
    let onToggleArchive: () -> Void
    let onToggleHighlight: () -> Void
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 0) {
                    if conversation.isInternal != true {
                        IconTextButton(startIconUrl: conversation.isArchived ? "arrow.up.bin" : "archivebox", text: conversation.isArchived ? "Unarchive" : "Archive") {
                            onToggleArchive()
                            dismiss()
                        }
                    }
                    
                    IconTextButton(startIconUrl: conversation.isHighlighted ? "star.slash" : "star", text: conversation.isHighlighted ? "Unhighlight" : "Highlight") {
                        onToggleHighlight()
                        dismiss()
                    }
                }
                .padding(.top, 24)
            }
        }
    }
}
