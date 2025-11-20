//
// SubredditSelectionSheet.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21
        
import SwiftUI
import Swinject
import GRDB
import Alamofire

struct SubredditSelectionSheet: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel
    
    @State private var showSearchSubredditsSheet: Bool = false
    
    let showCurrentAccountSubreddit: Bool
    let onSubscribedSubredditSelected: (SubscribedSubredditData) -> Void
    
    init(showCurrentAccountSubreddit: Bool = false, onSubscribedSubredditSelected: @escaping (SubscribedSubredditData) -> Void) {
        self.showCurrentAccountSubreddit = showCurrentAccountSubreddit
        _subscriptionListingViewModel = StateObject(
            wrappedValue: SubscriptionListingViewModel(
                // We don't care about the selection mode here cuz we are not using SubscriptionsView
                subscriptionSelectionMode: .noSelection,
                subscriptionListingRepository: SubscriptionListingRepository()
            )
        )
        self.onSubscribedSubredditSelected = onSubscribedSubredditSelected
    }

    var body: some View {
        SubscribedSubredditListingView(
            showCurrentAccountSubreddit: showCurrentAccountSubreddit,
            subscriptionListingViewModel: subscriptionListingViewModel
        ) { subscribedSubredditData in
            onSubscribedSubredditSelected(subscribedSubredditData)
            dismiss()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Select a Subreddit")
        .task {
            await subscriptionListingViewModel.loadSubscriptionsOnline()
            await subscriptionListingViewModel.loadMyCustomFeedsOnline()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showSearchSubredditsSheet = true
                } label: {
                    SwiftUI.Image(systemName: "magnifyingglass")
                }
            }
        }
        .sheet(isPresented: $showSearchSubredditsSheet) {
            NavigationStack {
                SearchSubredditsSheet { subscribedSubredditData in
                    onSubscribedSubredditSelected(subscribedSubredditData)
                    dismiss()
                }
            }
        }
    }
}

