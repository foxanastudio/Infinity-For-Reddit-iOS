//
//  ProfileSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import SwiftUI
import SDWebImageSwiftUI

struct AccountSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    CustomWebImage(
                        accountViewModel.account.profileImageUrl,
                        width: 96,
                        height: 96,
                        circleClipped: true,
                        fallbackView: {
                            SwiftUI.Image(systemName: "person.crop.circle")
                                .resizable()
                                .frame(width: 96, height: 96)
                        }
                    )
                    
//                    if let profileImageUrl = accountViewModel.account.profileImageUrl {
//                        WebImage(url: URL(string: profileImageUrl)) { image in
//                            image
//                                .resizable()
//                        }  placeholder: {
//                            
//                        }
//                        .onSuccess { image, data, cacheType in
//                            // Success
//                            // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
//                        }
//                        .indicator(.activity)
//                        
//                        .clipShape(Circle())
//                        .transition(.fade(duration: 0.5))
//                        .scaledToFit()
//                        .frame(width: 96, height: 96)
//                    } else {
//                        SwiftUI.Image(systemName: "person.crop.circle")
//                            .resizable()
//                            .frame(width: 96, height: 96)
//                    }
                    
                    // User's Name
                    Text(accountViewModel.account.isAnonymous() == true ? "Anonymous" : accountViewModel.account.username)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    if accountViewModel.account.isAnonymous() == false {
                        // Navigate to User Details Page
                        NavigationLink(destination: UserDetailsView(username: accountViewModel.account.username)) {
                            Text("View User Details")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Spacer()

                        
                        NavigationLink(destination: AccountListingView(dismissAccountSheet: {
                            self.dismiss()
                        })) {
                            Text("Switch account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            // Handle Sign Out Logic
                            do {
                                try accountViewModel.logoutToAnonymous()
                            } catch {
                                print("Failed to log out: \(error)")
                            }
                        }) {
                            Text("Anonymous")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        Button(action: {
                            // Handle Sign Out Logic
                            do {
                                try accountViewModel.logoutToAnonymous()
                            } catch {
                                print("Failed to log out: \(error)")
                            }
                            accountViewModel.shouldDismissAccountSheet = true
                        }) {
                            Text("Log out")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    } else {
                        NavigationLink(destination: LoginView().environmentObject(accountViewModel)) {
                            Text("Log in")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        
                        NavigationLink(destination: AccountListingView(dismissAccountSheet: {
                            self.dismiss()
                        })) {
                            Text("Switch account")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.top, 20)
            .navigationBarTitle("Account", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Close") {
                    dismiss() // Close the sheet
                }
            )
            .onChange(of: accountViewModel.shouldDismissAccountSheet) {
                accountViewModel.shouldDismissAccountSheet = false
                dismiss()
            }
            
        }
    }
}
