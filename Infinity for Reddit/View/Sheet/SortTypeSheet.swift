//
//  SortTypeSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-29.
//

import SwiftUI

struct SortTypeSheet: View {
    let postListingType: PostListingType
    let currentSortType: SortType.Kind
    
    var body: some View {
        VStack {
            Text("Select Sort Type")
            
            ForEach(postListingType.availableSortTypes, id: \.self) { sortType in
                IconTextButton(startIconUrl: sortType.icon, text: sortType.fullName) {
                    print(sortType.fullName)
                }
            }
        }
    }
}
