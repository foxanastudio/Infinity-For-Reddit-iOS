//
//  CustomNavigationStack.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-29.
//

import SwiftUI

struct CustomNavigationStack<Content: View>: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @ObservedObject private var navigationManager: NavigationManager
    
    @StateObject var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel = CommentSubmissionShareableViewModel()
    @StateObject var postEditingShareableViewModel: PostEditingShareableViewModel = PostEditingShareableViewModel()
    
    @AppStorage(GesturesButtonsUserDefaultsUtils.hideNavigationBarOnScrollDownKey, store: .gesturesButtons) private var hideNavigationBarOnScrollDown: Bool = false
    
    let content: () -> Content
    
    init(navigationManager: NavigationManager, @ViewBuilder content: @escaping () -> Content) {
        self.navigationManager = navigationManager
        self.content = content
    }
    
    var body: some View {
        NavigationStack(path: $navigationManager.path) {
            content()
                .navigationDestination(for: AppNavigation.self) { destination in
                    switch destination {
                    case .login:
                        LoginView()
                            .environmentObject(navigationManager)
                    case .postDetails(let postDetailsInput, let isFromSubredditPostListing, let videoPlaybackTime):
                        PostDetailsView(postDetailsInput: postDetailsInput, isFromSubredditPostListing: isFromSubredditPostListing, videoPlaybackTime: videoPlaybackTime)
                            .environmentObject(navigationManager)
                            .environmentObject(commentSubmissionShareableViewModel)
                            .environmentObject(postEditingShareableViewModel)
                    case .postDetailsWithId(let postId, let commentId, let isContinueThread):
                        PostDetailsView(
                            postDetailsInput: PostDetailsInput.postAndCommentId(postId: postId, commentId: commentId),
                            isFromSubredditPostListing: false,
                            isContinueThread: isContinueThread
                        )
                        .environmentObject(navigationManager)
                        .environmentObject(commentSubmissionShareableViewModel)
                        .environmentObject(postEditingShareableViewModel)
                    case .subredditDetails(let subredditName):
                        SubredditDetailsView(subredditName: subredditName)
                            .environmentObject(navigationManager)
                    case .userDetails(let username):
                        UserDetailsView(username: username)
                            .environmentObject(navigationManager)
                            .environmentObject(commentSubmissionShareableViewModel)
                    case .search:
                        SearchView()
                            .environmentObject(navigationManager)
                    case .searchResults(let query, let searchInSubredditOrUserName, let searchInMultiReddit, let searchInThingType, let searchResultTab):
                        SearchResultsView(
                            query: query,
                            searchInSubredditOrUserName: searchInSubredditOrUserName,
                            searchInMultiReddit: searchInMultiReddit,
                            searchInThingType: searchInThingType,
                            searchResultTab: searchResultTab
                        )
                        .environmentObject(navigationManager)
                    case .customFeed(let customFeed):
                        CustomFeedDetailsView(customFeed: customFeed)
                            .environmentObject(navigationManager)
                    case .inboxConversation(let inbox):
                        InboxConversationView(inbox: inbox)
                            .environmentObject(navigationManager)
                    case .submitComment(let commentParent):
                        SubmitCommentView(parent: commentParent)
                            .environmentObject(navigationManager)
                            .environmentObject(commentSubmissionShareableViewModel)
                    case .editComment(let commentToBeEdited):
                        EditCommentView(commentToBeEdited: commentToBeEdited)
                            .environmentObject(navigationManager)
                            .environmentObject(commentSubmissionShareableViewModel)
                    case .submitTextPost:
                        SubmitTextPostView()
                            .environmentObject(navigationManager)
                    case .submitLinkPost:
                        SubmitLinkPostView()
                            .environmentObject(navigationManager)
                    case .submitVideoPost:
                        SubmitVideoPostView()
                            .environmentObject(navigationManager)
                    case .submitImagePost:
                        SubmitImagePostView()
                            .environmentObject(navigationManager)
                    case .submitGalleryPost:
                        SubmitGalleryPostView()
                            .environmentObject(navigationManager)
                    case .submitPollPost:
                        SubmitPollPostView()
                            .environmentObject(navigationManager)
                    case .filterPosts(let postListingMetadata):
                        CustomizePostFilterView(PostFilter()) { postFilter in
                            navigationManager.replaceCurrentScreen(AppNavigation.filteredPosts(
                                postListingMetadata: postListingMetadata,
                                postFilter: postFilter
                            ))
                        }
                        .environmentObject(navigationManager)
                    case .filterHistoryPosts(let historyPostListingMetadata):
                        CustomizePostFilterView(PostFilter()) { postFilter in
                            navigationManager.replaceCurrentScreen(AppNavigation.filteredHistoryPosts(
                                historyPostListingMetadata: historyPostListingMetadata,
                                postFilter: postFilter
                            ))
                        }
                        .environmentObject(navigationManager)
                    case .filteredPosts(let postListingMetadata, let postFilter):
                        FilteredPostsView(
                            postListingMetadata: postListingMetadata,
                            postFilter: postFilter
                        )
                        .environmentObject(navigationManager)
                    case .filteredHistoryPosts(let historyPostListingMetadata, let postFilter):
                        FilteredHistoryPostsView(
                            historyPostListingMetadata: historyPostListingMetadata,
                            postFilter: postFilter
                        )
                        .environmentObject(navigationManager)
                    case .editPost(let post):
                        EditPostView(postToBeEdited: post)
                            .environmentObject(navigationManager)
                            .environmentObject(postEditingShareableViewModel)
                    case .crosspost(let postToBeCrossposted):
                        CrosspostView(postToBeCrossposted: postToBeCrossposted)
                            .environmentObject(navigationManager)
                    case .sendChatMessage(let recipient):
                        SendChatMessageView(recipient: recipient)
                            .environmentObject(navigationManager)
                    case .createCustomFeed:
                        CreateOrEditCustomFeedView()
                            .environmentObject(navigationManager)
                    case .editCustomFeed(let customFeedToEdit):
                        CreateOrEditCustomFeedView(customFeedToEdit: customFeedToEdit)
                            .environmentObject(navigationManager)
                    case .copyCustomFeed(let path):
                        CopyCustomFeedView(path: path)
                            .environmentObject(navigationManager)
                    case .report(let subredditName, let thingFullname):
                        ReportView(subredditName: subredditName, thingFullname: thingFullname)
                            .environmentObject(navigationManager)
                    case .wiki(let subredditName, let wikiPath):
                        WikiView(subredditName: subredditName, wikiPath: wikiPath)
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: MoreViewNavigation.self) { destination in
                    switch destination {
                    case .popular:
                        PopularOrAllView(subredditName: "popular")
                            .environmentObject(navigationManager)
                    case .all:
                        PopularOrAllView(subredditName: "all")
                            .environmentObject(navigationManager)
                    case .history:
                        HistoryView()
                            .environmentObject(navigationManager)
                    case .upvoted:
                        UpvotedView()
                            .environmentObject(navigationManager)
                    case .downvoted:
                        DownvotedView()
                            .environmentObject(navigationManager)
                    case .hidden:
                        HiddenView()
                            .environmentObject(navigationManager)
                    case .saved:
                        SavedView()
                            .environmentObject(navigationManager)
                            .environmentObject(commentSubmissionShareableViewModel)
                    case .settings:
                        SettingsView()
                            .environmentObject(navigationManager)
                    case .test:
                        TestView()
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: SettingsViewNavigation.self) { destination in
                    switch destination {
                    case .notification:
                        NotificationSettingsView()
                            .environmentObject(navigationManager)
                    case .interface:
                        InterfaceSettingsView()
                            .environmentObject(navigationManager)
                    case .theme:
                        CustomThemeSettingsView()
                            .environmentObject(navigationManager)
                    case .video:
                        VideoSettingsView()
                            .environmentObject(navigationManager)
                    case .gesturesAndButtons:
                        GestureButtonsSettingsView()
                            .environmentObject(navigationManager)
                    case .security:
                        SecuritySettingsView()
                            .environmentObject(navigationManager)
                    case .dataSavingMode:
                        DataSavingModeSettingsView()
                            .environmentObject(navigationManager)
                    case .proxy:
                        ProxySettingsView()
                    case .postHistory:
                        PostHistorySettingsView()
                            .environmentObject(navigationManager)
                    case .contentSensitivityFilter:
                        ContentSensitivityFilterSettingsView()
                            .environmentObject(navigationManager)
                    case .postFilter(let postToBeAdded, let subredditToBeAdded, let userToBeAdded):
                        PostFilterSettingsView(postToBeAdded: postToBeAdded, subredditToBeAdded: subredditToBeAdded, userToBeAdded: userToBeAdded)
                            .environmentObject(navigationManager)
                    case .createOrEditPostFilter(let postFilter, let postToBeAdded, let subredditToBeAdded, let userToBeAdded, let selectedFieldsToAddToPostFilter):
                        CustomizePostFilterView(postFilter, postToBeAdded: postToBeAdded, subredditToBeAdded: subredditToBeAdded, userToBeAdded: userToBeAdded, selectedFieldsToAddToPostFilter: selectedFieldsToAddToPostFilter)
                            .environmentObject(navigationManager)
                    case .postFilterUsageListing(let postFilterId):
                        PostFilterUsageListingView(postFilterId: postFilterId)
                            .environmentObject(navigationManager)
                    case .commentFilter(let commentToBeAdded):
                        CommentFilterSettingsView(commentToBeAdded: commentToBeAdded)
                            .environmentObject(navigationManager)
                    case .createOrEditCommentFilter(let commentFilter, let commentToBeAdded, let selectedFieldsToAddToCommentFilter):
                        CustomizeCommentFilterView(commentFilter, commentToBeAdded: commentToBeAdded, selectedFieldsToAddToCommentFilter: selectedFieldsToAddToCommentFilter)
                            .environmentObject(navigationManager)
                    case .commentFilterUsageListing(let commentFilterId):
                        CommentFilterUsageListingView(commentFilterId: commentFilterId)
                            .environmentObject(navigationManager)
                    case .sortType:
                        SortTypeSettingsView()
                    case .miscellaneous:
                        MiscellaneousSettingsView()
                            .environmentObject(navigationManager)
                    case .advanced:
                        AdvancedSettingsView()
                            .environmentObject(navigationManager)
                    case .manageSubscription:
                        ManageSubscriptionSettingsView()
                            .environmentObject(navigationManager)
                    case .about:
                        AboutSettingsView()
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: CustomThemeSettingsViewNavigation.self) { destination in
                    switch destination {
                    case .customizeCustomTheme(let customThemeId, let predefindCustomThemeName):
                        CustomizeCustomThemeView(customThemeId: customThemeId, predefindCustomThemeName: predefindCustomThemeName)
                            .environmentObject(navigationManager)
                    case .customThemeListing:
                        CustomThemeListingView()
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: InterfaceSettingsViewNavigation.self) { destination in
                    switch destination {
                    case .font:
                        InterfaceFontSettingsView()
                            .environmentObject(navigationManager)
                    case .timeFormat:
                        InterfaceTimeFormatSettingsView()
                    case .post:
                        InterfacePostSettingsView()
                    case .postDetails:
                        InterfacePostDetailsSettingsView()
                    case .comment:
                        InterfaceCommentSettingsView()
                    }
                }
                .navigationDestination(for: AboutSettingsViewNavigation.self) { destination in
                    switch destination {
                    case .acknowledgement:
                        AcknowledgementView()
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: FontSettingsViewNavigation.self) { destination in
                    switch destination {
                    case .fontPreview:
                        InterfaceFontFontPreviewSettingsView()
                    }
                }
                .environmentObject(navigationManager)
        }
        .themedNavigationBarButton()
        .onChange(of: navigationManager.path) { _, newValue in
            let newCount = newValue.count
            if navigationManager.viewShouldHideNavigationBarOnScroll.count > newCount {
                navigationManager.viewShouldHideNavigationBarOnScroll = Array(navigationManager.viewShouldHideNavigationBarOnScroll.prefix(newCount))
            }
        }
        .introspect(.navigationStack, on: .iOS(.v16, .v17, .v18, .v26)) {
            // UINavigationController
            $0.hidesBarsOnSwipe = hideNavigationBarOnScrollDown && navigationManager.hideNavigationBarOnScrollDown
        }
    }
}
