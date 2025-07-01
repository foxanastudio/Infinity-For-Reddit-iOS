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
    @Published var visibleComments: IdentifiedArrayOf<CommentItem> = []
    var allComments: IdentifiedArrayOf<CommentItem> = []
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
    
    public func fetchMoreCommentsInCommentMore(commentMore: CommentMore) async {
        do {
            try Task.checkCancellation()
            
            let moreChildren = try await postDetailsRepository.fetchMoreCommentsForCommentMore(
                params: ["link_id": post.name, "children": commentMore.children.joined(separator: ",")]
            )
            
            try Task.checkCancellation()
            
            let processedComments = postProcessComments(moreChildren.commentItems)
            
            try Task.checkCancellation()
            
            await MainActor.run {
                guard let visibleIndex = visibleComments.index(id: commentMore.id) else { return }
                guard let allIndex = allComments.index(id: commentMore.id) else { return }
                
                // Remove the CommentMore item
                self.visibleComments.remove(at: visibleIndex)
                self.allComments.remove(at: allIndex)
                
                self.visibleComments.insert(contentsOf: processedComments, at: visibleIndex)
                self.allComments.insert(contentsOf: processedComments, at: allIndex)
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
            print("Error fetching more comments for CommentMore: \(error)")
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
    
    func postProcessComments(_ comments: [CommentItem]) -> [CommentItem] {
        return comments.map {
            if case .comment(let comment) = $0 {
                modifyCommentBody(comment)
                comment.bodyProcessedMarkdown = MarkdownContent(comment.body)
            }
            return $0
        }
    }
    
    func modifyCommentBody(_ comment: Comment) {
        MarkdownUtils.parseRedditImagesBlock(comment)
    }
    
    func printDuplicateCommentIDs(in comments: IdentifiedArrayOf<CommentItem>) {
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

        while endIndex < visibleComments.count {
            let item = visibleComments[endIndex]

            guard item.depth > (parentDepth ?? 0) else {
                break
            }

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
            guard child.depth > parentDepth else {
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
        ).compactMap { item -> Comment? in
            if case .comment(let comment) = item {
                return comment
            } else {
                return nil
            }
        }

        Task {
            let iconUrl = await UserProfileImageBatchLoader.shared.loadIcons(for: commentBatch)
            
            if let iconUrl {
                await MainActor.run {
                    comment.authorIconUrl = iconUrl
                }
            }
        }
    }
    
    func loadIcon(isFromSubredditPostListing: Bool) async {
        guard post.subredditOrUserIconInPostDetails == nil else { return }
        
        if !isFromSubredditPostListing && post.subredditOrUserIcon != nil {
            await MainActor.run {
                post.subredditOrUserIconInPostDetails = post.subredditOrUserIcon
            }
            return
        }
        
        do {
            try await postDetailsRepository.loadPostIcon(post: post, isFromSubredditPostListing: isFromSubredditPostListing)
        } catch {
            print("Load icon failed")
        }
    }
}
