//
//  ModMailStateSheet.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2026-10-27.
//

import SwiftUI

struct ModMailStateSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let currentModMailState: ModMailState
    let onSelectModMailState: (ModMailState) -> Void
    
    var body: some View {
        SheetRootView {
            ScrollView {
                VStack(spacing: 0) {
                    Text("Filter Mod Mail")
                        .primaryText()
                    
                    Spacer()
                        .frame(height: 16)
                    
                    ForEach(ModMailState.allCases, id: \.self) { modMailState in
                        IconTextButton(startIconUrl: modMailState.icon, endIconUrl: modMailState == currentModMailState ? "checkmark.seal" : nil, text: modMailState.title) {
                            onSelectModMailState(modMailState)
                            dismiss()
                        }
                    }
                }
                .padding(.top, 24)
            }
        }
    }
}
