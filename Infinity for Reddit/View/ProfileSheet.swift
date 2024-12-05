//
//  ProfileSheet.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import SwiftUI

struct ProfileSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
                    VStack(spacing: 20) {
                        // User's Name
                        Text("John Doe")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        // Account Info Section
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Account Info")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            HStack {
                                Text("Email:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("john.doe@example.com")
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Account ID:")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("123-456-789")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))
                        .padding(.horizontal)
                        
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
                            Text("Sign Out")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .navigationBarTitle("Profile", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Close") {
                            dismiss() // Close the sheet
                        }
                    )
                }
    }
}
