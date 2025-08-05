//
//  PostFilterUsageSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-04.
//

import SwiftUI

struct PostFilterUsageSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var step: Step = .selectUsageType
    
    var onPostFilterUsageSelected: (PostFilterUsage.UsageType, String?) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 16)
            
            switch step {
                case .selectUsageType:
                IconTextButton(startIconUrl: "house", text: "Home") {
                    onPostFilterUsageSelected(.home, nil)
                    dismiss()
                }
                
                IconTextButton(startIconUrl: "text.bubble", text: "Subreddit") {
                    step = .nameOfUsage(selectedType: .subreddit)
                }
                
                IconTextButton(startIconUrl: "person.circle", text: "User") {
                    step = .nameOfUsage(selectedType: .user)
                }
                
                IconTextButton(startIconUrl: "rectangle.stack", text: "Custom Feed") {
                    step = .nameOfUsage(selectedType: .customFeed)
                }
                
                IconTextButton(startIconUrl: "magnifyingglass", text: "Search") {
                    onPostFilterUsageSelected(.search, nil)
                    dismiss()
                }
                case .nameOfUsage(let selectedType):
                Text(String(selectedType.rawValue))
            }
            
            Spacer()
        }
    }
    
    private enum Step {
        case selectUsageType
        case nameOfUsage(selectedType: PostFilterUsage.UsageType)
    }
}
