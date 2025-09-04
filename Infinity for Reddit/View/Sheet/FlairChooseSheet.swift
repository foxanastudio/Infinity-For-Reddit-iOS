//
// FlairChooseSheet.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-09-03

import SwiftUI

struct FlairChooseSheet: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject var subredditChooseViewModel: SubredditChooseViewModel
    @EnvironmentObject var submitTextPostViewModel: SubmitTextPostViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !subredditChooseViewModel.flairs.isEmpty {
                    ForEach(subredditChooseViewModel.flairs, id: \.id) { flair in
                        SimpleTouchItemRow(
                            text: flair.text,
                            icon: nil
                        ){
                            submitTextPostViewModel.selectedFlair = flair
                            dismiss()
                        }
                    }
                }
            }
            .padding(.top, 20)
        }
    }
}

