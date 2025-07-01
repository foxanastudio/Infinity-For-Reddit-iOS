//
//  SortTypeSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-29.
//

import SwiftUI

struct SortTypeSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let postListingType: PostListingType
    let currentSortType: SortType.Kind
    let onSelectSortType: (SortType.Kind) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Select Sort Type")
                
                ForEach(postListingType.availableSortTypes, id: \.self) { sortType in
                    IconTextButton(startIconUrl: sortType.icon, startIconType: .icon, endIconUrl: sortType == currentSortType ? "checkmark.seal" : nil, text: sortType.fullName) {
                        onSelectSortType(sortType)
                        dismiss()
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
    }
}
