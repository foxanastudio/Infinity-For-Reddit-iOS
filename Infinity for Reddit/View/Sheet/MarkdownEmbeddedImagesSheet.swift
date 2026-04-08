//
//  MarkdownEmbeddedImagesSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-18.
//

import SwiftUI

struct MarkdownEmbeddedImagesSheet: View {
    @Binding var embeddedImages: [UploadedImage]
    
    @FocusState private var focusedField: FieldType?
    
    @State private var showCaptionAlert: Bool = false
    @State private var caption: String = ""
    @State private var selectedImage: UploadedImage?
    @State private var showInfoSheet: Bool = false
    
    let onCaptureImage: () -> Void
    let onSelectImage: () -> Void
    let onInsertImage: (UploadedImage, String) -> Void
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    RowText("Tap an image to add a caption and insert it into your post.")
                        .primaryText(.f20)
                        .fontWeight(.bold)
                    
                    Button {
                        showInfoSheet = true
                    } label: {
                        SwiftUI.Image(systemName: "info.circle")
                            .font(.system(size: 24))
                            .primaryIcon()
                    }
                }
                .padding(16)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(maximum: .infinity)),
                            GridItem(.flexible(maximum: .infinity))
                        ],
                        alignment: .leading,
                        spacing: 16
                    ) {
                        ForEach(embeddedImages, id: \.id) { embeddedImage in
                            UploadedImageView(uploadedImage: embeddedImage, onImageTapped: {
                                caption = ""
                                selectedImage = embeddedImage
                                withAnimation(.linear(duration: 0.2)) {
                                    showCaptionAlert = true
                                }
                            })
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button {
                        onCaptureImage()
                    } label: {
                        Text("Capture")
                            .buttonText()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .filledButton(elevate: false)
                    
                    Button {
                        onSelectImage()
                    } label: {
                        Text("Select an Image")
                            .buttonText()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .filledButton(elevate: false)
                }
                .padding(.horizontal, 32)
            }
        }
        .overlay(
            CustomAlert(title: "Set Caption", isPresented: $showCaptionAlert) {
                CustomTextField("Caption (optional)",
                                text: $caption,
                                singleLine: true,
                                fieldType: .caption,
                                focusedField: $focusedField)
                .submitLabel(.done)
            } onConfirm: {
                if let selectedImage {
                    onInsertImage(selectedImage, caption)
                }
            }
        )
        .sheet(isPresented: $showInfoSheet) {
            MarkdownEmbeddedImagesInfoSheet()
        }
    }
    
    private enum FieldType: Hashable {
        case caption
    }
}

private struct MarkdownEmbeddedImagesInfoSheet: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RowText("This is an experimental feature, and here are some things you need to know:")
                    .primaryText()
                    .fontWeight(.bold)
                
                RowText(
    """
    1. Uploaded images will not be shown in the text editor, and instead, a piece of text will be inserted as a block, with a format similar to ![](XXXXX). XXXXX is the image id, and it should not be modified. To change the caption foryour image, simply type between the brackets. Example: ![This is a caption](XXXXX). Note that the caption will be treated as plain text.\n
    2. To write a superscript, please use ^(), and put the texts inside the parentheses, instead of only using a single ^. For simplicity, click the superscript option in the formatting tools to insert a superscript.\n
    3. This feature converts your markdown to rich text format and some formatting may be lost in the process.\n
    4. Uploaded images may not be shown on the preview screen.\n
    5. You cannot edit a submitted post with embedded images in it.\n
    6. Please do not change your account using the account chooser on the editing screen. You should switch your account by tapping on your profile image icon in the navigation bar on the main screen.
    """
                )
            }
            .padding(16)
        }
    }
}
