//
//  VideoFullScreenView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-06.
//

import SwiftUI
import AVKit

struct VideoFullScreenView: View {
    @EnvironmentObject var fullScreenMediaViewModel: FullScreenMediaViewModel
    @EnvironmentObject var namespaceManager: NamespaceManager
    
    @StateObject private var videoFullScreenViewModel: VideoFullScreenViewModel
    @State private var scale: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    @State private var currentDragOffset: CGSize = .zero
    @State private var hasStartedDragging: Bool = false
    @State private var isAnimatingBack: Bool = false
    
    let url: URL
    let onDismiss: () -> Void
    
    init(url: URL, onDismiss: @escaping () -> Void) {
        self.url = url
        self.onDismiss = onDismiss
        _videoFullScreenViewModel = StateObject(wrappedValue: VideoFullScreenViewModel(url: url))
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(opacityForBackground())
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
            
            VideoPlayer(player: videoFullScreenViewModel.player)
                .onDisappear {
                    videoFullScreenViewModel.player.pause()
                }
                .onAppear {
                    videoFullScreenViewModel.player.play()
                }
                .frame(height: 400)
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
                    if hasStartedDragging {
                        currentDragOffset.height = value.translation.height
                        currentDragOffset.width = value.translation.width
                        scale = max(1 - (abs(currentDragOffset.height) / 1000), 0.5) // Minimum scale of 0.7
                    }
                }
                .onEnded { value in
                    if hasStartedDragging && abs(value.translation.height) > 100 {
                        withAnimation {
                            onDismiss()
                        }
                    } else {
                        withAnimation {
                            currentDragOffset = .zero
                            scale = 1.0
                        }
                    }
                    hasStartedDragging = false
                }
        )
    }
    
    private func opacityForBackground() -> Double {
        let maxOffset: CGFloat = 300
        let offset = min(abs(currentDragOffset.height), maxOffset)
        return Double(1 - (offset / maxOffset))
    }
}
