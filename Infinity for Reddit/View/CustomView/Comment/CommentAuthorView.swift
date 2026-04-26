//
//  CommentAuthorView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-19.
//

import SwiftUI

struct CommentAuthorView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    @EnvironmentObject private var accountViewModel: AccountViewModel
    
    let comment: Comment
    private let iconSize: CGFloat = 16
    
    var textColor: Color {
        if comment.isSubmitter {
            Color(hex: customThemeViewModel.currentCustomTheme.submitter)
        } else if comment.distinguished == "moderator" {
            Color(hex: customThemeViewModel.currentCustomTheme.moderator)
        } else if accountViewModel.account.username == comment.author {
            Color(hex: customThemeViewModel.currentCustomTheme.currentUser)
        } else {
            Color(hex: customThemeViewModel.currentCustomTheme.username)
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if comment.isSubmitter {
                SwiftUI.Image(systemName: "microphone.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(Color(hex: customThemeViewModel.currentCustomTheme.submitter))
            } else if comment.distinguished == "moderator" {
                SwiftUI.Image(systemName: "checkmark.shield.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(Color(hex: customThemeViewModel.currentCustomTheme.moderator))
            } else if accountViewModel.account.username == comment.author {
                SwiftUI.Image(systemName: "person.crop.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconSize, height: iconSize)
                    .foregroundColor(Color(hex: customThemeViewModel.currentCustomTheme.currentUser))
            }
            
            Text("u/\(comment.author ?? "")")
                .fixedSize(horizontal: false, vertical: true)
                .customFont()
                .foregroundColor(textColor)
                .lineLimit(1)
        }
    }
}
