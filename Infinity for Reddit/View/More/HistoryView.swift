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
    
    var body: some View {
        HistoryPostListingView(historyPostListingMetadata: HistoryPostListingMetadata(
            historyPostListingType: .read
        ))
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("History")
        .id(accountViewModel.account.username)
    }
}
