//
//  PostDetailsViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-03-23.
//

import Foundation
import Combine
import MarkdownUI
import IdentifiedCollections

public class PostDetailsViewModel: ObservableObject {
    // MARK: - Properties
    @Published var post: Post
    @Published var visibleComments: IdentifiedArrayOf<Comment> = []
    var allComments: IdentifiedArrayOf<Comment> = []
    @Published var isSingleThread: Bool =  false
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreComments: Bool = true
    @Published var error: Error?
    private let account: Account
    private var postId: String?
    private var commentMore: CommentMore?
    
    private var after: String? = nil
    
    public let postDetailsRepository: PostDetailsRepositoryProtocol
    
    // MARK: - Initializer
    init(account: Account, post: Post, postDetailsRepository: PostDetailsRepositoryProtocol) {
        self.account = account
        self.post = post
        self.postDetailsRepository = postDetailsRepository
    }
    
    // MARK: - Methods
    
    public func fetchComments() async {
        guard !isInitialLoading, !isLoadingMore, hasMoreComments else { return }
        
        let isInitailLoadCopy = isInitialLoad
        
        await MainActor.run {
            if allComments.isEmpty {
                isInitialLoading = true
            } else {
                isLoadingMore = true
            }
            
            if isInitialLoad {
                isInitialLoad = false
            }
        }
        
        do {
            try Task.checkCancellation()
            
            let postDetails = try await postDetailsRepository.fetchComments(
                postId: post.id,
                queries: ["after": after ?? ""]
            )
            
            try Task.checkCancellation()
            
            let processedComments = postProcessComments(postDetails.comments)
            
            try Task.checkCancellation()
            
            await MainActor.run {
                self.visibleComments.append(contentsOf: processedComments)
                self.allComments.append(contentsOf: processedComments)
                
                printDuplicateCommentIDs(in: visibleComments)
                hasMoreComments = postDetails.commentListing.commentMore?.children.isEmpty == false
                
                self.isInitialLoading = false
                self.isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                
                self.isInitialLoad = isInitailLoadCopy
                self.isInitialLoading = false
                self.isLoadingMore = false
            }
            print("Error fetching comments: \(error)")
        }
    }
    
    /// Reloads posts from the first page
    func refreshPosts() async {
        await MainActor.run {
            isInitialLoad = true
            isInitialLoading = false
            isLoadingMore = false
            
            after = nil
            hasMoreComments = true
            visibleComments = []
            allComments = []
        }
        
        await fetchComments()
    }
    
    func postProcessComments(_ comments: [Comment]) -> [Comment] {
        return comments.map {
            modifyCommentBody($0)
            $0.bodyProcessedMarkdown = MarkdownContent($0.body)
            return $0
        }
    }
    
    func modifyCommentBody(_ comment: Comment) {
        MarkdownUtils.parseRedditImagesBlock(comment)
    }
    
    func printDuplicateCommentIDs(in comments: IdentifiedArrayOf<Comment>) {
        var seen: Set<String> = []
        var duplicates: Set<String> = []

        for comment in comments {
            if !seen.insert(comment.id).inserted {
                duplicates.insert(comment.id)
            }
        }

        if duplicates.isEmpty {
            print("✅ No duplicate comment IDs found.")
        } else {
            print("❌ Duplicate comment IDs found:")
            for id in duplicates {
                print(" - \(id)")
            }
        }
    }
    
    public func collapseComments(comment: Comment) {
        guard comment.replies?.comments?.count ?? -1 > 0 else {
            return
        }
        
        guard let index = visibleComments.index(id: comment.id) else { return }

        let parentDepth = comment.depth
        var endIndex = index + 1

        while endIndex < visibleComments.count,
              let depth = visibleComments[endIndex].depth,
              depth > (parentDepth ?? 0) {
            endIndex += 1
        }

        comment.isCollasped = true
        visibleComments.removeSubrange((index + 1)..<endIndex)
    }
    
    public func expandComments(comment: Comment) {
        guard comment.replies?.comments?.count ?? -1 > 0 else {
            return
        }
        
        guard let index = visibleComments.index(id: comment.id),
              let parentIndexInAll = allComments.index(id: comment.id),
              let parentDepth = comment.depth else {
            return
        }

        var insertIndex = index + 1
        var childIndex = parentIndexInAll + 1

        while childIndex < allComments.count {
            let child = allComments[childIndex]

            // Stop when we reach a sibling or ancestor
            guard let childDepth = child.depth, childDepth > parentDepth else {
                break
            }

            // Avoid inserting if already visible
            if !visibleComments.contains(where: { $0.id == child.id }) {
                visibleComments.insert(child, at: insertIndex)
                insertIndex += 1
            } else {
                break
            }

            childIndex += 1
        }
        
        comment.isCollasped = false
    }
    
    public func loadIcon(comment: Comment) {
        guard comment.authorIconUrl == nil else { return }
        
        let startIndex = visibleComments.firstIndex(where: { $0.id == comment.id }) ?? 0
        let commentBatch = Array(
            visibleComments[startIndex..<min(visibleComments.count, startIndex + UserProfileImageBatchLoader.batchSize)]
        )

        Task {
            let iconUrl = await UserProfileImageBatchLoader.shared.loadIcons(for: commentBatch)
            
            if let iconUrl {
                await MainActor.run {
                    comment.authorIconUrl = iconUrl
                }
            }
        }
    }
}
