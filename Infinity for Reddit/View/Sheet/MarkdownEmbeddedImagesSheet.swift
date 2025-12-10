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
    
    let onCaptureImage: () -> Void
    let onSelectImage: () -> Void
    let onInsertImage: (UploadedImage, String) -> Void
    
    var body: some View {
        SheetRootView {
            VStack(spacing: 0) {
                RowText("Choose an image to insert into your post content.")
                    .primaryText()
                    .padding(16)
                    .font(.system(size: 24, weight: .bold))
                
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
                    .filledButton()
                    .excludeFromTouchRipple()
                    
                    Button {
                        onSelectImage()
                    } label: {
                        Text("Select an Image")
                            .buttonText()
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .filledButton()
                    .excludeFromTouchRipple()
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
    }
    
    private enum FieldType: Hashable {
        case caption
    }
}
