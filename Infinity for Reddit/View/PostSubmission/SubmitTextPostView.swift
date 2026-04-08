//
// SubmitTextPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import SwiftUI
import MarkdownUI
import PhotosUI
import MijickCamera

struct SubmitTextPostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var submitTextPostViewModel: SubmitTextPostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    @FocusState private var focusedField: FieldType?

    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var bodySelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showMarkdownPreview: Bool = false
    @State private var cursorPosition: CGPoint = .zero
    @State private var showEmbeddedImagesSheet: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showNoSubredditAlert: Bool = false
    
    init() {
        _postSubmissionContextViewModel = StateObject(
            wrappedValue: PostSubmissionContextViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
        )
        _submitTextPostViewModel = StateObject(
            wrappedValue: SubmitTextPostViewModel(
                submitPostRepository: SubmitPostRepository(),
                mediaUploadRepository: MediaUploadRepository()
            )
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
                                    submitTextPostViewModel.selectedAccount = $0
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
                                    text: $submitTextPostViewModel.title,
                                    keyboardType: .default,
                                    showBorder: false,
                                    fieldType: .title,
                                    focusedField: $focusedField
                                )
                                .lineLimit(1...5)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)

                                MarkdownTextField(
                                    hint: "Content",
                                    text: $submitTextPostViewModel.content,
                                    selectedRange: $bodySelectedRange,
                                    canFocus: $contentTextViewCanFocus,
                                    minHeight: 300
                                )
                                .contentShape(Rectangle())
                                .padding(16)
                            }
                        }
                        
                        Spacer()
                            .frame(height: markdownToolbarHeight)
                    }
                    
                    MarkdownToolbar(
                        text: $submitTextPostViewModel.content,
                        selectedRange: $bodySelectedRange,
                        toolbarHeight: $markdownToolbarHeight,
                        focusedField: $markdownToolbarFocusedField,
                        enableImageUpload: true,
                        onImageUpload: {
                            showEmbeddedImagesSheet = true
                        }
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
        .addTitleToInlineNavigationBar("Text Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    submitTextPostViewModel.submitPost(
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
            MarkdownViewerSheet(markdown: submitTextPostViewModel.content)
        }
        .sheet(isPresented: $showEmbeddedImagesSheet) {
            MarkdownEmbeddedImagesSheet(embeddedImages: $submitTextPostViewModel.embeddedImages, onCaptureImage: {
                showEmbeddedImagesSheet = false
                showCamera = true
            }, onSelectImage: {
                showEmbeddedImagesSheet = false
                showPhotoPicker = true
            }, onInsertImage: { uploadedImage, caption in
                showEmbeddedImagesSheet = false
                
                MarkdownUtils.insertImageOrGifIntoMarkdownString(
                    content: &submitTextPostViewModel.content,
                    selectedRange: &bodySelectedRange,
                    caption: caption,
                    imageOrGifId: uploadedImage.imageId ?? ""
                )
            })
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images,
            photoLibrary: .shared()
        )
        .fullScreenCover(isPresented: $showCamera) {
            if Utils.checkCameraAvailability() {
                MCamera()
                    .onImageCaptured { capturedImage, controller in
                        submitTextPostViewModel.addEmbeddedImage(capturedImage)
                        controller.closeMCamera()
                        showEmbeddedImagesSheet = true
                    }
                    .setCloseMCameraAction {
                        showCamera = false
                    }
                    .setCameraOutputType(.photo)
                    .setAudioAvailability(false)
                    .setCameraScreen { cameraManager, id, closeMCameraAction in
                        DefaultCameraScreen(
                            cameraManager: cameraManager,
                            namespace: id,
                            closeMCameraAction: closeMCameraAction
                        ).cameraOutputSwitchAllowed(false)
                    }
                    .startSession()
            } else {
                VStack {
                    Text("Camera not available")
                        .padding(.bottom, 60)
                    
                    Button("Close") {
                        showCamera = false
                    }
                    .filledButton(elevate: false)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else {
                return
            }
            
            showEmbeddedImagesSheet = true
            Task {
                if let imageData = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: imageData) {
                    printInDebugOnly(Utils.isGIF(imageData: imageData))
                    submitTextPostViewModel.addEmbeddedImage(image)
                } else {
                    // Error handling
                }
                
                self.selectedPhotoItem = nil
            }
        }
        .onChange(of: submitTextPostViewModel.submitPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Submitting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: submitTextPostViewModel.submittedPostId) { _, newValue in
            if let id = newValue {
                snackbarManager.dismiss()
                navigationManager.replaceCurrentScreen(AppNavigation.postDetailsWithId(postId: id))
            }
        }
        .showErrorUsingSnackbar(submitTextPostViewModel.$error)
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
