//
//  SegmentedPicker.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-04-05.
//

import SwiftUI

struct SegmentedPicker: View {
    @EnvironmentObject var themeViewModel: CustomThemeViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Namespace var pickerAnimation
    
    var selectedValue: Binding<Int>
    let values: [String]
    
    var body: some View {
        HStack {
            ForEach(values.indices, id: \.self) { index in
                let isSelected = index == selectedValue.wrappedValue
                
                Button(action: {
                    withAnimation(.spring(duration: 0.25)) {
                        selectedValue.wrappedValue = index
                    }
                }) {
                    Text(values[index])
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(Color(hex: themeViewModel.currentCustomTheme.tabLayoutWithExpandedCollapsingToolbarTextColor))
                        .background {
                            if isSelected {
                                VStack {
                                    Spacer()
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .frame(width: 24, height: 2)
                                        .foregroundColor(Color(hex: themeViewModel.currentCustomTheme.tabLayoutWithExpandedCollapsingToolbarTabIndicator))
                                }
                                .matchedGeometryEffect(id: "background", in: pickerAnimation)
                            }
                        }
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
        }
        .tint(.white)
        .padding(4)
//        .background(
//            RoundedRectangle(cornerRadius: 50)
//                .fill(.ultraThinMaterial)
//        )
    }
}
