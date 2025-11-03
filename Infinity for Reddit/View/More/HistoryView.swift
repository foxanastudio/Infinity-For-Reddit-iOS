//
// HistoryView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct HistoryView: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            SegmentedPicker(selectedValue: $selectedTab, values: ["History"])
                .padding(4)
            
            TabView(selection: $selectedTab) {
                HistoryPostListingView(account: accountViewModel.account, historyPostListingMetadata: HistoryPostListingMetadata(
                    historyPostListingType: .read
                ))
                .tag(0)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("History")
        .id(accountViewModel.account.username)
        .toolbar {
            NavigationBarMenu()
        }
    }
}
