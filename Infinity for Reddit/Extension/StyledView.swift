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
    
    func primaryText() -> some View {
        self.modifier(PrimaryTextViewModifier())
    }
    
    func secondaryText() -> some View {
        self.modifier(PrimaryTextViewModifier())
    }
    
    func navigationBarPrimaryText() -> some View {
        self.modifier(NavigationBarPrimaryTextViewModifier())
    }
    
    func themedNavigationBar() -> some View {
        self.modifier(NavigationBarViewModifier())
    }
    
    func addTitleToInlineNavigationBar(_ title: String) -> some View {
        self.modifier(InlineNavigationBarWithTitle(title: title))
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
}
