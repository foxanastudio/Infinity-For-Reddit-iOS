//
//  SubmitCommentView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-15.
//

import SwiftUI
import MarkdownUI
import PhotosUI
import MijickCamera
import GiphyUISDK

struct SubmitCommentView: View {
    @EnvironmentObject private var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var submitCommentViewModel: SubmitCommentViewModel
    
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var textViewCanFocus: Bool = true
    @State private var toolbarHeight: CGFloat = 0
    @FocusState private var markdownFocusedField: MarkdownFieldType?
    @State private var showMarkdownPreview = false
    @State private var cursorPosition: CGPoint = .zero
    @State private var showEmbeddedImagesSheet: Bool = false
    @State private var showGiphyGifSheet: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    init(parent: CommentParent) {
        _submitCommentViewModel = StateObject(
            wrappedValue: SubmitCommentViewModel(
                commentParent: parent,
                submitCommentRepository: SubmitCommentRepository(),
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
                                if let title = submitCommentViewModel.commentParent.title {
                                    RowText(title)
                                        .primaryText()
                                        .padding(.horizontal, 16)
                                        .padding(.top, 16)
                                        .padding(.bottom, 8)
                                } else {
                                    Spacer()
                                        .frame(height: 8)
                                }
                                
                                if let bodyProcessedMarkdown = submitCommentViewModel.commentParent.bodyProcessedMarkdown {
                                    Markdown(bodyProcessedMarkdown)
                                        .markdownImageProvider(
                                            MarkdownImageProvider(
                                                mediaMetadata: submitCommentViewModel.commentParent.mediaMetadata,
                                                isSensitive: submitCommentViewModel.commentParent.isSensitive,
                                                fullScreenMediaViewModel: fullScreenMediaViewModel
                                            )
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.top, 8)
                                        .padding(.bottom, 16)
                                        .themedPostContentMarkdown()
                                        .markdownLinkHandler { url in
                                            navigationManager.openLink(url)
                                        }
                                } else if let body = submitCommentViewModel.commentParent.body, !body.isEmpty {
                                    Markdown(body)
                                        .markdownImageProvider(
                                            MarkdownImageProvider(
                                                mediaMetadata: submitCommentViewModel.commentParent.mediaMetadata,
                                                isSensitive: submitCommentViewModel.commentParent.isSensitive,
                                                fullScreenMediaViewModel: fullScreenMediaViewModel
                                            )
                                        )
                                        .padding(.horizontal, 16)
                                        .padding(.top, 8)
                                        .padding(.bottom, 16)
                                        .themedPostContentMarkdown()
                                        .markdownLinkHandler { url in
                                            navigationManager.openLink(url)
                                        }
                                } else {
                                    Spacer()
                                        .frame(height: 8)
                                }
                                
                                CustomDivider()
                                
                                UserPicker {
                                    submitCommentViewModel.selectedAccount = $0
                                }
                                
                                MarkdownTextField(
                                    hint: "Your interesting thoughts here",
                                    text: $submitCommentViewModel.text,
                                    selectedRange: $selectedRange,
                                    canFocus: $textViewCanFocus,
                                    minHeight: 300
                                )
                                .contentShape(Rectangle())
                                .padding(16)
                            }
                        }
                        
                        Spacer()
                            .frame(height: toolbarHeight)
                    }
                    
                    MarkdownToolbar(
                        text: $submitCommentViewModel.text,
                        selectedRange: $selectedRange,
                        toolbarHeight: $toolbarHeight,
                        focusedField: $markdownFocusedField,
                        enableImageUpload: true,
                        enableGifChooser: true,
                        onImageUpload: {
                            showEmbeddedImagesSheet = true
                        },
                        onChooseGif: {
                            showGiphyGifSheet = true
                        }
                    )
                }
                
                KeyboardToolbar {
                    textViewCanFocus = false
                    markdownFocusedField = nil
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Send Comment")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    submitCommentViewModel.submitComment()
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: submitCommentViewModel.text)
        }
        .sheet(isPresented: $showEmbeddedImagesSheet) {
            MarkdownEmbeddedImagesSheet(embeddedImages: $submitCommentViewModel.embeddedImages, onCaptureImage: {
                showEmbeddedImagesSheet = false
                showCamera = true
            }, onSelectImage: {
                showEmbeddedImagesSheet = false
                showPhotoPicker = true
            }, onInsertImage: { uploadedImage, caption in
                showEmbeddedImagesSheet = false
                
                MarkdownUtils.insertImageOrGifIntoMarkdownString(
                    content: &submitCommentViewModel.text,
                    selectedRange: &selectedRange,
                    caption: caption,
                    imageOrGifId: uploadedImage.imageId ?? ""
                )
            })
        }
        .sheet(isPresented: $showGiphyGifSheet) {
            GiphyView()
                .onSelectMedia { media, contentType in
                    showGiphyGifSheet = false
                    submitCommentViewModel.giphyGif = media
                    
                    MarkdownUtils.insertImageOrGifIntoMarkdownString(
                        content: &submitCommentViewModel.text,
                        selectedRange: &selectedRange,
                        caption: "gif",
                        imageOrGifId: media.id
                    )
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .ignoresSafeArea(edges: .bottom)
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
                        submitCommentViewModel.addEmbeddedImage(capturedImage)
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
                    submitCommentViewModel.addEmbeddedImage(image)
                } else {
                    // Error handling
                }
                
                self.selectedPhotoItem = nil
            }
        }
        .onChange(of: submitCommentViewModel.submitCommentTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Submitting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: submitCommentViewModel.submittedComment) { _, newValue in
            if let submittedComment = newValue {
                commentSubmissionShareableViewModel.submittedComment = submittedComment
                snackbarManager.dismiss()
                dismiss()
            }
        }
        .showErrorUsingSnackbar(submitCommentViewModel.$error)
    }
}

enum CommentParent: Hashable {
    case post(parentPost: Post)
    case comment(parentComment: Comment)
    
    var parentFullname: String? {
        switch self {
        case .post(let parentPost):
            return parentPost.name
        case .comment(let parentComment):
            return parentComment.name
        }
    }
    
    var childCommentDepth: Int {
        switch self {
        case .post:
            return 0
        case .comment(let parentComment):
            return parentComment.depth + 1
        }
    }
    
    var title: String? {
        switch self {
        case .post(let parentPost):
            return parentPost.title
        case .comment:
            return nil
        }
    }
    
    var bodyProcessedMarkdown: MarkdownContent? {
        switch self {
        case .post(let parentPost):
            return parentPost.selftextProcessedMarkdown
        case .comment(let parentComment):
            return parentComment.bodyProcessedMarkdown
        }
    }
    
    var body: String? {
        switch self {
        case .post(let parentPost):
            return parentPost.selftext
        case .comment(let parentComment):
            return parentComment.body
        }
    }
    
    var mediaMetadata: [String: MediaMetadata]? {
        switch self {
        case .post(let parentPost):
            return parentPost.mediaMetadata
        case .comment(let parentComment):
            return parentComment.mediaMetadata
        }
    }
    
    var isSensitive: Bool {
        switch self {
        case .post(let parentPost):
            return parentPost.over18
        case .comment(let parentComment):
            return parentComment.over18
        }
    }
}
