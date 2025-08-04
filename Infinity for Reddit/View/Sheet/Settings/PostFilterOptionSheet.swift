//
//  PostFilterOptionSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-08-03.
//

import SwiftUI

struct PostFilterOptionSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var onEditSelected: () -> Void
    var onApplyToSelected: () -> Void
    var onDeleteSelected: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 16)
            
            IconTextButton(startIconUrl: "pencil", text: "Edit") {
                onEditSelected()
                dismiss()
            }
            
            IconTextButton(startIconUrl: "text.badge.plus", text: "Apply to") {
                onApplyToSelected()
                dismiss()
            }
            
            IconTextButton(startIconUrl: "trash", text: "Delete") {
                onDeleteSelected()
                dismiss()
            }
            
            Spacer()
        }
    }
}
