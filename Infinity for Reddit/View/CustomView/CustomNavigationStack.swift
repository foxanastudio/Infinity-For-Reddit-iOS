//
//  CustomNavigationStack.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-29.
//

import SwiftUI

struct CustomNavigationStack<Content: View>: View {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject private var navigationManager = NavigationManager()
    @StateObject var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel = CommentSubmissionShareableViewModel()
    @StateObject var subredditChooseViewModel: SubredditChooseViewModel = SubredditChooseViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
    
    let content: () -> Content
    
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
                    case .postDetailsWithId(let postId, let commentId):
                        PostDetailsView(account: self.accountViewModel.account,
                                        postDetailsInput: PostDetailsInput.postAndCommentId(postId: postId, commentId: commentId),
                                        isFromSubredditPostListing: false
                        )
                        .environmentObject(navigationManager)
                        .environmentObject(commentSubmissionShareableViewModel)
                    case .subredditDetails(let subredditName):
                        SubredditDetailsView(subredditName: subredditName)
                            .environmentObject(navigationManager)
                    case .userDetails(let username):
                        UserDetailsView(username: username)
                            .environmentObject(navigationManager)
                    case .search(let query, let searchInSubredditOrUserName, searchInMultiReddit: let searchInMultiReddit, searchInThingType: let searchInThingType):
                        SearchResultsView(query: query, searchInSubredditOrUserName: searchInSubredditOrUserName, searchInMultiReddit: searchInMultiReddit, searchInThingType: searchInThingType)
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
                    case .submitTextPost:
                        SubmitTextPostView()
                            .environmentObject(navigationManager)
                            .environmentObject(subredditChooseViewModel)
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
                    case .chooseSubredditForNewPost:
                        SubredditSelectionView()
                            .environmentObject(navigationManager)
                            .environmentObject(subredditChooseViewModel)
                    case .filterPosts(let postListingMetadata):
                        CustomizePostFilterView(PostFilter()) { postFilter in
                            navigationManager.path.removeLast()
                            navigationManager.path.append(
                                AppNavigation.filteredPosts(
                                    postListingMetadata: postListingMetadata,
                                    postFilter: postFilter
                                )
                            )
                        }
                        .environmentObject(navigationManager)
                    case .filteredPosts(let postListingMetadata, let postFilter):
                        FilteredPostsView(
                            postListingMetadata: postListingMetadata,
                            postFilter: postFilter
                        )
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
                    case .downloadLocation:
                        DownloadLocationSettingsView()
                            .environmentObject(navigationManager)
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
                    case .privacyPolicy:
                        PrivacyPolicySettingsView()
                            .environmentObject(navigationManager)
                    case .redditUserAgreement:
                        RedditUserAgreementSettingsView()
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
                .environmentObject(navigationManager)
        }
        .themedNavigationBarBackButton()
    }
}
