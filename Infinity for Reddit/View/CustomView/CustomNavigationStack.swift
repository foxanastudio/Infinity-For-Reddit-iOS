//
//  CustomNavigationStack.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-29.
//

import SwiftUI

struct CustomNavigationStack<Content: View>: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject private var navigationManager: NavigationManager
    @StateObject var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel = CommentSubmissionShareableViewModel()
    @StateObject var postEditingShareableViewModel: PostEditingShareableViewModel = PostEditingShareableViewModel()
    
    let content: () -> Content
    
    init(fullScreenMediaViewModel: FullScreenMediaViewModel, @ViewBuilder content: @escaping () -> Content) {
        _navigationManager = StateObject(wrappedValue: NavigationManager(fullScreenMediaViewModel: fullScreenMediaViewModel))
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
                    case .postDetails(let postDetailsInput, let isFromSubredditPostListing):
                        PostDetailsView(account: self.accountViewModel.account, postDetailsInput: postDetailsInput, isFromSubredditPostListing: isFromSubredditPostListing)
                            .environmentObject(navigationManager)
                            .environmentObject(commentSubmissionShareableViewModel)
                            .environmentObject(postEditingShareableViewModel)
                    case .postDetailsWithId(let postId, let commentId, let isContinueThread):
                        PostDetailsView(account: self.accountViewModel.account,
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
                    case .searchResults(let query, let searchInSubredditOrUserName, let searchInMultiReddit, let searchInThingType):
                        SearchResultsView(query: query,
                                          searchInSubredditOrUserName: searchInSubredditOrUserName,
                                          searchInMultiReddit: searchInMultiReddit,
                                          searchInThingType: searchInThingType
                        )
                        .environmentObject(navigationManager)
                    case .customFeed(let myCustomFeed):
                        CustomFeedDetailsView(myCustomFeed: myCustomFeed)
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
                    case .profile:
                        UserDetailsView(username: self.accountViewModel.account.username)
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
                        EmptyView()
                    case .proxy:
                        EmptyView()
                    case .postHistory:
                        PostHistorySettingsView()
                            .environmentObject(navigationManager)
                    case .contentSensitivityFilter:
                        ContentSensitivityFilterSettingsView()
                            .environmentObject(navigationManager)
                    case .postFilter:
                        PostFilterSettingsView()
                            .environmentObject(navigationManager)
                    case .createOrEditPostFilter(let postFilter):
                        CustomizePostFilterView(postFilter)
                            .environmentObject(navigationManager)
                    case .postFilterUsageListing(let postFilterId):
                        PostFilterUsageListingView(postFilterId: postFilterId)
                            .environmentObject(navigationManager)
                    case .commentFilter:
                        CommentFilterSettingsView()
                            .environmentObject(navigationManager)
                    case .createOrEditCommentFilter(let commentFilter):
                        CustomizeCommentFilterView(commentFilter)
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
                    case .customizeCustomTheme(let customTheme):
                        CustomizeCustomThemeView(customTheme: customTheme)
                            .environmentObject(navigationManager)
                    case .customThemeListing:
                        CustomThemeListingView()
                            .environmentObject(navigationManager)
                    }
                }
                .navigationDestination(for: InterfaceSettingsViewNavigation.self) { destination in
                    switch destination {
                    case .font:
                        FontInterfaceView()
                    case .timeFormat:
                        InterfaceTimeFormatView()
                    case .post:
                        InterfacePostSettingsView()
                    case .postDetails:
                        InterfacePostDetailsSettingsView()
                    case .comment:
                        InterfaceCommentSettingsView()
                    }
                }
                .environmentObject(navigationManager)
        }
        .themedNavigationBarBackButton()
    }
}
