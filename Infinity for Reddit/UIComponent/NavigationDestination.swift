//
//  NavigationDestination.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-05-29.
//

import SwiftUI

struct NavigationStackItemViewModifier: ViewModifier {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @State private var showProfile: Bool = false
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showProfile.toggle()
                    }) {
                        CustomWebImage(
                            accountViewModel.account.profileImageUrl,
                            width: 30,
                            height: 30,
                            circleClipped: true,
                            handleImageTapGesture: false,
                            fallbackView: {
                                SwiftUI.Image(systemName: "person.crop.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .navigationBarImage()
                            }
                        )
                    }
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationBarMenu()
                }
            }
            .themedNavigationBar()
            .sheet(isPresented: $showProfile) {
                AccountSheet()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
    }
}
