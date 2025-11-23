//
//  UserDetailsViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-02-11.
//

import Foundation
import SwiftUI

@MainActor
class UserDetailsViewModel: ObservableObject {
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @Published var username: String
    @Published var userData: UserData?
    @Published var error: Error?
    
    private let userDetailsRepository: UserDetailsRepositoryProtocol
    private var followUserTask: Task<Void, Never>?
    
    init(username: String, userDetailsRepository: UserDetailsRepositoryProtocol) {
        self.username = username
        self.userDetailsRepository = userDetailsRepository
    }
    
    func fetchUserDetails() async {
        do {
            try Task.checkCancellation()
            
            let userData = try await userDetailsRepository.fetchUserDetails(username: username)
            
            try Task.checkCancellation()
            
            self.userData = userData
        } catch {
            self.error = error
            
            print("Error fetching user data: \(error)")
        }
    }
    
    func toggleFollowUser() {
        guard let userData else {
            return
        }
        
        followUserTask?.cancel()
        followUserTask = Task {
            let action = userData.isSubscribed ? "unsub" : "sub"
            do {
                try await userDetailsRepository.followUser(userData: userData, action: action)
                
                try Task.checkCancellation()
                
                self.userData?.isSubscribed = action == "sub"
            } catch {
                self.error = error
                
                print("Error \(action == "sub" ? "following" : "unfollowing") \(username): \(error)")
            }
            
            followUserTask = nil
        }
    }
}
