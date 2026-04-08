//
// SubmitLinkPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21
        
import SwiftUI
import MarkdownUI

struct SubmitLinkPostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var submitLinkPostViewModel: SubmitLinkPostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    @FocusState private var focusedField: FieldType?
    
    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var bodySelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showMarkdownPreview: Bool = false
    @State private var cursorPosition: CGPoint = .zero
    @State private var showNoSubredditAlert: Bool = false
    
    init() {
        _postSubmissionContextViewModel = StateObject(
            wrappedValue: PostSubmissionContextViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
        )
        _submitLinkPostViewModel = StateObject(
            wrappedValue: SubmitLinkPostViewModel(submitPostRepository: SubmitPostRepository())
        )
    }
    
    var body: some View {
        RootView {
            VStack(spacing: 0) {
                ZStack {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 0) {
                                UserPicker {
                                    submitLinkPostViewModel.selectedAccount = $0
                                }
                                
                                PostSubmissionSubredditChooserView(postSubmissionContextViewModel: postSubmissionContextViewModel) { subscribedSubredditData in
                                    postSubmissionContextViewModel.selectedSubreddit = subscribedSubredditData
                                } onShowNoSubredditAlert: {
                                    showNoSubredditAlert = true
                                }
                                
                                CustomDivider()
                                
                                PostSubmissionContextView(postSubmissionContextViewModel: postSubmissionContextViewModel)
                                
                                CustomDivider()
                                
                                HStack {
                                    CustomTextField(
                                        "Title",
                                        text: $submitLinkPostViewModel.title,
                                        keyboardType: .default,
                                        showBorder: false,
                                        fieldType: .title,
                                        focusedField: $focusedField
                                    )
                                    .lineLimit(1...5)
                                    
                                    Button("Suggest Title") {
                                        submitLinkPostViewModel.suggestTitle()
                                    }
                                    .filledButton(elevate: false)
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                CustomTextField(
                                    "URL",
                                    text: $submitLinkPostViewModel.urlString,
                                    singleLine: true,
                                    keyboardType: .URL,
                                    showBorder: false,
                                    fieldType: .url,
                                    focusedField: $focusedField
                                )
                                .submitLabel(.done)
                                .urlTextField()
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                MarkdownTextField(
                                    hint: "Content",
                                    text: $submitLinkPostViewModel.content,
                                    selectedRange: $bodySelectedRange,
                                    canFocus: $contentTextViewCanFocus,
                                    minHeight: 300
                                )
                                .contentShape(Rectangle())
                                .padding(16)
                            }
                        }
                        
                        Spacer().frame(height: markdownToolbarHeight)
                        
                    }
                    
                    MarkdownToolbar(
                        text: $submitLinkPostViewModel.content,
                        selectedRange: $bodySelectedRange,
                        toolbarHeight: $markdownToolbarHeight,
                        focusedField: $markdownToolbarFocusedField
                    )
                }
                
                KeyboardToolbar {
                    contentTextViewCanFocus = false
                    markdownToolbarFocusedField = nil
                    focusedField = nil
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Link Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    submitLinkPostViewModel.submitPost(
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
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: submitLinkPostViewModel.content)
        }
        .onChange(of: submitLinkPostViewModel.submitPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Submitting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: submitLinkPostViewModel.submittedPostId) { _, newValue in
            if let id = newValue {
                snackbarManager.dismiss()
                navigationManager.replaceCurrentScreen(AppNavigation.postDetailsWithId(postId: id))
            }
        }
        .showErrorUsingSnackbar(submitLinkPostViewModel.$error)
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
        case title, url
    }
}
