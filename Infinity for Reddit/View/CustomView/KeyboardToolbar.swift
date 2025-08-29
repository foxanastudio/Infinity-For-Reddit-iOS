//
//  KeyboardToolbar.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-28.
//

import SwiftUI

struct KeyboardToolbar: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @StateObject private var keyboard = KeyboardManager()
    
    let hideKeyboard: () -> Void
    
    var body: some View {
        if keyboard.isVisible {
            HStack {
                Spacer()
                
                Button {
                    hideKeyboard()
                } label: {
                    Text("Done")
                        .positiveTextButton()
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(Color(hex: customThemeViewModel.currentCustomTheme.backgroundColor))
            //.background(Color.blue)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.25), value: keyboard.isVisible)
        }
    }
}
