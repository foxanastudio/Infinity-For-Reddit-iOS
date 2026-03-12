//
//  PostViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2024-12-11.
//

import Foundation
import Alamofire
import Combine

@MainActor
class PostViewModel: ObservableObject {
    @Published var post: Post
    
    private var cancellables = Set<AnyCancellable>()
    
    let postRepository: PostRepositoryProtocol
    
    init(post: Post, postRepository: PostRepositoryProtocol) {
        self.post = post
        self.postRepository = postRepository
        
        post.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func readPost(markPostsAsRead: Bool, limitHistorySize: Bool, historyLimit: Int) async {
        guard !post.isRead, markPostsAsRead else {
            return
        }
        
        do {
            try await postRepository.readPost(
                post: post,
                account: AccountViewModel.shared.account,
                limitHistorySize: limitHistorySize,
                historyLimit: historyLimit
            )
            
            await MainActor.run {
                post.isRead = true
            }
        } catch {
            print("Mark post as read failed with error: \(error)")
        }
    }
}
