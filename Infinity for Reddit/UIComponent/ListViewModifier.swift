//
//  ListViewModifier.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-21.
//

import SwiftUI

struct ListCustomThemeViewModifier: ViewModifier {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    
    func body(content: Content) -> some View {
        content
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .padding(0)
    }
}

struct ListPlainItemThemeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

struct ListPlainItemNoInsetsThemeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
    }
}
