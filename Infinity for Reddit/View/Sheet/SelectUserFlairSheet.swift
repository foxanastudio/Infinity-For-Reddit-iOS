//
//  SelectUserFlairSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-17.
//

import SwiftUI

struct SelectUserFlairSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let userFlairs: [UserFlair]?
    let onUserFlairSelected: (UserFlair) -> Void
    let onClearUserFlair: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                TouchRipple(action: {
                    onClearUserFlair()
                    dismiss()
                }) {
                    RowText("Clear Flair")
                        .primaryText()
                        .padding(16)
                }
                .padding(.top, 20)
                
                if let userFlairs {
                    VStack(spacing: 0) {
                        if !userFlairs.isEmpty {
                            ForEach(userFlairs, id: \.id) { userFlair in
                                TouchRipple(action: {
                                    onUserFlairSelected(userFlair)
                                    dismiss()
                                }) {
                                    UserFlairRowView(userFlair: userFlair)
                                }
                            }
                        } else {
                            Text("No user flairs available")
                                .secondaryText()
                        }
                    }
                } else {
                    ZStack {
                        ProgressIndicator()
                    }
                    .frame(height: 80)
                }
            }
        }
    }
}
