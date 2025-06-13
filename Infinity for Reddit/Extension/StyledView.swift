//
//  StyledView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-21.
//

import SwiftUI

extension View {
    func themedList() -> some View {
        self.modifier(ListCustomThemeViewModifier())
    }
    
    func listPlainItem() -> some View {
        self.modifier(ListPlainItemThemeViewModifier())
    }
    
    func listPlainItemNoInsets() -> some View {
        self.modifier(ListPlainItemNoInsetsThemeViewModifier())
    }
    
    func primaryText() -> some View {
        self.modifier(PrimaryTextViewModifier())
    }
    
    func secondaryText() -> some View {
        self.modifier(SecondaryTextViewModifier())
    }
    
    func navigationBarPrimaryText() -> some View {
        self.modifier(NavigationBarPrimaryTextViewModifier())
    }
    
    func themedNavigationBar() -> some View {
        self.modifier(NavigationBarViewModifier())
    }
    
    func addTitleToInlineNavigationBar(_ title: String, _ opacity: Double) -> some View {
        self.modifier(InlineNavigationBarWithTitle(title: title, opacity: opacity))
    }
    
    func navigationBarButton() -> some View {
        self.modifier(NavigationBarButtonViewModifier())
    }
    
    func navigationBarImage() -> some View {
        self.modifier(NavigationBarImageViewModifier())
    }
    
    func themedNavigationBarBackButton() -> some View {
        self.modifier(NavigationBarBackButtonViewModifier())
    }
    
    func themedTabView() -> some View {
        self.modifier(TabViewCustomThemeViewModifier())
    }
    
    func themedTabViewGroup() -> some View {
        self.modifier(TabViewGroupViewModifier())
    }
    
    func listSectionHeader() -> some View {
        self.modifier(ListSectionHeaderViewModifier())
    }
    
    func postIcon() -> some View {
        self.modifier(PostIconImageViewModifier())
    }
    
    func postInfo() -> some View {
        self.modifier(PostInfoTextViewModifier())
    }
    
    func commentIcon() -> some View {
        self.modifier(CommentIconImageViewModifier())
    }
    
    func commentInfo() -> some View {
        self.modifier(CommentInfoTextViewModifier())
    }
    
    func postUpvoteIcon(isUpvoted: Bool) -> some View {
        self.modifier(PostUpvoteIconImageViewModifier(isUpvoted: isUpvoted))
    }
    
    func postDownvoteIcon(isDownvoted: Bool) -> some View {
        self.modifier(PostDownvoteIconImageViewModifier(isDownVoted: isDownvoted))
    }
    
    func commentUpvoteIcon(isUpvoted: Bool) -> some View {
        self.modifier(CommentUpvoteIconImageViewModifier(isUpvoted: isUpvoted))
    }
    
    func commentDownvoteIcon(isDownvoted: Bool) -> some View {
        self.modifier(CommentDownvoteIconImageViewModifier(isDownVoted: isDownvoted))
    }
    
    func username() -> some View {
        self.modifier(UsernameTextViewModifier())
    }
    
    func subreddit() -> some View {
        self.modifier(SubredditTextViewModifier())
    }
    
    func postTitle() -> some View {
        self.modifier(PostTitleTextViewModifier())
    }
    
    func postContent() -> some View {
        self.modifier(PostContentTextViewModifier())
    }
    
    func commentText() -> some View {
        self.modifier(CommentTextViewModifier())
    }
    
    func primaryIcon() -> some View {
        self.modifier(PrimaryIconImageViewModifier())
    }
    
    func themedPicker() -> some View {
        self.modifier(PickerCustomThemeViewModifier())
    }
    
    func themedToggle() -> some View {
        self.modifier(ToggleCustomThemeViewModifier())
    }
    
    func themedMarkdown() -> some View {
        self.modifier(MarkdownViewModifier())
    }
    
    func themedPostCommentMarkdown() -> some View {
        self.modifier(PostContentMarkdownViewModifier())
    }
    
    func themedCommentMarkdown() -> some View {
        self.modifier(CommentMarkdownViewModifier())
    }
    
    func mediaIndicator() -> some View {
        self.modifier(MediaIndicatorViewModifier())
    }
}
