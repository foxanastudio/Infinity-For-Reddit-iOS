//
//  CustomNavigationLink.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-02.
//

import SwiftUI

struct CustomNavigationLink<Destination: View, Content: View>: View {
    var title: String?
    var content: (() -> Content)?
    let destination: Destination
    let showArrow: Bool
    
    init(_ title: String, destination: Destination) where Content == EmptyView {
        self.title = title
        self.destination = destination
        self.showArrow = true
    }
    
    init(destination: Destination, @ViewBuilder _ content: @escaping () -> Content) {
        self.destination = destination
        self.content = content
        self.showArrow = true
    }
    
    init(destination: Destination, showArrow: Bool, @ViewBuilder _ content: @escaping () -> Content) {
        self.destination = destination
        self.showArrow = showArrow
        self.content = content
    }
    
    var body: some View {
        HStack {
            if title != nil {
                Text(title!)
                    .primaryText()
            } else if content != nil {
                content!()
            }
            
            Spacer()
            
            if showArrow {
                SwiftUI.Image(systemName: "chevron.right")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 7)
                    .primaryIcon()
            }
        }
        .background(
            NavigationLink("", destination: destination)
                .opacity(0)
        )
    }
}
