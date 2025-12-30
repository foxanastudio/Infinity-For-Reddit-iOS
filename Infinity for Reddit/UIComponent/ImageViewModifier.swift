//
//  ImageViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI

struct NavigationBarImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            content
        } else {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.toolbarPrimaryTextAndIconColor))
        }
    }
}

struct PostIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
    }
}

struct VoteAndReplyUnavailableIconViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.voteAndReplyUnavailableButtonColor))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.voteAndReplyUnavailableButtonColor))
    }
}

struct CommentIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.commentIconAndInfoColor))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.commentIconAndInfoColor))
    }
}

struct PostUpvoteIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    let isUpvoted: Bool
    
    func body(content: Content) -> some View {
        if (isUpvoted) {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.upvoted))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.upvoted))
        } else {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
        }
    }
}

struct CommentUpvoteIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    let isUpvoted: Bool
    
    func body(content: Content) -> some View {
        if (isUpvoted) {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.upvoted))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.upvoted))
        } else {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.commentIconAndInfoColor))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.commentIconAndInfoColor))
        }
    }
}

struct PostDownvoteIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    let isDownVoted: Bool
    
    func body(content: Content) -> some View {
        if isDownVoted {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.downvoted))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.downvoted))
        } else {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
        }
    }
}

struct CommentDownvoteIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    let isDownVoted: Bool
    
    func body(content: Content) -> some View {
        if isDownVoted {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.downvoted))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.downvoted))
        } else {
            content
                .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.commentIconAndInfoColor))
                .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.commentIconAndInfoColor))
        }
    }
}

struct PrimaryIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryIconColor))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.primaryIconColor))
    }
}

struct SecondaryIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.secondaryTextColor))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.secondaryTextColor))
    }
}

struct FabIconImageViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.fabIconColor))
            .colorMultiply(Color(hex: themeViewModel.currentCustomTheme.fabIconColor))
    }
}

struct MediaIndicatorViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .padding(4)
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.mediaIndicatorIconColor))
            .background(Circle().fill(Color(hex: themeViewModel.currentCustomTheme.mediaIndicatorBackgroundColor)))
            .clipShape(Circle())
    }
}
