//
//  SortTypeKindSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-29.
//

import SwiftUI

struct SortTypeKindSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let sortTypeKindSource: SortTypeKindSource
    let currentSortTypeKind: SortType.Kind
    let onSelectSortTypeKind: (SortType.Kind) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Select Sort Type")
                
                Spacer()
                    .frame(height: 16)
                
                ForEach(sortTypeKindSource.availableSortTypeKinds, id: \.self) { sortType in
                    IconTextButton(startIconUrl: sortType.icon, startIconType: .icon, endIconUrl: sortType == currentSortTypeKind ? "checkmark.seal" : nil, text: sortType.fullName) {
                        onSelectSortTypeKind(sortType)
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                }
            }
            .padding(.top, 24)
        }
    }
}

protocol SortTypeKindSource {
    var availableSortTypeKinds: [SortType.Kind] { get }
}
