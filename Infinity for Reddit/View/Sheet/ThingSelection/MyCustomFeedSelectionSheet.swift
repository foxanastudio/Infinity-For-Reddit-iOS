//
//  MyCustomFeedSelectionSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-05.
//

import SwiftUI

struct MyCustomFeedSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject var subscriptionListingViewModel: SubscriptionListingViewModel
    
    var onSelectMyCustomFeed: (Thing) -> Void
    
    init(onSelectMyCustomFeed: @escaping (Thing) -> Void) {
        _subscriptionListingViewModel = StateObject(
            wrappedValue: SubscriptionListingViewModel(
                // We don't care about the selection mode here cuz we are not using SubscriptionsView
                subscriptionSelectionMode: .noSelection,
                subscriptionListingRepository: SubscriptionListingRepository()
            )
        )
        self.onSelectMyCustomFeed = onSelectMyCustomFeed
    }
    
    var body: some View {
        SheetRootView {
            CustomFeedListingView(subscriptionListingViewModel: subscriptionListingViewModel) { customFeed in
                onSelectMyCustomFeed(customFeed)
                dismiss()
            }
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Custom Feeds")
        .task {
            await subscriptionListingViewModel.loadMyCustomFeedsOnline()
        }
    }
}
