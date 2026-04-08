//
//  EditCommentView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-31.
//

import SwiftUI
import MarkdownUI
import PhotosUI
import MijickCamera
import GiphyUISDK

struct EditCommentView: View {
    @EnvironmentObject private var commentSubmissionShareableViewModel: CommentSubmissionShareableViewModel
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var editCommentViewModel: EditCommentViewModel
    
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
    
    init(commentToBeEdited: Comment) {
        _editCommentViewModel = StateObject(
            wrappedValue: EditCommentViewModel(
                commentToBeEdited: commentToBeEdited,
                editCommentRepository: EditCommentRepository(),
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
                                if let bodyProcessedMarkdown = editCommentViewModel.commentToBeEdited.bodyProcessedMarkdown {
                                    Markdown(bodyProcessedMarkdown)
                                        .markdownImageProvider(
                                            MarkdownImageProvider(
                                                mediaMetadata: editCommentViewModel.commentToBeEdited.mediaMetadata,
                                                isSensitive: editCommentViewModel.commentToBeEdited.over18,
                                                fullScreenMediaViewModel: fullScreenMediaViewModel
                                            )
                                        )
                                        .padding(16)
                                        .themedPostContentMarkdown()
                                        .markdownLinkHandler { url in
                                            navigationManager.openLink(url)
                                        }
                                } else if let body = editCommentViewModel.commentToBeEdited.body, !body.isEmpty {
                                    Markdown(body)
                                        .markdownImageProvider(
                                            MarkdownImageProvider(
                                                mediaMetadata: editCommentViewModel.commentToBeEdited.mediaMetadata,
                                                isSensitive: editCommentViewModel.commentToBeEdited.over18,
                                                fullScreenMediaViewModel: fullScreenMediaViewModel
                                            )
                                        )
                                        .padding(16)
                                        .themedPostContentMarkdown()
                                        .markdownLinkHandler { url in
                                            navigationManager.openLink(url)
                                        }
                                } else {
                                    Spacer()
                                        .frame(height: 8)
                                }
                                
                                CustomDivider()
                                
                                MarkdownTextField(
                                    hint: "Your new interesting thoughts here",
                                    text: $editCommentViewModel.text,
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
                        text: $editCommentViewModel.text,
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
        .addTitleToInlineNavigationBar("Edit Comment")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    editCommentViewModel.editComment()
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: editCommentViewModel.text)
        }
        .sheet(isPresented: $showEmbeddedImagesSheet) {
            MarkdownEmbeddedImagesSheet(embeddedImages: $editCommentViewModel.embeddedImages, onCaptureImage: {
                showEmbeddedImagesSheet = false
                showCamera = true
            }, onSelectImage: {
                showEmbeddedImagesSheet = false
                showPhotoPicker = true
            }, onInsertImage: { uploadedImage, caption in
                showEmbeddedImagesSheet = false
                
                MarkdownUtils.insertImageOrGifIntoMarkdownString(
                    content: &editCommentViewModel.text,
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
                    editCommentViewModel.giphyGifId = media.id
                    
                    MarkdownUtils.insertImageOrGifIntoMarkdownString(
                        content: &editCommentViewModel.text,
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
                        editCommentViewModel.addEmbeddedImage(capturedImage)
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
                    editCommentViewModel.addEmbeddedImage(image)
                } else {
                    // Error handling
                }
                
                self.selectedPhotoItem = nil
            }
        }
        .onChange(of: editCommentViewModel.editCommentTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Editing. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: editCommentViewModel.editCommentResult) { _, newValue in
            if let editCommentResult = newValue {
                switch editCommentResult {
                case .comment(let comment):
                    commentSubmissionShareableViewModel.editedComment = comment
                    snackbarManager.dismiss()
                    dismiss()
                case .content(let content):
                    editCommentViewModel.commentToBeEdited.body = content
                    editCommentViewModel.commentToBeEdited.bodyProcessedMarkdown = MarkdownContent(content)
                    commentSubmissionShareableViewModel.editedComment = editCommentViewModel.commentToBeEdited
                    snackbarManager.showSnackbar(.info("Comment edited, but couldn’t fetch the update. Please refresh."))
                    dismiss()
                }
            }
        }
        .showErrorUsingSnackbar(editCommentViewModel.$error)
    }
}
