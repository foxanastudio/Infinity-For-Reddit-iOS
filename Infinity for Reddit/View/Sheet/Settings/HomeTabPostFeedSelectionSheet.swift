//
//  HomeTabPostFeedSelectionSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2026-04-05.
//

import SwiftUI

struct HomeTabPostFeedSelectionSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @FocusState private var focusedField: FieldType?
    
    @State private var step: Step = .selectHomeTabPostFeedType
    @State private var nameOfHomeTabPostFeed: String = ""
    @State private var goForward: Bool = true
    @State private var showSelectSubredditSheet: Bool = false
    @State private var showSelectUserSheet: Bool = false
    @State private var showSelectCustomFeedSheet: Bool = false
    
    var onHomeTabPostFeedTypeSelected: (HomeTabPostFeedType, String?) -> Void
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(step == .selectHomeTabPostFeedType ? "Cancel" : "Back")
                        .neutralTextButton()
                        .onTapGesture {
                            if case .nameOfHomeTabPostFeedType = step {
                                goForward = false
                                withAnimation {
                                    step = .selectHomeTabPostFeedType
                                }
                            } else {
                                dismiss()
                            }
                        }
                    
                    Spacer()
                    
                    if case .nameOfHomeTabPostFeedType(let selectedType) = step {
                        Text("Save")
                            .positiveTextButton()
                            .onTapGesture {
                                let trimmed = nameOfHomeTabPostFeed.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else {
                                    return
                                }
                                onHomeTabPostFeedTypeSelected(selectedType, trimmed.isEmpty ? nil : trimmed)
                                dismiss()
                            }
                    }
                }
                .padding(16)
                
                RowText("This setting must be configured separately for each account and will take effect after restarting the app.")
                    .primaryText()
                    .fontWeight(.bold)
                    .padding(16)
                
                switch step {
                    case .selectHomeTabPostFeedType:
                    Group {
                        IconTextButton(startIconUrl: "sparkles", text: "Front Page") {
                            onHomeTabPostFeedTypeSelected(.frontPage, nil)
                            dismiss()
                        }
                        
                        IconTextButton(startIconUrl: "flame", text: "Popular") {
                            onHomeTabPostFeedTypeSelected(.subreddit, "popular")
                            dismiss()
                        }
                        
                        IconTextButton(startIconUrl: "globe", text: "All") {
                            onHomeTabPostFeedTypeSelected(.subreddit, "all")
                            dismiss()
                        }
                        
                        IconTextButton(startIconUrl: "text.bubble", text: "Subreddit") {
                            goForward = true
                            withAnimation {
                                step = .nameOfHomeTabPostFeedType(selectedType: .subreddit)
                            }
                        }
                        
                        IconTextButton(startIconUrl: "person.circle", text: "User") {
                            goForward = true
                            withAnimation {
                                step = .nameOfHomeTabPostFeedType(selectedType: .user)
                            }
                        }
                        
                        IconTextButton(startIconUrl: "rectangle.stack", text: "Custom Feed") {
                            goForward = true
                            withAnimation {
                                step = .nameOfHomeTabPostFeedType(selectedType: .customFeed)
                            }
                        }
                    }
                    .transition(transition)
                    
                    case .nameOfHomeTabPostFeedType(let selectedType):
                    Group {
                        RowText(selectedType.description)
                            .primaryText()
                            .fontWeight(.bold)
                            .padding(16)
                        
                        RowText("Leave it blank to apply this post filter to all the subreddits / users / multireddits")
                            .primaryText()
                            .padding(16)
                        
                        HStack(spacing: 16) {
                            CustomTextField(selectedType.textFieldPlaceholder,
                                            text: $nameOfHomeTabPostFeed,
                                            singleLine: true,
                                            autocapitalization: .never,
                                            fieldType: .nameOfHomeTabPostFeedType,
                                            focusedField: $focusedField)
                            .submitLabel(.done)
                            
                            if let searchIcon = selectedType.searchIcon {
                                Button(action: {
                                    switch selectedType {
                                    case .subreddit:
                                        showSelectSubredditSheet = true
                                    case .user:
                                        showSelectUserSheet = true
                                    case .customFeed:
                                        showSelectCustomFeedSheet = true
                                    default:
                                        // Shouldn't happen
                                        break
                                    }
                                }) {
                                    SwiftUI.Image(systemName: searchIcon)
                                        .resizable()
                                        .scaledToFit()
                                        .primaryIcon()
                                        .frame(width: 28)
                                }
                            }
                        }
                        .padding(16)
                    }
                    .transition(transition)
                }
            }
        }
        .sheet(isPresented: $showSelectSubredditSheet) {
            NavigationStack {
                SubredditSelectionSheet { thing in
                    onHomeTabPostFeedTypeSelected(.subreddit, thing.name)
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showSelectUserSheet) {
            NavigationStack {
                UserSelectionSheet { thing in
                    onHomeTabPostFeedTypeSelected(.user, thing.searchInSubredditOrUserName)
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showSelectCustomFeedSheet) {
            MyCustomFeedSelectionSheet { thing in
                onHomeTabPostFeedTypeSelected(.customFeed, thing.searchInCustomFeed)
                dismiss()
            }
        }
    }
    
    var transition: AnyTransition {
        return goForward ? .asymmetric(
            insertion: .move(edge: .trailing), removal: .move(edge: .leading)
        ) : .asymmetric(
            insertion: .move(edge: .leading), removal: .move(edge: .trailing)
        )
    }
}

private enum Step: Equatable {
    case selectHomeTabPostFeedType
    case nameOfHomeTabPostFeedType(selectedType: HomeTabPostFeedType)
}

private enum FieldType: Hashable {
    case nameOfHomeTabPostFeedType
}

private extension HomeTabPostFeedType {
    var searchIcon: String? {
        switch self {
        case .subreddit:
            return "text.bubble"
        case .user:
            return "person.crop.circle"
        case .customFeed:
            return "rectangle.stack"
        default:
            return nil
        }
    }
}
