//
//  FontPreviewView.swift
//  Infinity for Reddit
//
//  Created by Joeylr on 2025-11-14.
//

import SwiftUI

struct FontPreviewView: View {
    var body: some View {
        List {
            PreferenceEntry(
                title: "Default"
            ){}
            .listPlainItemNoInsets()
            
            PreferenceEntry(
                title: "Balsamiq Sans"
            ){}
            .font(.custom("BalsamiqSans-Regular", size: 17))
            .listPlainItemNoInsets()
        }
        .themedList()
        .themedNavigationBar()
        .addTitleToInlineNavigationBar("Font Preview")
    }
}
