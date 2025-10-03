//
//  ZoomableScrollView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-06.
//

import SwiftUI

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
    var content: Content
    var onSingleTap: () -> Void
    @Binding var currentZoomScale: CGFloat

    private let singleTap = UITapGestureRecognizer()
    private let doubleTap = UITapGestureRecognizer()

    init(@ViewBuilder content: () -> Content, onSingleTap: @escaping () -> Void, currentZoomScale: Binding<CGFloat>) {
        self.content = content()
        self.onSingleTap = onSingleTap
        self._currentZoomScale = currentZoomScale
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 4.0
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(hostedView)
        
        NSLayoutConstraint.activate([
            hostedView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostedView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostedView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostedView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostedView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            hostedView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
        ])

        let doubleTap = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        let singleTap = UITapGestureRecognizer(target: context.coordinator,
                                               action: #selector(Coordinator.handleSingleTap))
        singleTap.numberOfTapsRequired = 1

        singleTap.delegate = context.coordinator
        scrollView.addGestureRecognizer(singleTap)

        singleTap.require(toFail: doubleTap)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content
        context.coordinator.onSingleTap = onSingleTap
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(content: content, onSingleTap: onSingleTap, currentZoomScale: $currentZoomScale)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UIScrollViewDelegate, UIGestureRecognizerDelegate {
        var hostingController: UIHostingController<Content>
        var onSingleTap: () -> Void
        var zoomScaleBinding: Binding<CGFloat> // Store the binding wrapper
        
        init(content: Content, onSingleTap: @escaping () -> Void, currentZoomScale: Binding<CGFloat>) {
            self.hostingController = UIHostingController(rootView: content)
            self.hostingController.view.backgroundColor = .clear
            self.onSingleTap = onSingleTap
            self.zoomScaleBinding = currentZoomScale
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostingController.view
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            zoomScaleBinding.wrappedValue = scrollView.zoomScale
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return gestureRecognizer is UITapGestureRecognizer
        }
        
        // MARK: - Tap Handlers
        
        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView = recognizer.view as? UIScrollView else { return }
            
            let targetScale: CGFloat = (scrollView.zoomScale == 1.0) ? 2.0 : 1.0
            
            if targetScale > 1.0 {
                // zoom in around tap point
                let pointInView = recognizer.location(in: hostingController.view)
                let newZoomScale: CGFloat = 2
                let scrollViewSize = scrollView.bounds.size
                
                let w = scrollViewSize.width / newZoomScale
                let h = scrollViewSize.height / newZoomScale
                let x = pointInView.x - (w / 2.0)
                let y = pointInView.y - (h / 2.0)
                
                let rectToZoom = CGRect(x: x, y: y, width: w, height: h)
                scrollView.zoom(to: rectToZoom, animated: true)
            } else {
                // zoom out
                scrollView.setZoomScale(1.0, animated: true)
            }

            DispatchQueue.main.async {
                self.zoomScaleBinding.wrappedValue = targetScale
            }
        }
        
        @objc func handleSingleTap() {
            onSingleTap()
        }
    }
}
