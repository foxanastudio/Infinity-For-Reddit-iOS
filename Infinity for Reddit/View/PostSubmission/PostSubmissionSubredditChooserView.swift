//
// PostSubmissionSubredditChooserView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21
        
import SwiftUI

struct PostSubmissionSubredditChooserView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    @ObservedObject var postSubmissionContextViewModel: PostSubmissionContextViewModel
    
    @State private var showRulesSheet = false
    @State private var showSubredditSelectionSheet = false

    var onSubredditSelected: (SubscribedSubredditData) -> Void
    var onShowNoSubredditAlert: () -> Void
    
    private let iconSize: CGFloat = 24
    
    init(postSubmissionContextViewModel: PostSubmissionContextViewModel,
         onSubredditSelected: @escaping (SubscribedSubredditData) -> Void,
         onShowNoSubredditAlert: @escaping () -> Void
    ) {
        self.postSubmissionContextViewModel = postSubmissionContextViewModel
        self.onSubredditSelected = onSubredditSelected
        self.onShowNoSubredditAlert = onShowNoSubredditAlert
    }
    
    var body: some View {
        TouchRipple(action: {
            showSubredditSelectionSheet = true
        }) {
            HStack(spacing: 0) {
                if let icon = postSubmissionContextViewModel.selectedSubreddit?.iconUrl {
                    CustomWebImage(
                        icon,
                        width: iconSize,
                        height: iconSize,
                        circleClipped: true,
                        handleImageTapGesture: false,
                        fallbackView: {
                            InitialLetterAvatarImageFallbackView(name: postSubmissionContextViewModel.selectedSubreddit?.name, size: iconSize)
                        }
                    )
                } else {
                    Spacer()
                        .frame(width: iconSize)
                }
                
                Spacer()
                    .frame(width: 24)
                
                RowText(postSubmissionContextViewModel.selectedSubreddit?.name ?? "Choose a subreddit")
                    .primaryText()
                
                Spacer()
                    .frame(width: 24)
                
                Button("Rules") {
                    if postSubmissionContextViewModel.selectedSubreddit == nil {
                        onShowNoSubredditAlert()
                    } else {
                        showRulesSheet = true
                    }
                }
                .filledButton(elevate: false)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .contentShape(Rectangle())
        }
        .sheet(isPresented: $showRulesSheet) {
            SubredditRulesSheet()
                .environmentObject(postSubmissionContextViewModel)
        }
        .sheet(isPresented: $showSubredditSelectionSheet) {
            NavigationStack {
                SubredditSelectionSheet(showCurrentAccountSubreddit: true) { thing in
                    switch thing {
                    case .subscribedSubreddit(let subscribedSubredditData):
                        onSubredditSelected(subscribedSubredditData)
                    case .subreddit(let subredditData):
                        onSubredditSelected(subredditData.toSubscribedSubredditData())
                    default:
                        break
                    }
                }
            }
        }
    }
}

