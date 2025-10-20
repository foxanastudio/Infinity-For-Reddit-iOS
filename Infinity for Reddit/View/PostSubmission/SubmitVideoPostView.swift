//
// SubmitVideoPostView.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-21

import SwiftUI
import MarkdownUI
import MijickCamera
import PhotosUI
import AVKit

struct SubmitVideoPostView: View {
    @EnvironmentObject private var snackbarManager: SnackbarManager
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var submitVideoPostViewModel: SubmitVideoPostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    @FocusState private var focusedField: FieldType?
    
    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var bodySelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showMarkdownPreview: Bool = false
    @State private var showCamera: Bool = false
    @State private var showVideoPicker: Bool = false
    @State private var selectedVideoItem: PhotosPickerItem? = nil
    
    init() {
        _postSubmissionContextViewModel = StateObject(
            wrappedValue: PostSubmissionContextViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
        )
        _submitVideoPostViewModel = StateObject(
            wrappedValue: SubmitVideoPostViewModel(
                submitPostRepository: SubmitPostRepository(),
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
                            UserPicker {
                                submitVideoPostViewModel.selectedAccount = $0
                            }
                            
                            PostSubmissionSubredditChooserView(postSubmissionContextViewModel: postSubmissionContextViewModel) { subscribedSubredditData in
                                postSubmissionContextViewModel.selectedSubreddit = subscribedSubredditData
                            }
                            
                            Divider()
                            
                            PostSubmissionContextView(postSubmissionContextViewModel: postSubmissionContextViewModel)
                            
                            Divider()
                            
                            CustomTextField(
                                "Title",
                                text: $submitVideoPostViewModel.title,
                                singleLine: true,
                                keyboardType: .default,
                                showBorder: false,
                                fieldType: .title,
                                focusedField: $focusedField
                            )
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            
                            ZStack(alignment: .topLeading) {
                                MarkdownTextField(text: $submitVideoPostViewModel.content, selectedRange: $bodySelectedRange, canFocus: $contentTextViewCanFocus)
                                    .contentShape(Rectangle())
                                
                                if submitVideoPostViewModel.content.isEmpty {
                                    Text("Content")
                                        .secondaryText()
                                }
                            }
                            .padding(16)
                            
                            SelectVideoToolbar(
                                onCameraTap: { showCamera = true },
                                onPhotoPickerTap: { showVideoPicker = true }
                            )
                            .frame(maxWidth: .infinity)
                            
                            
//                            if let thumbnail = submitVideoPostViewModel.thumbnail {
//                                SwiftUI.Image(uiImage: thumbnail)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(maxWidth: .infinity)
//                                    .frame(height: 200)
//                                    .padding(.horizontal, 16)
//                                    .padding(.top, 8)
//                            }
                            
                            if let videoURL = submitVideoPostViewModel.videoURL {
                                InlineVideoPlayer(videoURL: videoURL, aspectRatio: nil, muteVideo: true)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 400)
                                    .cornerRadius(8)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                            }
                        }
                    }
                    
                    Spacer()
                        .frame(height: markdownToolbarHeight)
                    
                }
                
                MarkdownToolbar(
                    text: $submitVideoPostViewModel.content,
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
        .frame(maxHeight: .infinity)
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Video Post")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showMarkdownPreview = true
                } label: {
                    SwiftUI.Image(systemName: "eye")
                }
                
                Button {
                    submitVideoPostViewModel.submitPost(
                        subreddit: postSubmissionContextViewModel.selectedSubreddit,
                        flair: postSubmissionContextViewModel.selectedFlair,
                        isSpoiler: postSubmissionContextViewModel.isSpoiler,
                        isSensitive: postSubmissionContextViewModel.isSensitive,
                        receivePostReplyNotifications: postSubmissionContextViewModel.receivePostReplyNotification,
                        isRichTextJSON: false
                    )
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: submitVideoPostViewModel.content)
        }
        .photosPicker(
            isPresented: $showVideoPicker,
            selection: $selectedVideoItem,
            matching: .videos,
            photoLibrary: .shared()
        )
        .onChange(of: selectedVideoItem) { _, newItem in
            Task {
                guard let newItem else {
                    print("No video selected")
                    return
                }

                do {
                    print("Importing video…")
                    if let movie = try await newItem.loadTransferable(type: Movie.self) {
                        print("Video imported:", movie.url)
                        submitVideoPostViewModel.setVideo(url: movie.url)
                    } else {
                        print("Failed to import video (Movie returned nil)")
                    }
                } catch {
                    print("Error loading video:", error)
                }
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            if Utils.checkCameraAvailability() {
                MCamera()
                    .onVideoCaptured { videoURL, controller in
                        submitVideoPostViewModel.setVideo(url: videoURL)
                        controller.closeMCamera()
                    }
                    .setCloseMCameraAction {
                        showCamera = false
                    }
                    .setCameraOutputType(.video)
                    .setAudioAvailability(true)
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
        .onChange(of: submitVideoPostViewModel.submitPostTask) { _, newValue in
            if newValue != nil {
                snackbarManager.showSnackbar(
                    text: "Submitting. Please wait...",
                    autoDismiss: false,
                    canDismissByGesture: false
                )
            }
        }
        .onChange(of: submitVideoPostViewModel.postSubmittedFlag) { _, newValue in
            if newValue {
                snackbarManager.showSnackbar(text: "Post submitted successfully. Your image is being processed.")
                dismiss()
            }
        }
        .onReceive(submitVideoPostViewModel.$error) { newValue in
            if let error = newValue {
                snackbarManager.showSnackbar(text: error.localizedDescription)
            }
        }
    }
    
    private enum FieldType: Hashable {
        case title
    }
}

private struct SelectVideoToolbar: View {
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

struct Movie: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
            
            if FileManager.default.fileExists(atPath: copy.path()) {
                try FileManager.default.removeItem(at: copy)
            }
            
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self.init(url: copy)
        }
    }
}
