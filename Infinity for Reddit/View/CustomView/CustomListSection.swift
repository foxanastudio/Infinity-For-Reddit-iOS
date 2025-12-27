//
//  CustomListSection.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-29.
//

import SwiftUI

struct CustomListSection<Content: View>: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @State private var currentWidth: CGFloat = 0
    
    let title: String
    let padding: CGFloat
    var content: Content
    
    init(
        _ title: String,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        Section {
            content
        } header: {
            Text(title)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                .padding(.horizontal, max(0, (currentWidth - 500) / 2) + 16)
                .background(
                    GeometryReader { proxy in
                        Color(hex: customThemeViewModel.currentCustomTheme.backgroundColor)
                            .onAppear {
                                currentWidth = proxy.size.width
                            }
                            .onChange(of: proxy.size) { _, newValue in
                                currentWidth = newValue.width
                            }
                    }
                )
                .listSectionHeader()
        }
        .listPlainItemNoInsets()
    }
}
