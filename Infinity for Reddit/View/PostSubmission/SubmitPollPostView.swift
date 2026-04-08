//
// SubmitPollPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21
        
import SwiftUI
import MarkdownUI
import PhotosUI
import MijickCamera

struct SubmitPollPostView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var snackbarManager: SnackbarManager
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var submitPollPostViewModel: SubmitPollPostViewModel
    
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
        _submitPollPostViewModel = StateObject(
            wrappedValue: SubmitPollPostViewModel(
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
                                    submitPollPostViewModel.selectedAccount = $0
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
                                    text: $submitPollPostViewModel.title,
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
                                    text: $submitPollPostViewModel.content,
                                    selectedRange: $bodySelectedRange,
                                    canFocus: $contentTextViewCanFocus
                                )
                                .contentShape(Rectangle())
                                .padding(16)
                                
                                CustomDivider()
                                
                                Menu {
                                    ForEach(1..<8, id: \.self) { index in
                                        Button(index == 1 ? "1 day" : "\(index) days") {
                                            submitPollPostViewModel.votingDuration = index
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 8) {
                                        RowText("Voting Duration: \(submitPollPostViewModel.votingDuration) \(submitPollPostViewModel.votingDuration > 1 ? "days" : "day")")
                                            .primaryText()
                                        
                                        SwiftUI.Image(systemName: "chevron.down")
                                            .primaryIcon()
                                    }
                                    .padding(.horizontal, 16)
                                }
                                .padding(.top, 16)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(0..<6, id: \.self) { index in
                                        let placeholder = index < 2
                                        ? "Option \(index + 1) (Required)"
                                        : "Option \(index + 1)"
                                        
                                        CustomTextField(
                                            placeholder,
                                            text: $submitPollPostViewModel.pollOptions[index],
                                            singleLine: true,
                                            keyboardType: .default,
                                            showBorder: false,
                                            fieldType: .option(index),
                                            focusedField: $focusedField
                                        )
                                        .submitLabel(.done)
                                        .padding(.horizontal, 16)
                                        .padding(.top, 16)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(height: markdownToolbarHeight)
                    }
                    
                    MarkdownToolbar(
                        text: $submitPollPostViewModel.content,
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
        .addTitleToInlineNavigationBar("Poll Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    submitPollPostViewModel.submitPost(
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
            MarkdownViewerSheet(markdown: submitPollPostViewModel.content)
        }
        .sheet(isPresented: $showEmbeddedImagesSheet) {
            MarkdownEmbeddedImagesSheet(embeddedImages: $submitPollPostViewModel.embeddedImages, onCaptureImage: {
                showEmbeddedImagesSheet = false
                showCamera = true
            }, onSelectImage: {
                showEmbeddedImagesSheet = false
                showPhotoPicker = true
            }, onInsertImage: { uploadedImage, caption in
                showEmbeddedImagesSheet = false
                
                MarkdownUtils.insertImageOrGifIntoMarkdownString(
                    content: &submitPollPostViewModel.content,
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
                        submitPollPostViewModel.addEmbeddedImage(capturedImage)
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
                    submitPollPostViewModel.addEmbeddedImage(image)
                } else {
                    // Error handling
                }
                
                self.selectedPhotoItem = nil
            }
        }
        .onChange(of: submitPollPostViewModel.submitPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Submitting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: submitPollPostViewModel.submittedPostUrlString) { _, newValue in
            if let urlString = newValue {
                snackbarManager.dismiss()
                navigationManager.replaceCurrentScreen(urlString)
            }
        }
        .showErrorUsingSnackbar(submitPollPostViewModel.$error)
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
        case option(Int)
    }
}

