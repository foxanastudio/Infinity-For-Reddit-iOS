//
//  SelectPostFlairSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-17.
//

import SwiftUI

struct SelectPostFlairSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let flairs: [Flair]?
    let onFlairSelected: (Flair) -> Void
    
    var body: some View {
        ScrollView {
            if let flairs {
                VStack(spacing: 0) {
                    if !flairs.isEmpty {
                        ForEach(flairs, id: \.id) { flair in
                            TouchRipple(action: {
                                onFlairSelected(flair)
                                dismiss()
                            }) {
                                FlairRowView(flair: flair)
                            }
                        }
                    } else {
                        Text("No flairs available")
                            .secondaryText()
                    }
                }
                .padding(.top, 20)
            } else {
                ProgressIndicator()
            }
        }
    }
}
