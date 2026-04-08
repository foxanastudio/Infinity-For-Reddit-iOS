//
// SubmitImagePostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import SwiftUI
import MarkdownUI
import MijickCamera
import PhotosUI

struct SubmitImagePostView: View {
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var submitImagePostViewModel: SubmitImagePostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    @FocusState private var focusedField: FieldType?
    
    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var bodySelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showMarkdownPreview: Bool = false
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showNoSubredditAlert: Bool = false
    
    init() {
        _postSubmissionContextViewModel = StateObject(
            wrappedValue: PostSubmissionContextViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
        )
        _submitImagePostViewModel = StateObject(
            wrappedValue: SubmitImagePostViewModel(
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
                                    submitImagePostViewModel.selectedAccount = $0
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
                                    text: $submitImagePostViewModel.title,
                                    keyboardType: .default,
                                    showBorder: false,
                                    fieldType: .title,
                                    focusedField: $focusedField
                                )
                                .lineLimit(1...5)
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                                
                                MarkdownTextField(hint: "Content", text: $submitImagePostViewModel.content, selectedRange: $bodySelectedRange, canFocus: $contentTextViewCanFocus, minHeight: 100)
                                    .contentShape(Rectangle())
                                    .padding(16)
                                
                                if let previewImage = submitImagePostViewModel.image {
                                    VStack(spacing: 16) {
                                        Button(action: {
                                            submitImagePostViewModel.clearCapturedImage()
                                        }) {
                                            Text("Select again")
                                                .colorAccentText()
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        
                                        SwiftUI.Image(uiImage: previewImage)
                                            .resizable()
                                            .scaledToFit()
                                            .cornerRadius(8)
                                    }
                                    .padding(.horizontal, 16)
                                } else {
                                    SelectImageToolbar(
                                        onCameraTap: { showCamera = true },
                                        onPhotoPickerTap: { showPhotoPicker = true }
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                        
                        Spacer()
                            .frame(height: markdownToolbarHeight)
                        
                    }
                    
                    MarkdownToolbar(
                        text: $submitImagePostViewModel.content,
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
        .addTitleToInlineNavigationBar("Image Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    submitImagePostViewModel.submitPost(
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
            MarkdownViewerSheet(markdown: submitImagePostViewModel.content)
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
                        submitImagePostViewModel.setImage(image: capturedImage)
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
                    .filledButton(elevate: false)
                }
            }
        }
        .onChange(of: selectedPhotoItem) { _, newValue in
            guard let newValue else {
                return
            }
            
            Task {
                if let imageData = try? await newValue.loadTransferable(type: Data.self),
                   let image = UIImage(data: imageData) {
                    printInDebugOnly(Utils.isGIF(imageData: imageData))
                    submitImagePostViewModel.setImage(image: image, imageData: imageData, isGIF: Utils.isGIF(imageData: imageData))
                } else {
                    // Error handling
                }
                
                self.selectedPhotoItem = nil
            }
        }
        .onChange(of: submitImagePostViewModel.submitPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    .info("Submitting. Please wait..."),
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: submitImagePostViewModel.postSubmittedFlag) { _, newValue in
            if newValue {
                snackbarManager.showSnackbar(.info("Post submitted successfully. Your image is being processed."))
                dismiss()
            }
        }
        .showErrorUsingSnackbar(submitImagePostViewModel.$error)
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

private struct SelectImageToolbar: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    let onCameraTap: () -> Void
    let onPhotoPickerTap: () -> Void
    
    let buttonSize: CGFloat = 24
    
    var body: some View {
        HStack(spacing: 32) {
            Button {
                onCameraTap()
            } label: {
                SwiftUI.Image(systemName: "camera.fill")
                    .font(.system(size: buttonSize))
                    .foregroundColor(.white)
                    .padding(16)
                    .background(Circle().fill(Color(hex: customThemeViewModel.currentCustomTheme.colorAccent)))
            }
            
            Button {
                onPhotoPickerTap()
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
