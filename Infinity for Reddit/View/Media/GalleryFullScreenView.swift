//
//  GalleryFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-05.
//

import SwiftUI

struct GalleryFullScreenView: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject private var namespaceManager: NamespaceManager
    
    @ObservedObject private var galleryScrollState: GalleryScrollState
    @GestureState private var dragOffset: CGSize = .zero
    @State private var currentDragOffset = 0.0
    @State private var hasStartedDragging: Bool = false
    @State private var isAnimatingBack: Bool = false
    
    var items: [GalleryItem]
    let onDismiss: () -> Void
    
    init(items: [GalleryItem], galleryScrollState: GalleryScrollState, onDismiss: @escaping () -> Void) {
        self.items = items
        self.galleryScrollState = galleryScrollState
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(opacityForBackground())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            TabView(selection: $galleryScrollState.scrollId) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    ZoomableScrollView {
                        CustomWebImage(
                            item.urlString,
                            handleImageTapGesture: false
                        )
                        .offset(y: currentDragOffset)
                    }
                    .containerRelativeFrame(.horizontal, count: 1, span: 1, spacing: 0, alignment: .center)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    // Only allow vertical drag to trigger dismiss
                    if !hasStartedDragging && abs(value.translation.height) > abs(value.translation.width) {
                        hasStartedDragging = true
                    }
                    if hasStartedDragging {
                        state = value.translation
                    }
                }
                .onChanged { value in
                    // Adjust the scale based on the drag distance
                    currentDragOffset = value.translation.height
                }
                .onEnded { value in
                    if hasStartedDragging && abs(value.translation.height) > 100 {
                        withAnimation(.linear(duration: 0.25)) {
                            if value.translation.height < 0 {
                                // Dragged up
                                currentDragOffset = -UIScreen.main.bounds.height
                            } else {
                                // Dragged down
                                currentDragOffset = UIScreen.main.bounds.height
                            }
                        } completion: {
                            onDismiss()
                        }
                    } else {
                        withAnimation {
                            currentDragOffset = 0.0
                        }
                    }
                    hasStartedDragging = false
                }
        )
    }
    
    private func opacityForBackground() -> Double {
        let maxOffset: CGFloat = UIScreen.main.bounds.height
        let offset = min(abs(currentDragOffset), maxOffset)
        return Double(1 - (offset / maxOffset))
    }
}
