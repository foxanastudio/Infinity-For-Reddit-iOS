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
    
    func buttonText() -> some View {
        self.modifier(ButtonTextViewModifier())
    }
    
    func navigationBarPrimaryText() -> some View {
        self.modifier(NavigationBarPrimaryTextViewModifier())
    }
    
    func themedNavigationBar(opacity: Double = 1) -> some View {
        self.modifier(NavigationBarViewModifier(opacity: opacity))
    }
    
    func addTitleToInlineNavigationBar(_ title: String, _ opacity: Double = 1.0) -> some View {
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
    
    func usernameOnPost(post: Post) -> some View {
        self.modifier(UsernameOnPostTextViewModifier(post: post))
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
    
    func secondaryIcon() -> some View {
        self.modifier(SecondaryIconImageViewModifier())
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
    
    func galleryIndexIndicator() -> some View {
        self.modifier(GalleryIndexIndicatorViewModifier())
    }
    
    func mediaIndicator() -> some View {
        self.modifier(MediaIndicatorViewModifier())
    }
    
    func noPreviewPostTypeIndicatorBackground() -> some View {
        self.modifier(NoPreviewPostTypeIndicatorBackgroundViewModifier())
    }
    
    func noPreviewPostTypeIndicator() -> some View {
        self.modifier(NoPreviewPostTypeIndicatorViewModifier())
    }
    
    func mediaTapGesture(post: Post?, aspectRatio: CGSize?, matchedGeometryEffectId: String?) -> some View {
        self.modifier(MediaTapGestureHandlerViewModifer(
            post: post, aspectRatio: aspectRatio, matchedGeometryEffectId: matchedGeometryEffectId
        ))
    }
    
    func postTypeTag() -> some View {
        self.modifier(PostTypeTagViewModifier())
    }
    
    func spoilerTag() -> some View {
        self.modifier(SpoilerTagViewModifier())
    }
    
    func sensitiveTag() -> some View {
        self.modifier(SensitiveTagViewModifier())
    }
    
    func postFlairBackground() -> some View {
        self.modifier(PostFlairBackgroundViewModifier())
    }
    
    func postFlairText() -> some View {
        self.modifier(PostFlairTextViewModifier())
    }
    
    func upvoteRatioText() -> some View {
        self.modifier(UpvoteRatioTextViewModifier())
    }
    
    func upvoteRatioIcon() -> some View {
        self.modifier(UpvoteRatioIconViewModifier())
    }
    
    func archivedTag() -> some View {
        self.modifier(ArchivedTagViewModifier())
    }
    
    func lockedTag() -> some View {
        self.modifier(LockedTagViewModifier())
    }
    
    func crosspostTag() -> some View {
        self.modifier(CrosspostTagViewModifier())
    }
    
    func filledCardBackground() -> some View {
        self.modifier(FilledCardBackgroundViewModifier())
    }
    
    func colorAccentText() -> some View {
        self.modifier(ColorAccentTextViewModifier())
    }
    
    func positiveTextButton() -> some View {
        self.modifier(PositiveTextButtonViewModifier())
    }
    
    func warningTextButton() -> some View {
        self.modifier(WarningTextButtonViewModifier())
    }
    
    func neutralTextButton() -> some View {
        self.modifier(NeutralTextButtonViewModifier())
    }
    
    func appForegroundBackgroundListener(
        onAppEntersForeground: (() -> Void)? = nil,
        onAppEntersBackground: (() -> Void)? = nil
    ) -> some View {
        self.modifier(AppForegroundBackgroundViewModifier(
            onAppEntersForeground: onAppEntersForeground,
            onAppEntersBackground: onAppEntersBackground
        ))
    }
    
    func customFilledButton(
        backgroundColor: Color,
        textColor: Color,
        borderColor: Color,
        cornerRadius: CGFloat = 6,
        borderWidth: CGFloat = 1
    ) -> some View {
        self.modifier(
            CustomFilledTextButtonViewModifier(
                backgroundColor: backgroundColor,
                textColor: textColor,
                borderColor: borderColor,
                cornerRadius: cornerRadius,
                borderWidth: borderWidth
            )
        )
    }
    
    func rootViewBackground() -> some View {
        self.modifier(RootViewBackgroundViewModifier())
    }
    
    func mediaGesture(
        minZoomScale: CGFloat = 1,
        doubleTapZoomScale: CGFloat = 2,
        outOfBoundsColor: Color? = nil,
        onDragEnded: @escaping (CGAffineTransform) -> Bool,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(MediaGestureViewModifier(
            minZoomScale: minZoomScale,
            doubleTapZoomScale: doubleTapZoomScale,
            outOfBoundsColor: outOfBoundsColor,
            onDragEnded: onDragEnded,
            onDismiss: onDismiss
        ))
    }
    
    func authorFlairText() -> some View {
        self.modifier(AuthorFlairTextViewModifier())
    }
    
    func filledButton() -> some View {
        self.modifier(FilledButtonViewModifier())
    }
    
    func urlTextField() -> some View {
        self.modifier(URLTextFieldViewModifier())
    }
}
