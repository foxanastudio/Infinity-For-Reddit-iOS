//
//  PostListingView.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-04.
//

import SwiftUI
import Swinject
import GRDB
import Alamofire

struct PostListingView: View {
    @Environment(\.dependencyManager) private var dependencyManager: Container
    @EnvironmentObject var accountViewModel: AccountViewModel
    
    @StateObject var postListingViewModel: PostListingViewModel
    
    init() {
        // Resolve the session ASAP and store it in a property
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session")
        }
        
        _postListingViewModel = StateObject(
            wrappedValue: PostListingViewModel(
                postListingRepository: PostListingRepository(
                    session: resolvedSession
                )
            )
        )
    }
    
    var body: some View {
        List() {
        }
        .onAppear {
            postListingViewModel.postListingRepository.setAccount(accountViewModel.account)
            
            postListingViewModel.loadPosts()
        }
    }
}
