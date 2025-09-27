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
    @StateObject private var postSubmissionContextViewModel: PostSubmissionContextViewModel
    @StateObject private var submitImagePostViewModel: SubmitImagePostViewModel
    
    @FocusState private var markdownToolbarFocusedField: MarkdownFieldType?
    @FocusState private var focusedField: FieldType?
    
    @State private var contentTextViewCanFocus: Bool = true
    @State private var markdownToolbarHeight: CGFloat = 0
    @State private var titleSelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var bodySelectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var showMarkdownPreview: Bool = false
    @State private var cursorPosition: CGPoint = .zero
    @State private var showCamera: Bool = false
    @State private var showPhotoPicker: Bool = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    
    init() {
        _postSubmissionContextViewModel = StateObject(
            wrappedValue: PostSubmissionContextViewModel(ruleRepository: RuleRepository(), flairRepository: FlairRepository())
        )
        _submitImagePostViewModel = StateObject(wrappedValue: SubmitImagePostViewModel())
    }
    
    var body: some View {
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
                            }
                            
                            Divider()
                            
                            PostSubmissionContextView(postSubmissionContextViewModel: postSubmissionContextViewModel)
                            
                            Divider()
                            
                            CustomTextField(
                                "Title",
                                text: $submitImagePostViewModel.title,
                                singleLine: true,
                                keyboardType: .default,
                                showBorder: false,
                                fieldType: .title,
                                focusedField: $focusedField
                            )
                            .padding(16)
                            
                            VStack {
                                ZStack(alignment: .topLeading) {
                                    MarkdownTextField(text: $submitImagePostViewModel.content, selectedRange: $bodySelectedRange, canFocus: $contentTextViewCanFocus)
                                        .contentShape(Rectangle())
                                    
                                    if submitImagePostViewModel.content.isEmpty {
                                        Text("Content")
                                            .secondaryText()
                                    }
                                    
                                }
                                .padding(16)
                                
                                SubmitImageToolbar(
                                    onCameraTap: { showCamera = true },
                                    onPhotoPickerTap: { showPhotoPicker = true }
                                )
                                .frame(maxWidth: .infinity)
                                .photosPicker(
                                    isPresented: $showPhotoPicker,
                                    selection: $selectedPhotoItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                )
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
                    print("Submit Text Post")
                } label: {
                    SwiftUI.Image(systemName: "paperplane.fill")
                }
            }
        }
        .sheet(isPresented: $showMarkdownPreview) {
            MarkdownViewerSheet(markdown: submitImagePostViewModel.content)
        }
        .fullScreenCover(isPresented: $showCamera) {
            MCamera()
                .onImageCaptured { capturedImage, controller in
                    submitImagePostViewModel.capturedImage = capturedImage
                    print("Captured Image: \(capturedImage.description)")
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
        }
        .onChange(of: selectedPhotoItem) { _, newSelectedItem in
            Task {
                if let selectedItem = newSelectedItem,
                   let imageData = try? await selectedItem.loadTransferable(type: Data.self),
                   let pickedImage = UIImage(data: imageData) {
                    submitImagePostViewModel.capturedImage = pickedImage
                    print("Picked Image: \(pickedImage.description)")
                }
            }
        }
    }
    
    private enum FieldType: Hashable {
        case title
    }
}

