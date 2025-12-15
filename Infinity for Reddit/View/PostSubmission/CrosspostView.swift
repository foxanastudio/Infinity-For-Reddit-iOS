//
//  CrosspostView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-18.
//

import SwiftUI
import MarkdownUI

struct CrosspostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var crosspostViewModel: CrosspostViewModel
    
    @FocusState private var focusedField: FieldType?

    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showNoSubredditAlert: Bool = false
    
    init(postToBeCrossposted: Post) {
        _postSubmissionContextViewModel = StateObject(
            wrappedValue: PostSubmissionContextViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
        )
        _crosspostViewModel = StateObject(
            wrappedValue: CrosspostViewModel(
                postToBeCrossposted: postToBeCrossposted,
                submitPostRepository: SubmitPostRepository()
            )
        )
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        UserPicker {
                            crosspostViewModel.selectedAccount = $0
                        }
                        
                        PostSubmissionSubredditChooserView(postSubmissionContextViewModel: postSubmissionContextViewModel) { subscribedSubredditData in
                            postSubmissionContextViewModel.selectedSubreddit = subscribedSubredditData
                        } onShowNoSubredditAlert: {
                            showNoSubredditAlert = true
                        }
                        
                        CustomDivider()
                        
                        PostSubmissionContextView(postSubmissionContextViewModel: postSubmissionContextViewModel)
                        
                        CustomDivider()
                        
                        CustomTextField(
                            "Title",
                            text: $crosspostViewModel.title,
                            keyboardType: .default,
                            showBorder: false,
                            fieldType: .title,
                            focusedField: $focusedField
                        )
                        .lineLimit(1...5)
                        .padding(16)
                        
                        if crosspostViewModel.postToBeCrossposted.postType == .noPreviewLink || crosspostViewModel.postToBeCrossposted.postType == .link {
                            RowText(crosspostViewModel.postToBeCrossposted.url)
                                .secondaryText()
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        } else if let galleryData = crosspostViewModel.postToBeCrossposted.galleryData,
                                  !galleryData.items.isEmpty,
                                  let mediaMetadata = crosspostViewModel.postToBeCrossposted.mediaMetadata,
                                  let preview = mediaMetadata[galleryData.items[0].mediaId] {
                            // May not have a preview!!!!!!
                            GalleryCarousel(post: crosspostViewModel.postToBeCrossposted)
                                .applyIf(preview.s?.aspectRatio != nil) {
                                    $0.aspectRatio(preview.s!.aspectRatio, contentMode: .fit)
                                }
                        } else if case .redditVideo(let videoUrlString, _) = crosspostViewModel.postToBeCrossposted.postType {
                            PostVideoView(post: crosspostViewModel.postToBeCrossposted, videoUrlString: videoUrlString)
                        } else if case .video(let videoUrlString, _) = crosspostViewModel.postToBeCrossposted.postType {
                            PostVideoView(post: crosspostViewModel.postToBeCrossposted, videoUrlString: videoUrlString)
                        } else if crosspostViewModel.postToBeCrossposted.postType.isMedia {
                            PostPreviewView(post: crosspostViewModel.postToBeCrossposted)
                        }
                        
                        if let selftext = crosspostViewModel.postToBeCrossposted.selftextProcessedMarkdown {
                            Markdown(selftext)
                                .markdownImageProvider(
                                    MarkdownImageProvider(
                                        mediaMetadata: crosspostViewModel.postToBeCrossposted.mediaMetadata,
                                        isSensitive: crosspostViewModel.postToBeCrossposted.over18,
                                        fullScreenMediaViewModel: fullScreenMediaViewModel,
                                        onFullScreenVideo: { videoUrlString in
                                            fullScreenMediaViewModel.show(
                                                .video(urlString: videoUrlString, videoType: .direct, canDownload: false)
                                            )
                                        }
                                    )
                                )
                                .font(.system(size: 24))
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                                .themedPostCommentMarkdown()
                                .markdownLinkHandler { url in
                                    navigationManager.openLink(url)
                                }
                        }
                    }
                }
                
                KeyboardToolbar {
                    focusedField = nil
                }
            }
        }
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Crosspost")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    crosspostViewModel.submitPost(
                        subreddit: postSubmissionContextViewModel.selectedSubreddit,
                        flair: postSubmissionContextViewModel.selectedFlair,
                        isSpoiler: postSubmissionContextViewModel.isSpoiler,
                        isSensitive: postSubmissionContextViewModel.isSensitive,
                        receivePostReplyNotifications: postSubmissionContextViewModel.receivePostReplyNotification
                    )
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .onChange(of: crosspostViewModel.submitPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Submitting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: crosspostViewModel.submittedPostId) { _, newValue in
            if let id = newValue {
                snackbarManager.dismiss()
                navigationManager.replaceCurrentScreen(AppNavigation.postDetailsWithId(postId: id))
            }
        }
        .showErrorUsingSnackbar(crosspostViewModel.$error)
        .overlay(
            CustomAlert<EmptyView>(
                title: "No Subreddit Selected",
                confirmButtonText: "OK",
                showDismissButton: false,
                isPresented: $showNoSubredditAlert
            )
        )
    }
    
    private enum FieldType: Hashable {
        case title
    }
}
