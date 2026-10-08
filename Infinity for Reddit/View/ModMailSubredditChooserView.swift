//
//  ModMailSubredditChooserView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-08.
//

import SwiftUI

struct ModMailSubredditChooserView: View {
    @State private var showModeratedSubredditSelectionSheet: Bool = false
    
    let selectedSubreddit: ModeratedSubreddit?
    let labelWidth: CGFloat
    let onSubredditSelected: (ModeratedSubreddit) -> Void
    
    private let iconSize: CGFloat = 24
    
    init(selectedSubreddit: ModeratedSubreddit?,
         labelWidth: CGFloat,
         onSubredditSelected: @escaping (ModeratedSubreddit) -> Void
    ) {
        self.selectedSubreddit = selectedSubreddit
        self.labelWidth = labelWidth
        self.onSubredditSelected = onSubredditSelected
    }
    
    var body: some View {
        TouchRipple(action: {
            showModeratedSubredditSelectionSheet = true
        }) {
            HStack(spacing: 0) {
                Text("From")
                    .secondaryText()
                    .frame(width: labelWidth, alignment: .leading)
                
                Spacer()
                    .frame(width: 8)
                
                if let selectedSubreddit {
                    if let iconUrl = selectedSubreddit.iconUrl {
                        CustomWebImage(
                            iconUrl,
                            width: iconSize,
                            height: iconSize,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                InitialLetterAvatarImageFallbackView(name: selectedSubreddit.name, size: iconSize)
                            }
                        )
                    } else {
                        InitialLetterAvatarImageFallbackView(name: selectedSubreddit.name, size: iconSize)
                    }
                } else {
                    Spacer()
                        .frame(width: iconSize)
                }
                
                Spacer()
                    .frame(width: 24)
                
                RowText(selectedSubreddit?.name ?? "Choose a subreddit")
                    .primaryText()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .contentShape(Rectangle())
        }
        .sheet(isPresented: $showModeratedSubredditSelectionSheet) {
            NavigationStack {
                ModeratedSubredditSelectionSheet { subreddit in
                    onSubredditSelected(subreddit)
                }
            }
        }
    }
}
