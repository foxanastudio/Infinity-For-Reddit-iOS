//
//  EditPostView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-02.
//

import SwiftUI
import MarkdownUI
import PhotosUI
import MijickCamera

struct EditPostView: View {
    @EnvironmentObject private var postEditingShareableViewModel: PostEditingShareableViewModel
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var editPostViewModel: EditPostViewModel
    
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var textViewCanFocus: Bool = true
    @State private var toolbarHeight: CGFloat = 0
    @FocusState private var markdownFocusedField: MarkdownFieldType?
    @State private var showMarkdownPreview = false
    @State private var cursorPosition: CGPoint = .zero
    @State private var showEmbeddedImagesSheet: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    init(postToBeEdited: Post) {
        _editPostViewModel = StateObject(
            wrappedValue: EditPostViewModel(
                postToBeEdited: postToBeEdited,
                editPostRepository: EditPostRepository(),
                mediaUploadRepository: MediaUploadRepository()
            )
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            if let bodyProcessedMarkdown = editPostViewModel.postToBeEdited.selftextProcessedMarkdown {
                                Markdown(bodyProcessedMarkdown)
                                    .markdownImageProvider(
                                        MarkdownImageProvider(
                                            mediaMetadata: editPostViewModel.postToBeEdited.mediaMetadata,
                                            isSensitive: editPostViewModel.postToBeEdited.over18,
                                            fullScreenMediaViewModel: fullScreenMediaViewModel,
                                            onFullScreenVideo: { videoUrlString in
                                                fullScreenMediaViewModel.show(
                                                    .video(urlString: videoUrlString, videoType: .direct, canDownload: false)
                                                )
                                            }
                                        )
                                    )
                                    .padding(16)
                                    .themedPostContentMarkdown()
                                    .markdownLinkHandler { url in
                                        navigationManager.openLink(url)
                                    }
                            } else if let selftext = editPostViewModel.postToBeEdited.selftext, !selftext.isEmpty {
                                Markdown(selftext)
                                    .markdownImageProvider(
                                        MarkdownImageProvider(
                                            mediaMetadata: editPostViewModel.postToBeEdited.mediaMetadata,
                                            isSensitive: editPostViewModel.postToBeEdited.over18,
                                            fullScreenMediaViewModel: fullScreenMediaViewModel,
                                            onFullScreenVideo: { videoUrlString in
                                                fullScreenMediaViewModel.show(
                                                    .video(urlString: videoUrlString, videoType: .direct, canDownload: false)
                                                )
                                            }
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
                                text: $editPostViewModel.text,
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
                    text: $editPostViewModel.text,
                    selectedRange: $selectedRange,
                    toolbarHeight: $toolbarHeight,
                    focusedField: $markdownFocusedField,
                    enableImageUpload: true,
                    onImageUpload: {
                        showEmbeddedImagesSheet = true
                    }
                )
            }
            
            KeyboardToolbar {
                textViewCanFocus = false
                markdownFocusedField = nil
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Edit Post Body")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    editPostViewModel.editPost()
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: editPostViewModel.text)
        }
        .sheet(isPresented: $showEmbeddedImagesSheet) {
            MarkdownEmbeddedImagesSheet(embeddedImages: $editPostViewModel.embeddedImages, onCaptureImage: {
                showEmbeddedImagesSheet = false
                showCamera = true
            }, onSelectImage: {
                showEmbeddedImagesSheet = false
                showPhotoPicker = true
            }, onInsertImage: { uploadedImage, caption in
                showEmbeddedImagesSheet = false
                
                MarkdownUtils.insertImageOrGifIntoMarkdownString(
                    content: &editPostViewModel.text,
                    selectedRange: &selectedRange,
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
                        editPostViewModel.addEmbeddedImage(capturedImage)
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
                    editPostViewModel.addEmbeddedImage(image)
                } else {
                    // Error handling
                }
                
                self.selectedPhotoItem = nil
            }
        }
        .onChange(of: editPostViewModel.editPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Editing. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: editPostViewModel.editPostResult) { _, newValue in
            if let editPostResult = newValue {
                switch editPostResult {
                case .post(let post):
                    postEditingShareableViewModel.editedPost = post
                    snackbarManager.dismiss()
                    dismiss()
                case .content(let content):
                    editPostViewModel.postToBeEdited.selftext = content
                    editPostViewModel.postToBeEdited.selftextProcessedMarkdown = MarkdownContent(content)
                    postEditingShareableViewModel.editedPost = editPostViewModel.postToBeEdited
                    snackbarManager.showSnackbar(.info("Comment edited, but couldn’t fetch the update. Please refresh."))
                    dismiss()
                }
            }
        }
        .showErrorUsingSnackbar(editPostViewModel.$error)
    }
}
