//
//  SubscriptionsView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-03.
//

import SwiftUI
import Swinject
import GRDB

struct SubscriptionsView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    
    // State to track the selected picker index
    @State private var selectedOption = 0

    var body: some View {
        VStack {
            Picker("Options", selection: $selectedOption) {
                Text("Subreddits").tag(0)
                Text("Users").tag(1)
                Text("Custom Feed").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selectedOption == 0 {
                SubredditsView()
            } else if selectedOption == 1 {
                UsersView()
            } else {
                CustomFeedView()
            }

            Spacer() // Push content to the top
        }
        .navigationTitle("Subscriptions") // Optional navigation title
    }
}

struct SubredditsView: View {
    var body: some View {
        Text("Subreddits Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green.opacity(0.1))
    }
}

struct UsersView: View {
    var body: some View {
        Text("Users Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.purple.opacity(0.1))
    }
}

struct CustomFeedView: View {
    var body: some View {
        Text("Custom Feed Content")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.1))
    }
}
