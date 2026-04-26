//
//  StyledView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-21.
//

import SwiftUI
import Combine

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
    
    func primaryText(_ fontSize: AppFontSize = .f17) -> some View {
        self.modifier(PrimaryTextViewModifier(fontSize: fontSize))
    }
    
    func secondaryText(_ fontSize: AppFontSize = .f17) -> some View {
        self.modifier(SecondaryTextViewModifier(fontSize: fontSize))
    }
    
    func buttonText(_ fontSize: AppFontSize = .f17) -> some View {
        self.modifier(ButtonTextViewModifier(fontSize: fontSize))
    }
    
    func navigationBarPrimaryText() -> some View {
        self.modifier(NavigationBarPrimaryTextViewModifier())
    }

    func navigationBarTitleGlassEffect() -> some View {
        self.modifier(NavigationBarTitleGlassEffectViewModifier())
    }
    
    func linkText(_ fontSize: AppFontSize = .f17) -> some View {
        self.modifier(LinkTextViewModifier(fontSize: fontSize))
    }
    
    func themedNavigationBar(opacity: Double = 1) -> some View {
        self.modifier(NavigationBarViewModifier(opacity: opacity))
    }
    
    func addTitleToInlineNavigationBar(_ title: String, _ opacity: Double = 1.0) -> some View {
        self.modifier(InlineNavigationBarWithTitle(title: title, opacity: opacity))
    }
    
    func navigationBarImage() -> some View {
        self.modifier(NavigationBarImageViewModifier())
    }
    
    func themedNavigationBarButton() -> some View {
        self.modifier(NavigationBarButtonViewModifier())
    }
    
    func themedTabView() -> some View {
        self.modifier(TabViewCustomThemeViewModifier())
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
    
    func voteAndReplyUnavailbleIcon() -> some View {
        self.modifier(VoteAndReplyUnavailableIconViewModifier())
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
    
    func postTitle(isRead: Bool) -> some View {
        self.modifier(PostTitleTextViewModifier(isRead: isRead))
    }
    
    func postContent(isRead: Bool) -> some View {
        self.modifier(PostContentTextViewModifier(isRead: isRead))
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
    
    func fabIcon() -> some View {
        self.modifier(FabIconImageViewModifier())
    }
    
    func themedPicker() -> some View {
        self.modifier(PickerCustomThemeViewModifier())
    }
    
    func themedToggle() -> some View {
        self.modifier(ToggleCustomThemeViewModifier())
    }
    
    func themedMarkdown(_ fontSize: AppFontSize = .f17) -> some View {
        self.modifier(MarkdownViewModifier(fontSize: fontSize))
    }
    
    func themedPostContentMarkdown(_ fontSize: AppFontSize = .f15) -> some View {
        self.modifier(PostContentMarkdownViewModifier(fontSize: fontSize))
    }
    
    func themedCommentMarkdown(_ fontSize: AppFontSize = .f15) -> some View {
        self.modifier(CommentMarkdownViewModifier(fontSize: fontSize))
    }
    
    func themedChatMessageMarkdown(_ fontSize: AppFontSize = .f17, isSentMessage: Bool) -> some View {
        self.modifier(ChatMessageMarkdownViewModifier(fontSize: fontSize, isSentMessage: isSentMessage))
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
    
    func mediaTapGesture(post: Post?, aspectRatio: CGSize?) -> some View {
        self.modifier(MediaTapGestureHandlerViewModifer(post: post, aspectRatio: aspectRatio))
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
    
    func stickiedTag() -> some View {
        self.modifier(StickiedTagViewModifier())
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
        onAppEntersInactive: (() -> Void)? = nil,
        onAppEntersBackground: (() -> Void)? = nil
    ) -> some View {
        self.modifier(AppForegroundBackgroundViewModifier(
            onAppEntersForeground: onAppEntersForeground,
            onAppEntersInactive: onAppEntersInactive,
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
        outOfBoundsColor: Color = .black,
        onDragEnded: @escaping (CGAffineTransform) -> Bool,
        onStartDismiss: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(MediaGestureViewModifier(
            minZoomScale: minZoomScale,
            doubleTapZoomScale: doubleTapZoomScale,
            outOfBoundsColor: outOfBoundsColor,
            onDragEnded: onDragEnded,
            onStartDismiss: onStartDismiss,
            onDismiss: onDismiss
        ))
    }
    
    func tabItemMediaGesture(
        dismissStarted: Binding<Bool>,
        childViewHasZoomed: Bool,
        onDismiss: @escaping () -> Void
    ) -> some View {
        self.modifier(TabViewGestureViewModifier(
            dismissStarted: dismissStarted,
            childViewHasZoomed: childViewHasZoomed,
            onDismiss: onDismiss
        ))
    }
    
    func tabItemMediaGesture(
        minZoomScale: CGFloat = 1,
        doubleTapZoomScale: CGFloat = 2,
        childViewHasZoomed: Binding<Bool>
    ) -> some View {
        self.modifier(TabItemMediaGestureViewModifier(
            minZoomScale: minZoomScale,
            doubleTapZoomScale: doubleTapZoomScale,
            childViewHasZoomed: childViewHasZoomed
        ))
    }
    
    func authorFlairText() -> some View {
        self.modifier(AuthorFlairTextViewModifier())
    }
    
    func filledButton(elevate: Bool = true) -> some View {
        self.modifier(FilledButtonViewModifier(elevate: elevate))
    }
    
    func subscribeButton(isSubscribed: Bool) -> some View {
        self.modifier(SubscribeButtonViewModifier(isSubscribed: isSubscribed))
    }
    
    func urlTextField() -> some View {
        self.modifier(URLTextFieldViewModifier())
    }
    
    func wrapContentSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        showDragIndicator: Bool = true,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(
            WrapContentSheetViewModifier(
                isPresented: isPresented,
                showDragIndicator: showDragIndicator,
                sheetContent: content
            )
        )
    }
    
    func onVisiblePercentageChange(
        in space: CoordinateSpace = .global,
        _ action: @escaping (CGFloat) -> Void
    ) -> some View {
        modifier(VisiblePercentageModifier(onChange: action, space: space))
    }
    
    func showErrorUsingSnackbar<P: Publisher>(
        _ errorPublisher: P,
        showTaskCancelledError: Bool = false
    ) -> some View where P.Output == Error?, P.Failure == Never {
        self.modifier(SnackbarErrorViewModifier(errorPublisher: errorPublisher, showTaskCancelledError: showTaskCancelledError))
    }
    
    func limitedWidth() -> some View {
        self.modifier(LimitedWidthViewModifier())
    }
}
