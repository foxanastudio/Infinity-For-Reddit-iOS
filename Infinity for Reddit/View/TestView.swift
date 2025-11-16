//
//  TestView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-02-22.
//

import SwiftUI
import Kingfisher

struct TestView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("Font: This is a sample label")
                    .customFont()
                
                Text("Post Title Font: Sample Post Title Here")
                    .customPostTitleFont()
                
                Text("Content Font: This is a comment example text.")
                    .customContentFont()
            }
            .padding()
        }
    }
}
