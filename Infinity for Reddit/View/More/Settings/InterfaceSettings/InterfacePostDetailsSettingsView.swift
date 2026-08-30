//
//  PostDetailsInterfaceView.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-11.
//

import Swinject
import GRDB
import SwiftUI

struct InterfacePostDetailsSettingsView: View {
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.separatePostAndCommentsKey, store: .interfacePostDetails) private var separatePostAndComments: Bool = true
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hidePostTypeKey, store: .interfacePostDetails) private var hidePostType: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hidePostFlairKey, store: .interfacePostDetails) private var hidePostFlair: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideUpvoteRatioKey, store: .interfacePostDetails) private var hideUpvoteRatio: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideSubredditAndUserPrefixKey, store: .interfacePostDetails) private var hideSubredditAndUserPrefix: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideNVotesKey, store: .interfacePostDetails) private var hideNVotes: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideNCommentsKey, store: .interfacePostDetails) private var hideNComments: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.hideFloatingControlsKey, store: .interfacePostDetails) private var hideFloatingControls: Bool = false
    @AppStorage(InterfacePostDetailsUserDefaultsUtils.markdownEmbeddedMediaTypeKey, store: .interfacePostDetails) private var markdownEmbeddedMediaType: Int = 15
    
    var body: some View {
        RootView {
            List {
                TogglePreference(
                    isEnabled: $separatePostAndComments,
                    title: "Separate Post and Comments",
                    subtitle: "When enabled, post and comments appear in separate columns if there’s enough space."
                )
                .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $hidePostType, title: "Hide Post Type")
                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $hidePostFlair, title: "Hide Post Flair")
                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $hideUpvoteRatio, title: "Hide Upvote Ratio")
                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $hideSubredditAndUserPrefix, title: "Hide Subreddit and User Prefix")
                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $hideNVotes, title: "Hide the Number of Votes")
                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $hideNComments, title: "Hide the Number of Comments")
                    .listPlainItemNoInsets()
                
                TogglePreference(isEnabled: $hideFloatingControls, title: "Hide Floating Controls")
                    .listPlainItemNoInsets()
                
                BarebonePickerPreference(
                    selected: $markdownEmbeddedMediaType,
                    items: InterfacePostDetailsUserDefaultsUtils.markdownEmbeddedMediaTypes,
                    title: "Markdown Embedded Media Type"
                ) { layout in
                    InterfacePostDetailsUserDefaultsUtils.markdownEmbeddedMediaTypesText[InterfacePostDetailsUserDefaultsUtils.markdownEmbeddedMediaTypes.firstIndex(of: layout) ?? 0]
                }
                .listPlainItemNoInsets()
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Post Details")
    }
}
