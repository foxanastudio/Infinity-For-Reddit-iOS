//
//  TextViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-21.
//

import SwiftUI

struct PrimaryTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    let fontSize: AppFontSize
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont(fontSize: fontSize)
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor))
    }
}

struct SecondaryTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    let fontSize: AppFontSize
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont(fontSize: fontSize)
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.secondaryTextColor))
    }
}

struct ButtonTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.buttonTextColor))
    }
}

struct NavigationBarPrimaryTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.toolbarPrimaryTextAndIconColor))
            .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostInfoTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postIconAndInfoColor))
    }
}

struct CommentInfoTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.commentIconAndInfoColor))
    }
}

struct UsernameTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.username))
    }
}

struct UsernameOnPostTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    let post: Post
    
    var usernameColor: Color {
        if post.distinguished == "moderator" {
            Color(hex: themeViewModel.currentCustomTheme.moderator)
        } else {
            Color(hex: themeViewModel.currentCustomTheme.username)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont()
            .foregroundColor(usernameColor)
    }
}

struct SubredditTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.subreddit))
    }
}

struct PostTitleTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customPostTitleFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postTitleColor))
    }
}

struct PostContentTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customContentFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.postContentColor))
    }
}

struct CommentTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .fixedSize(horizontal: false, vertical: true)
            .customContentFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.commentColor))
    }
}

struct ListSectionHeaderViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.colorAccent))
    }
}

struct GalleryIndexIndicatorViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.mediaIndicatorIconColor))
            .background(Color(hex: themeViewModel.currentCustomTheme.mediaIndicatorBackgroundColor))
    }
}

struct ColorAccentTextViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.colorAccent))
    }
}

struct PositiveTextButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.colorPrimaryLightTheme))
    }
}

struct WarningTextButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .customFont()
            //.foregroundColor(Color(hex: themeViewModel.currentCustomTheme.colorPrimaryLightTheme))
            .foregroundColor(.red)
    }
}

struct NeutralTextButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .customFont()
            .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.primaryTextColor))
    }
}

struct CustomFilledTextButtonViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    let backgroundColor: Color
    let textColor: Color
    let borderColor: Color
    
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
}

