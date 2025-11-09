//
//  SortTypeTimeSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-29.
//

import SwiftUI

struct SortTypeTimeSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let sortTypeTimeSource: SortTypeTimeSource
    let currentSortTypeTime: SortType.Time?
    let onSelectSortType: (SortType.Time) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("Select Sort Time")
                    .padding(.bottom, 16)
                
                ForEach(sortTypeTimeSource.availableSortTypeTimes, id: \.self) { sortTime in
                    IconTextButton(endIconUrl: sortTime == currentSortTypeTime ? "checkmark.seal" : nil, text: sortTime.fullName) {
                        onSelectSortType(sortTime)
                        dismiss()
                    }
                    .listPlainItemNoInsets()
                }
            }
            .padding(.top, 24)
        }
    }
}

protocol SortTypeTimeSource {
    var availableSortTypeTimes: [SortType.Time] { get }
}
