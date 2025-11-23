//
// FlairRowView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-09-14
        
import SwiftUI

struct FlairRowView: View {
    let flair: Flair
    private let emojiSize: CGFloat = 14
    
    var body: some View {
        if let flairRichtext = flair.richtext, !flairRichtext.isEmpty {
            HStack {
                FlairRichTextView(flairRichtext: flairRichtext, usePrimaryTextColor: true)
                    .padding(16)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        } else {
            HStack {
                RowText(flair.text)
                    .primaryText()
                    .padding(16)
                
                if flair.isEditable {
                    ZStack {
                        SwiftUI.Image(systemName: "pencil")
                            .primaryIcon()
                            .padding(12)
                            .padding(.trailing, 16)
                    }
                    .contentShape(Rectangle())
                    .excludeFromTouchRipple()
                    .onTapGesture {
                        // TODO modify flair
                    }
                }
            }
        }
    }
}
