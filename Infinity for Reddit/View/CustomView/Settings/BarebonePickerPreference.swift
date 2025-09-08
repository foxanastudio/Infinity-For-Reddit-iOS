//
//  BarebonePickerPreference.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-08.
//

import SwiftUI

struct BarebonePickerPreference<T: Hashable>: View {
    @Binding var selected: T
    let items: [T]
    let title: String
    var icon: String? = nil
    var labelProvider: (T) -> String
    
    var body: some View {
        Menu {
            ForEach(items, id: \.self) { item in
                Button {
                    selected = item
                } label: {
                    Text(labelProvider(item))
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
                } else {
                    Spacer()
                        .frame(width: 24)
                }
                
                Spacer()
                    .frame(width: 24)
                
                VStack(spacing: 4) {
                    RowText(title)
                        .primaryText()
                    
                    RowText(labelProvider(selected))
                        .secondaryText()
                }
                
                Spacer()
                
                SwiftUI.Image(systemName: "chevron.down")
                    .primaryIcon()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
