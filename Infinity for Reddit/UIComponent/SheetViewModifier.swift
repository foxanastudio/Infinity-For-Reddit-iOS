//
//  SheetViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-12.
//

import SwiftUI

struct WrapContentSheetViewModifier<SheetContent: View>: ViewModifier {
    @Binding private var isPresented: Bool
    private let showDragIndicator: Bool
    private let sheetContent: SheetContent
    @State private var sheetContentHeight: CGFloat = 0

    init(
        isPresented: Binding<Bool>,
        showDragIndicator: Bool,
        sheetContent: @escaping () -> SheetContent
    ) {
        _isPresented = isPresented
        self.showDragIndicator = showDragIndicator
        self.sheetContent = sheetContent()
    }

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ScrollView {
                    sheetContent
                        .frame(maxWidth: .infinity)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .task {
                                        updateSheetHeight(proxy.size.height)
                                    }
                                    .onChange(of: proxy.size.height) { _, newValue in
                                        updateSheetHeight(newValue)
                                    }
                            }
                        )
                }
                .presentationDetents([.height(sheetContentHeight)])
                .presentationDragIndicator(showDragIndicator ? .visible : .hidden)
            }
    }

    private func updateSheetHeight(_ newHeight: CGFloat) {
        if sheetContentHeight != newHeight {
            sheetContentHeight = newHeight
        }
    }
}
