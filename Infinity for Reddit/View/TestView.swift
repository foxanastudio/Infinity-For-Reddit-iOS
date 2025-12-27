//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI
import SeekBar

struct TestView: View {
    @EnvironmentObject private var customThemeViewModel: CustomThemeViewModel
    
    @State private var value: Double = 12
    @State private var isEditing = false
    
    var body: some View {
        VStack {
            SeekBar(
                value: $value,
                in: 0...100,
                onEditingChanged: { edited in
                    print(value)
                    withAnimation {
                        isEditing = edited
                    }
                }
            )
            .seekBarDisplay(with: .trackOnly)
            .trackDimensions(
                trackHeight: isEditing ? 24 : 16,
                inactiveTrackCornerRadius: 24
            )
            .trackColors(activeTrackColor: Color(hex: customThemeViewModel.currentCustomTheme.colorPrimary), inactiveTrackColor: Color.red)
            .padding(.horizontal, isEditing ? 12 : 24)
        }
        .themedNavigationBar()
    }
}
