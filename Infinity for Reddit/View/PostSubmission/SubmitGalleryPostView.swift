//
// SubmitGalleryPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import SwiftUI
import MarkdownUI
import MijickCamera
import PhotosUI

struct SubmitGalleryPostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var submitGalleryPostViewModel: SubmitGalleryPostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    @FocusState private var focusedField: FieldType?
    
    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var bodySelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showMarkdownPreview: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var showCamera: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var showCaptionAndURLAlert: Bool = false
    @State private var caption: String = ""
    @State private var outboundUrlString: String = ""
    @State private var selectedImageIndex: Int? = nil
    @State private var showNoSubredditAlert: Bool = false
    
    init() {
        _postSubmissionContextViewModel = StateObject(
            wrappedValue: PostSubmissionContextViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
        )
        _submitGalleryPostViewModel = StateObject(
            wrappedValue: SubmitGalleryPostViewModel(
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
                                    submitGalleryPostViewModel.selectedAccount = $0
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
                                    text: $submitGalleryPostViewModel.title,
                                    singleLine: true,
                                    keyboardType: .default,
                                    showBorder: false,
                                    fieldType: .title,
                                    focusedField: $focusedField
                                )
                                .lineLimit(1...5)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                MarkdownTextField(hint: "Content", text: $submitGalleryPostViewModel.content, selectedRange: $bodySelectedRange, canFocus: $contentTextViewCanFocus)
                                    .contentShape(Rectangle())
                                    .padding(16)
                                
                                if !submitGalleryPostViewModel.galleryImages.isEmpty {
                                    GalleryGridView(
                                        galleryImages: submitGalleryPostViewModel.galleryImages,
                                        onSelectImage: {
                                            showPhotoPicker = true
                                        }, onCaptureImage: {
                                            showCamera = true
                                        },
                                        onSetCaptionAndUrl: { index in
                                            selectedImageIndex = index
                                            caption = submitGalleryPostViewModel.galleryImages[index].caption ?? ""
                                            outboundUrlString = submitGalleryPostViewModel.galleryImages[index].outboundUrlString ?? ""
                                            withAnimation(.linear(duration: 0.2)) {
                                                showCaptionAndURLAlert = true
                                            }
                                        },
                                        onDeleteImage: { index in
                                            submitGalleryPostViewModel.deleteCapturedImage(at: index)
                                        }
                                    )
                                    .padding(.horizontal, 16)
                                } else {
                                    AddMediaButton(onSelectImage: {
                                        showPhotoPicker = true
                                    }, onCaptureImage: {
                                        showCamera = true
                                    })
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(height: markdownToolbarHeight)
                        
                    }
                    
                    MarkdownToolbar(
                        text: $submitGalleryPostViewModel.content,
                        selectedRange: $bodySelectedRange,
                        toolbarHeight: $markdownToolbarHeight,
                        focusedField: $markdownToolbarFocusedField
                    )
                }
                
                KeyboardToolbar {
                    contentTextViewCanFocus = false
                    markdownToolbarFocusedField = nil
                    focusedField = nil
                }
            }
        }
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Gallery Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    submitGalleryPostViewModel.submitPost(
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
            MarkdownViewerSheet(markdown: submitGalleryPostViewModel.content)
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedPhotoItem,
            matching: .images
        )
        .onChange(of: selectedPhotoItem) { _, newSelectedItem in
            Task {
                if let selectedItem = newSelectedItem,
                   let imageData = try? await selectedItem.loadTransferable(type: Data.self),
                   let pickedImage = UIImage(data: imageData) {
                    submitGalleryPostViewModel.addImage(pickedImage)
                } else {
                    // Error handling
                }
            }
        }
        .onChange(of: submitGalleryPostViewModel.submitPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Submitting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: submitGalleryPostViewModel.submittedPostUrlString) { _, newValue in
            if let urlString = newValue {
                snackbarManager.dismiss()
                navigationManager.replaceCurrentScreen(urlString)
            }
        }
        .showErrorUsingSnackbar(submitGalleryPostViewModel.$error)
        .fullScreenCover(isPresented: $showCamera) {
            if Utils.checkCameraAvailability() {
                MCamera()
                    .onImageCaptured { capturedImage, controller in
                        submitGalleryPostViewModel.addImage(capturedImage)
                        controller.closeMCamera()
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
                    .filledButton()
                }
            }
        }
        .overlay(
            CustomAlert(title: "Set Caption and URL", confirmButtonText: "Done", isPresented: $showCaptionAndURLAlert) {
                CustomTextField(
                    "Caption (optional)",
                    text: $caption,
                    singleLine: true,
                    fieldType: .caption,
                    focusedField: $focusedField
                )
                .submitLabel(.done)
                
                CustomTextField(
                    "URL (optional)",
                    text: $outboundUrlString,
                    singleLine: true,
                    fieldType: .url,
                    focusedField: $focusedField
                )
                .submitLabel(.done)
                .urlTextField()
            } onConfirm: {
                if let selectedImageIndex {
                    submitGalleryPostViewModel.setCaptionAndUrlString(
                        index: selectedImageIndex,
                        caption: caption,
                        outboundUrlString: outboundUrlString
                    )
                }
            }
        )
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
        case caption
        case url
    }
}

private struct AddMediaButton: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    let buttonSize: CGFloat = 24
    
    let onSelectImage: () -> Void
    let onCaptureImage: () -> Void
    
    var body: some View {
        ZStack {
            Menu {
                Button("Select an image") {
                    onSelectImage()
                }
                
                Button("Capture an image") {
                    onCaptureImage()
                }
            } label: {
                SwiftUI.Image(systemName: "photo.fill.on.rectangle.fill")
                    .font(.system(size: buttonSize))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Circle().fill(Color(hex: customThemeViewModel.currentCustomTheme.colorAccent)))
            }
        }
        .padding(16)
    }
}

private struct GalleryGridView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    let galleryImages: [UploadedImage]
    let onSelectImage: () -> Void
    let onCaptureImage: () -> Void
    let onSetCaptionAndUrl: (Int) -> Void
    let onDeleteImage: (Int) -> Void
    
    let maxImageCount: Int = 20
    
    var body: some View {
        LazyVGrid(
            columns:[
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(Array(galleryImages.enumerated()), id: \.offset) { index, image in
                ZStack(alignment: .topTrailing) {
                    GeometryReader { geo in
                        UploadedImageView(
                            uploadedImage: image,
                            width: geo.size.width,
                            height: geo.size.height,
                            centerCrop: true
                        ) {
                            onSetCaptionAndUrl(index)
                        }
                    }
                    
                    Button {
                        onDeleteImage(index)
                    } label: {
                        SwiftUI.Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(hex: customThemeViewModel.currentCustomTheme.backgroundColor))
                            .background(
                                Circle()
                                    .fill(Color(hex: customThemeViewModel.currentCustomTheme.colorPrimary))
                            )
                            .font(.system(size: 20))
                            .padding(6)
                    }
                }
                .aspectRatio(1, contentMode: .fill)
            }
            
            if galleryImages.count < maxImageCount {
                GeometryReader { geometry in
                    AddMediaButton(onSelectImage: onSelectImage, onCaptureImage: onCaptureImage)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .aspectRatio(1, contentMode: .fit)
            }
        }
    }
}


