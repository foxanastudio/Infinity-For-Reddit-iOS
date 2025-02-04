//
//  CustomizeCustomThemeView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-01-29.
//

import SwiftUI

struct CustomizeCustomThemeView: View {
    @StateObject var customizeCustomThemeViewModel: CustomizeCustomThemeViewModel
    
    init(customTheme: CustomTheme) {
        _customizeCustomThemeViewModel = StateObject(wrappedValue: CustomizeCustomThemeViewModel(customTheme: customTheme))
    }
    
    var body: some View {
        List {
            ForEach(customizeCustomThemeViewModel.customThemeFields, id: \.self) { fieldName in
                ColorEntry(fieldName: fieldName, title: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.title ?? "", description: customizeCustomThemeViewModel.customThemeSettingsItems[fieldName]?.description ?? "", color: 0x000000)
            }
        }
    }
    
    private func ColorEntry(fieldName: String, title: String, description: String, color: Int) -> some View {
        return HStack(alignment: .center) {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 24, height: 24)
            
            Spacer()
                .frame(width: 16)
            
            VStack(alignment: .leading) {
                Text(title)
                
                Spacer()
                    .frame(height: 8)
                
                Text(description)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
