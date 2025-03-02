//
//  Image.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-02.
//

import SwiftUI

extension SwiftUI.Image {
    func postIconTemplateRendering() -> some View {
        self
            .renderingMode(.template)
    }
}
