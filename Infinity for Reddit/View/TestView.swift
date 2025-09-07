//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TestView: View {
    @State private var scale: CGFloat = 1.0
    @GestureState private var dragOffset: CGSize = .zero
    @State private var currentDragOffset: CGSize = .zero
    @State private var hasStartedDragging: Bool = false
    @State private var isAnimatingBack: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea()
        }
    }
}
