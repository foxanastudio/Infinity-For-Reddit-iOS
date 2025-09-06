//
//  GenericPickerPreference.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-05.
//

import SwiftUI

struct GenericPickerPreference: View {
    @Binding var selected: String
    let items: [String]
    let title: String
    var icon: String? = nil
    
    var body: some View {
        Menu {
            ForEach(items, id: \.self) { item in
                Button {
                    selected = item 
                } label: {
                    Text(item)
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
                    
                    RowText(selected)
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
