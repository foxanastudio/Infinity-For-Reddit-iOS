//
//  TextViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-21.
//

import SwiftUI

struct PrimaryTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor))
    }
}

struct SecondaryTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.secondaryTextColor))
    }
}

struct NavigationBarPrimaryTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.toolbarPrimaryTextAndIconColor))
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostInfoTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
    }
}

struct UsernameTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.username))
    }
}

struct SubredditTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.subreddit))
    }
}

struct PostTitleTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postTitleColor))
    }
}

struct PostContentTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postContentColor))
    }
}

struct CommentTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.commentColor))
    }
}

struct ListSectionHeaderViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            //.font()
            .foregroundColor(Color.red)
            //.foregroundColor(Color(hex: themeViewModel.currentCustomTheme.secondaryTextColor))
    }
}
