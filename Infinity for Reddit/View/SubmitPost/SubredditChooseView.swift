//
// SubredditChooseView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21
        
import SwiftUI

struct SubredditChooseView: View {
    
    @EnvironmentObject var subredditChooseViewModel: SubredditChooseViewModel
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @State private var showNoSubredditAlert = false
    
    var text: String
    var iconUrl: String?
    var iconSize: CGFloat = 24
    var action: () -> Void
    
    var body: some View {
        TouchRipple {
            HStack(spacing: 0) {
                if let icon = subredditChooseViewModel.selectedSubreddit?.iconUrl {
                    CustomWebImage(
                        icon,
                        width: iconSize,
                        height: iconSize,
                        circleClipped: true,
                        handleImageTapGesture: false
                    )
                } else {
                    Spacer()
                        .frame(width: iconSize)
                }
                
                Spacer()
                    .frame(width: 24)
                
                Text(subredditChooseViewModel.selectedSubreddit?.name ?? text)
                    .primaryText()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button("Rules") {
                    if subredditChooseViewModel.selectedSubreddit == nil {
                        showNoSubredditAlert = true
                    } else {
                        Task {
                            let isAnonymous: Bool = accountViewModel.account.isAnonymous()
                            await subredditChooseViewModel.fetchRules(
                                isAnonymous: isAnonymous
                            )
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .controlSize(.regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
            .alert("No Subreddit Selected",
                   isPresented: $showNoSubredditAlert,
                   actions: { Button("OK", role: .cancel) { } },
                   message: { Text("Please select a subreddit first") }
            )
        }
    }
}

