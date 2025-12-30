//
//  UserFlairRowView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-17.
//

import SwiftUI

struct UserFlairRowView: View {
    let userFlair: UserFlair
    private let emojiSize: CGFloat = 14
    
    var body: some View {
        if !userFlair.richtext.isEmpty {
            HStack {
                FlairRichTextView(flairRichtext: userFlair.richtext, usePrimaryTextColor: true)
                    .padding(16)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        } else {
            HStack {
                RowText(userFlair.text)
                    .primaryText()
                    .padding(16)
                
                if userFlair.textEditable {
                    ZStack {
                        SwiftUI.Image(systemName: "pencil")
                            .primaryIcon()
                            .padding(12)
                            .padding(.trailing, 16)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // TODO modify flair
                    }
                }
            }
        }
    }
}
