//
// GestureButtonsSettingsView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2024-12-04
//

import SwiftUI
import Swinject
import GRDB

struct GestureButtonsSettingsView: View {
    @AppStorage(GesturesButtonsUserDefaultsUtils.hideNavigationBarOnScrollDownKey, store: .gesturesButtons) private var hideNavigationBarOnScrollDown: Bool = false
    @AppStorage(GesturesButtonsUserDefaultsUtils.postLeftSwipeActionKey, store: .gesturesButtons) private var postLeftSwipeAction: Int = SwipeAction.upvote.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.postRightSwipeActionKey, store: .gesturesButtons) private var postRightSwipeAction: Int = SwipeAction.downvote.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.postDetailsLeftSwipeActionKey, store: .gesturesButtons) private var postDetailsLeftSwipeAction: Int = SwipeAction.upvote.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.postDetailsRightSwipeActionKey, store: .gesturesButtons) private var postDetailsRightSwipeAction: Int = SwipeAction.downvote.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.commentLeftSwipeActionKey, store: .gesturesButtons) private var commentLeftSwipeAction: Int = SwipeAction.upvote.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.commentRightSwipeActionKey, store: .gesturesButtons) private var commentRightSwipeAction: Int = SwipeAction.downvote.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.commentTapActionKey, store: .gesturesButtons) private var commentTapAction: Int = CommentTapAction.toggleToolbar.rawValue
    @AppStorage(GesturesButtonsUserDefaultsUtils.commentLongPressActionKey, store: .gesturesButtons) private var commentLongPressAction: Int = CommentTapAction.expandCollapseComment.rawValue
    
    var body: some View {
        RootView {
            List {
                TogglePreference(
                    isEnabled: $hideNavigationBarOnScrollDown,
                    title: "Hide Navigation Bar on Scroll Down",
                    subtitle: "Only applies to some pages"
                )
                .listPlainItemNoInsets()
                
                CustomListSection("Swipe Actions") {
                    BarebonePickerPreference(
                        selected: $postLeftSwipeAction,
                        items: GesturesButtonsUserDefaultsUtils.swipeActions,
                        title: "Post Left Swipe Action"
                    ) { swipeActionRawValue in
                        return (SwipeAction(rawValue: swipeActionRawValue) ?? .upvote).title
                    }
                    .listPlainItemNoInsets()
                    
                    BarebonePickerPreference(
                        selected: $postRightSwipeAction,
                        items: GesturesButtonsUserDefaultsUtils.swipeActions,
                        title: "Post Right Swipe Action"
                    ) { swipeActionRawValue in
                        return (SwipeAction(rawValue: swipeActionRawValue) ?? .downvote).title
                    }
                    .listPlainItemNoInsets()
                    
                    BarebonePickerPreference(
                        selected: $postDetailsLeftSwipeAction,
                        items: GesturesButtonsUserDefaultsUtils.swipeActions,
                        title: "Post Details Left Swipe Action"
                    ) { swipeActionRawValue in
                        return (SwipeAction(rawValue: swipeActionRawValue) ?? .upvote).title
                    }
                    .listPlainItemNoInsets()
                    
                    BarebonePickerPreference(
                        selected: $postDetailsRightSwipeAction,
                        items: GesturesButtonsUserDefaultsUtils.swipeActions,
                        title: "Post Details Right Swipe Action"
                    ) { swipeActionRawValue in
                        return (SwipeAction(rawValue: swipeActionRawValue) ?? .downvote).title
                    }
                    .listPlainItemNoInsets()
                    
                    BarebonePickerPreference(
                        selected: $commentLeftSwipeAction,
                        items: GesturesButtonsUserDefaultsUtils.swipeActions,
                        title: "Comment Left Swipe Action"
                    ) { swipeActionRawValue in
                        return (SwipeAction(rawValue: swipeActionRawValue) ?? .upvote).title
                    }
                    .listPlainItemNoInsets()
                    
                    BarebonePickerPreference(
                        selected: $commentRightSwipeAction,
                        items: GesturesButtonsUserDefaultsUtils.swipeActions,
                        title: "Comment Right Swipe Action"
                    ) { swipeActionRawValue in
                        return (SwipeAction(rawValue: swipeActionRawValue) ?? .downvote).title
                    }
                    .listPlainItemNoInsets()
                }
                
                CustomListSection("Comment Gestures") {
                    BarebonePickerPreference(
                        selected: $commentTapAction,
                        items: GesturesButtonsUserDefaultsUtils.commentTapActions,
                        title: "Comment Tap Action"
                    ) { tapActionRawValue in
                        return (CommentTapAction(rawValue: tapActionRawValue) ?? .toggleToolbar).title
                    }
                    .listPlainItemNoInsets()
                    
                    BarebonePickerPreference(
                        selected: $commentLongPressAction,
                        items: GesturesButtonsUserDefaultsUtils.commentTapActions,
                        title: "Comment Long Press Action"
                    ) { longPressActionRawValue in
                        return (CommentTapAction(rawValue: longPressActionRawValue) ?? .expandCollapseComment).title
                    }
                    .listPlainItemNoInsets()
                }
            }
            .themedList()
        }
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Gestures & Buttons")
    }
}
