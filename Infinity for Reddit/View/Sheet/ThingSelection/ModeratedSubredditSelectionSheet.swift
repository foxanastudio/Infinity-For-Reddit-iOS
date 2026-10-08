//
//  ModeratedSubredditSelectionSheet.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-08.
//

import SwiftUI

struct ModeratedSubredditSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var moderatedSubredditListingViewModel: ModeratedSubredditListingViewModel
    
    let onSubredditSelected: (ModeratedSubreddit) -> Void
    
    init(onSubredditSelected: @escaping (ModeratedSubreddit) -> Void) {
        _moderatedSubredditListingViewModel = StateObject(
            wrappedValue: ModeratedSubredditListingViewModel(
                createModMailConversationRepository: CreateModMailConversationRepository()
            )
        )
        self.onSubredditSelected = onSubredditSelected
    }
    
    var body: some View {
        SheetRootView {
            if moderatedSubredditListingViewModel.moderatedSubreddits.isEmpty {
                ZStack {
                    if moderatedSubredditListingViewModel.isLoading {
                        ProgressIndicator()
                    } else if let error = moderatedSubredditListingViewModel.error {
                        Text("Unable to load moderated subreddits. Tap to retry. Error: \(error.localizedDescription)")
                            .primaryText()
                            .padding(16)
                            .onTapGesture {
                                moderatedSubredditListingViewModel.refreshModeratedSubreddits()
                            }
                    } else {
                        Text("No moderated subreddits")
                            .primaryText()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(moderatedSubredditListingViewModel.moderatedSubreddits) { subreddit in
                        ModeratedSubredditItemView(subreddit: subreddit) {
                            onSubredditSelected(subreddit)
                            dismiss()
                        }
                        .limitedWidth()
                        .listPlainItemNoInsets()
                    }
                }
                .scrollBounceBehavior(.always)
                .themedList()
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Select a Subreddit")
        .task(id: moderatedSubredditListingViewModel.loadModeratedSubredditsFlag) {
            await moderatedSubredditListingViewModel.loadModeratedSubreddits()
        }
    }
}

private struct ModeratedSubredditItemView: View {
    let subreddit: ModeratedSubreddit
    let action: () -> Void
    
    private let iconSize: CGFloat = 24
    
    var body: some View {
        TouchRipple(action: action) {
            HStack(spacing: 0) {
                if let iconUrl = subreddit.iconUrl {
                    CustomWebImage(
                        iconUrl,
                        width: iconSize,
                        height: iconSize,
                        circleClipped: true,
                        handleImageTapGesture: false,
                        fallbackView: {
                            InitialLetterAvatarImageFallbackView(name: subreddit.name, size: iconSize)
                        }
                    )
                } else {
                    InitialLetterAvatarImageFallbackView(name: subreddit.name, size: iconSize)
                }
                
                Spacer()
                    .frame(width: 24)
                
                RowText(subreddit.name)
                    .primaryText()
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .contentShape(Rectangle())
        }
    }
}
