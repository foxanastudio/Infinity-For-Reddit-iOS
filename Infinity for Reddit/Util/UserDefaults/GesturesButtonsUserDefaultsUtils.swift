//
//  GesturesButtonsUserDefaultsUtils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-12-10.
//

import Foundation

class GesturesButtonsUserDefaultsUtils {
    static let hideNavigationBarOnScrollDownKey = "hide_navigation_bar_on_scroll_down"
    static var hideNavigationBarOnScrollDown: Bool {
        return UserDefaults.gesturesButtons.bool(forKey: hideNavigationBarOnScrollDownKey, false)
    }
    
    static let postLeftSwipeActionKey = "post_left_swipe_actions"
    static var postLeftSwipeAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: postLeftSwipeActionKey, SwipeAction.upvote.rawValue)
    }
    
    static let postRightSwipeActionKey = "post_right_swipe_actions"
    static var postRightSwipeAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: postRightSwipeActionKey, SwipeAction.downvote.rawValue)
    }
    
    static let postDetailsLeftSwipeActionKey = "post_details_left_swipe_actions"
    static var postDetailsLeftSwipeAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: postDetailsLeftSwipeActionKey, SwipeAction.upvote.rawValue)
    }
    
    static let postDetailsRightSwipeActionKey = "post_details_right_swipe_actions"
    static var postDetailsRightSwipeAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: postDetailsRightSwipeActionKey, SwipeAction.downvote.rawValue)
    }
    
    static let commentLeftSwipeActionKey = "comment_left_swipe_actions"
    static var commentLeftSwipeAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: commentLeftSwipeActionKey, SwipeAction.upvote.rawValue)
    }
    
    static let commentRightSwipeActionKey = "comment_right_swipe_actions"
    static var commentRightSwipeAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: commentRightSwipeActionKey, SwipeAction.downvote.rawValue)
    }
    
    static let swipeActions: [Int] = [SwipeAction.none.rawValue, SwipeAction.upvote.rawValue, SwipeAction.downvote.rawValue]
    
    static let commentTapActionKey = "comment_tap_action"
    static var commentTapAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: commentTapActionKey, CommentTapAction.toggleToolbar.rawValue)
    }
    
    static let commentLongPressActionKey = "comment_long_press_action"
    static var commentLongPressAction: Int {
        return UserDefaults.gesturesButtons.integer(forKey: commentLongPressActionKey, CommentTapAction.expandCollapseComment.rawValue)
    }
    
    static let commentTapActions: [Int] = [CommentTapAction.toggleToolbar.rawValue, CommentTapAction.expandCollapseComment.rawValue]
}
