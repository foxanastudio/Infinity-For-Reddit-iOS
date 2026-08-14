//
//  ModMailReplyAsPicker.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-05-12.
//

import SwiftUI

struct ModMailReplyAsPicker: View {
    @Binding var selectedReplyAsOption: ModMailReplyAsOption
    
    let subredditName: String
    
    var body: some View {
        Menu {
            ForEach(ModMailReplyAsOption.allCases, id: \.self) { option in
                Button {
                    selectedReplyAsOption = option
                } label: {
                    replyAsMenuRow(
                        title: option.getTitle(
                            subredditName: subredditName
                        )
                    )
                }
            }
        } label: {
            HStack(spacing: 12) {
                Text(selectedReplyAsOption.getTitle(
                    subredditName: subredditName
                ))
                .primaryText()
                .lineLimit(1)
                .padding(.trailing, 2)
                
                SwiftUI.Image(systemName: "chevron.up.chevron.down")
                    .primaryIcon()
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
    }
    
    private func replyAsMenuRow(title: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .primaryText()
                .fontWeight(.medium)
                .lineLimit(1)
            
            Spacer(minLength: 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
    }
}
