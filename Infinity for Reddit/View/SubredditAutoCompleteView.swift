//
//  SubredditAutoCompleteView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-01.
//

import SwiftUI

struct SubredditAutoCompleteView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject private var subredditAutoCompleteViewModel: SubredditAutoCompleteViewModel
    
    @Binding var query: String
    
    @AppStorage(ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey, store: .contentSensitivityFilter) private var sensitiveContent: Bool = false
    
    private let iconSize: CGFloat = 28
    private let onGoToSubreddit: (() -> Void)?
    
    init(query: Binding<String>, thingSelectionMode: ThingSelectionMode = .noSelection, onGoToSubreddit: (() -> Void)? = nil) {
        _query = query
        self.onGoToSubreddit = onGoToSubreddit
        _subredditAutoCompleteViewModel = StateObject(
            wrappedValue: SubredditAutoCompleteViewModel(
                thingSelectionMode: thingSelectionMode,
                subredditAutoCompleteRepository: SubredditAutoCompleteRepository()
            )
        )
    }
    
    var body: some View {
        Group {
            if subredditAutoCompleteViewModel.subreddits.isEmpty {
                EmptyView()
            } else {
                List {
                    ForEach(subredditAutoCompleteViewModel.subreddits, id: \.id) { subreddit in
                        HStack(spacing: 0) {
                            CustomWebImage(
                                subreddit.iconUrl,
                                width: iconSize,
                                height: iconSize,
                                circleClipped: true,
                                handleImageTapGesture: false,
                                fallbackView: {
                                    InitialLetterAvatarImageFallbackView(name: subreddit.displayName, size: iconSize)
                                }
                            )
                            
                            Spacer()
                                .frame(width: 24)
                            
                            VStack(spacing: 0) {
                                Text(subreddit.displayNamePrefixed)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .primaryText()
                                
                                Text("Subscribers: " + subreddit.subscribers.formatted())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .secondaryText()
                            }
                            
                            Spacer()
                            
                            if subredditAutoCompleteViewModel.thingSelectionMode.isMultiSelection {
                                SwiftUI.Image(systemName: isSelected(subreddit) ? "checkmark.square" : "square")
                                    .primaryIcon()
                            }
                        }
                        .listPlainItemNoInsets()
                        .padding(8)
                        .background(isSelected(subreddit) ? Color(hex: customThemeViewModel.currentCustomTheme.filledCardViewBackgroundColor) : Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            switch subredditAutoCompleteViewModel.thingSelectionMode {
                            case .noSelection:
                                navigationManager.append(
                                    AppNavigation.subredditDetails(subredditName: subreddit.displayName)
                                )
                                onGoToSubreddit?()
                            case .thingSelection(let onSelectThing):
                                onSelectThing(.subreddit(subreddit.toSubredditData()))
                            case .subredditAndUserMultiSelection:
                                subredditAutoCompleteViewModel.toggleSelection(subreddit: subreddit)
                            }
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
                .themedList()
            }
        }
        .onChange(of: query) { _, newValue in
            if newValue.trimmingCharacters(in: .whitespaces).isEmpty {
                subredditAutoCompleteViewModel.clearSubreddits()
            } else {
                subredditAutoCompleteViewModel.fetchSubredditsAutoComplete(query: query, over18: sensitiveContent)
            }
        }
    }
    
    func isSelected(_ subreddit: Subreddit) -> Bool {
        return subredditAutoCompleteViewModel.selectedSubreddits.index(id: subreddit.id) != nil
        || subredditAutoCompleteViewModel.selectedSubredditData.index(id: subreddit.id) != nil
        || subredditAutoCompleteViewModel.selectedSubscribedSubreddits.index(id: subreddit.id) != nil
        || subredditAutoCompleteViewModel.selectedSubredditsInCustomFeed.index(id: subreddit.name) != nil
    }
}
