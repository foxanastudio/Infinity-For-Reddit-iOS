//
//  ProfileSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import SwiftUI

struct AccountSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if let profileImageUrl = accountViewModel.account.profileImageUrl {
                        AsyncImage(url: URL(string: profileImageUrl)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                SwiftUI.Image(systemName: "person.circle.circle")
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 96, height: 96)
                        .clipShape(.circle)
                    } else {
                        SwiftUI.Image(systemName: "person.crop.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }
                    
                    // User's Name
                    Text(accountViewModel.account.isAnonymous() == true ? "Anonymous" : accountViewModel.account.username)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Navigate to User Details Page
                    Button(action: {
                        // Navigate to User Details Page
                    }) {
                        Text("View User Details")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Sign Out Button
                    Button(action: {
                        // Handle Sign Out Logic
                    }) {
                        Text("Add an account")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Handle Sign Out Logic
                    }) {
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
                    }) {
                        Text("Log out")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 20)
            .navigationBarTitle("Account", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Close") {
                    dismiss() // Close the sheet
                }
            )
        }
    }
}
