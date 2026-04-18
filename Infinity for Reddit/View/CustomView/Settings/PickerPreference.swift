//
//  PickerPreference.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-10.
//

import SwiftUI

struct PickerPreference: View {
    @Binding var selectedIndex: Int
    let items: [String]
    let title: String
    var icon: String? = nil
    
    private var selectedItem: String {
        guard items.indices.contains(selectedIndex) else {
            return "Select"
        }
        
        return items[selectedIndex]
    }
    
    var body: some View {
        Menu {
            ForEach(items.indices, id: \.self) { i in
                Button {
                    selectedIndex = i
                } label: {
                    Text(items[i])
                        .primaryText()
                }
            }
        } label: {
            HStack(spacing: 0) {
                if let icon = icon {
                    SwiftUI.Image(systemName: icon)
                        .primaryIcon()
                        .frame(width: 24, height: 24, alignment: .leading)
                        .padding(0)
                    
                    Spacer()
                        .frame(width: 16)
                }
                
                VStack(spacing: 4) {
                    RowText(title)
                        .primaryText()
                    
                    RowText(selectedItem)
                        .secondaryText()
                }
                .padding(.trailing, 16)
                
                SwiftUI.Image(systemName: "chevron.down")
                    .primaryIcon()
            }
            .padding(16)
            .limitedWidth()
        }
        .compositingGroup()
    }
}
