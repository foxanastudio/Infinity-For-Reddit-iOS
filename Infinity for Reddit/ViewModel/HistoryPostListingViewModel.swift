//
//  HistoryPostListingViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-03.
//

import Foundation
import Combine
import MarkdownUI
import GRDB
import SwiftUI

public class HistoryPostListingViewModel: ObservableObject {
    // MARK: - Properties
    @Published var posts: [Post] = []
    @Published var isInitialLoad: Bool = true
    @Published var isInitialLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var error: Error?
    @Published var loadPostsTaskId = UUID()
    @Published var layout: PostLayoutType
    
    private var historyPostListingMetadata: HistoryPostListingMetadata
    private var externalPostFilter: PostFilter?
    private var postFilter: PostFilter?
    private var allPostIds = Set<String>()
    private var after: String? = nil
    
    // UserDefaults
    private var sensitiveContent: Bool
    private var spoilerContent: Bool
    
    private let historyPostListingRepository: HistoryPostListingRepositoryProtocol
    private let readPostsRepository: ReadPostsRepositoryProtocol
    
    private var refreshPostsContinuation: CheckedContinuation<Void, Never>?
    
    private var paginationTask: Task<Void, Never>?
    
    private var cancellables = Set<AnyCancellable>()
    
    private var userSelectedLayout: PostLayoutType? = nil
    private let postFeedID: String
    
    // MARK: - Initializer
    init(
        historyPostListingMetadata: HistoryPostListingMetadata,
        externalPostFilter: PostFilter?,
        historyPostListingRepository: HistoryPostListingRepositoryProtocol,
        readPostsRepository: ReadPostsRepositoryProtocol,
        postFeedID: String
    ) {
        self.historyPostListingMetadata = historyPostListingMetadata
        self.externalPostFilter = externalPostFilter
        self.historyPostListingRepository = historyPostListingRepository
        self.readPostsRepository = readPostsRepository
        
        self.sensitiveContent = ContentSensitivityFilterUserDetailsUtils.sensitiveContent
        self.spoilerContent = ContentSensitivityFilterUserDetailsUtils.spoilerContent
        
        self.postFeedID = postFeedID
        
        if let customLayout = Self.loadCustomLayout(for: postFeedID) {
            self.layout = customLayout
            print("Loaded custom layout \(customLayout) for feed \(postFeedID)")
        } else {
            self.layout = PostLayoutType(rawValue: InterfacePostUserDefaultsUtils.defaultPostLayout) ?? .card
            print("Using default layout \(layout) for feed \(postFeedID)")
        }
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if !Self.hasCustomLayout(for: self.postFeedID) {
                    let newLayout = PostLayoutType(
                        rawValue: InterfacePostUserDefaultsUtils.defaultPostLayout
                    ) ?? .card
                    
                    print("UserDefaults changed — no custom layout for \(self.postFeedID). Updating to default layout: \(newLayout)")
                    
                    Task { @MainActor in
                        self.layout = newLayout
                        print("Updated layout on main thread to \(self.layout)")
                    }
                } else {
                    print("UserDefaults changed to \(PostLayoutType(rawValue: InterfacePostUserDefaultsUtils.defaultPostLayout) ?? .card) for feed \(self.postFeedID) — but custom layout exists for \(self.postFeedID), keeping \(self.layout)")
                }
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .sink { [weak self] _ in
                let sensitiveContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.sensitiveContentKey)
                let spoilerContent = UserDefaults.contentSensitivityFilter.bool(forKey: ContentSensitivityFilterUserDetailsUtils.spoilerContentKey)
                self?.setSensitiveContent(sensitiveContent)
                self?.setSpoilerContent(spoilerContent)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    public func initialLoadPosts() async {
        guard isInitialLoad else {
            return
        }
        
        await loadPosts(isRefreshWithContinuation: refreshPostsContinuation != nil)
    }
    
    public func loadPostsPagination(index: Int) {
        guard paginationTask == nil else { return }
        
        guard index >= posts.count - 3 else { return }
        
        paginationTask = Task {
            defer { paginationTask = nil }
            await loadPosts()
        }
    }
    
    /// Fetches the next page of posts
    public func loadPosts(isRefreshWithContinuation: Bool = false) async {
        guard !isInitialLoading, !isLoadingMore, hasMorePages else { return }
        
        let isInitailLoadCopy = isInitialLoad
        
        await MainActor.run {
            if posts.isEmpty {
                isInitialLoading = true
            } else {
                print("isloadingmore is true")
                isLoadingMore = true
            }
            
            if isInitialLoad {
                isInitialLoad = false
            }
        }
        
        do {
            try Task.checkCancellation()
            
            let postListing: PostListing
            postListing = try await historyPostListingRepository.fetchPosts(
                historyPostListingType: historyPostListingMetadata.historyPostListingType
            )
            
            try Task.checkCancellation()
            
            if postFilter == nil {
                fetchPostFilter()
            }
            
            let processedPosts = self.postProcessPosts(postListing.posts)
            
            try Task.checkCancellation()
            
            if (processedPosts.isEmpty) {
                // No more posts
                await MainActor.run {
                    hasMorePages = false
                    self.after = nil
                }
            } else {
                let realNewPosts = processedPosts.filter {
                    !self.allPostIds.contains($0.id)
                }
                
                self.after = postListing.after
                
                allPostIds.formUnion(
                    realNewPosts
                        .compactMap {
                            $0.id
                        }
                )
                
                await MainActor.run {
                    if isRefreshWithContinuation {
                        self.posts.removeAll()
                    }
                    self.posts.append(contentsOf: realNewPosts)
                    hasMorePages = !(self.after == nil || self.after?.isEmpty == true)
                }
            }
            
            await MainActor.run {
                if isRefreshWithContinuation {
                    finishPullToRefresh()
                }
                
                isInitialLoading = false
                isLoadingMore = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                
                isInitialLoad = isInitailLoadCopy
                isInitialLoading = false
                isLoadingMore = false
            }
            
            print("Error fetching posts: \(error)")
        }
    }
    
    @MainActor
    func refreshPostsWithContinuation() async {
        resetPostLoadingState()
        await withCheckedContinuation { continuation in
            refreshPostsContinuation = continuation
            loadPostsTaskId = UUID()
        }
    }
    
    func refreshPosts() {
        resetPostLoadingState()
        loadPostsTaskId = UUID()
    }
    
    private func resetPostLoadingState() {
        isInitialLoad = true
        isInitialLoading = false
        isLoadingMore = false
        
        after = nil
        hasMorePages = true
        if refreshPostsContinuation == nil {
            posts = []
        }
        
        allPostIds = Set<String>()
    }
    
    func finishPullToRefresh() {
        refreshPostsContinuation?.resume()
        refreshPostsContinuation = nil
    }
    
    func postProcessPosts(_ posts: [Post]) -> [Post] {
        return posts.filter { post in
            return PostFilter.isPostAllowed(post: post, postFilter: postFilter)
        }.map {
            if !$0.selftext.isEmpty {
                modifyPostBody($0)
                $0.selftextProcessedMarkdown = MarkdownContent($0.selftext)
            }
            
            return $0
        }
    }
    
    func modifyPostBody(_ post: Post) {
        MarkdownUtils.parseRedditImagesBlock(post)
    }
    
    func fetchPostFilter() {
        self.postFilter = historyPostListingRepository.getPostFilter(
            historyPostListingType: historyPostListingMetadata.historyPostListingType,
            externalPostFilter: externalPostFilter
        )
        self.postFilter?.allowSensitive = sensitiveContent
        self.postFilter?.allowSpoiler = spoilerContent
    }
    
    func loadIcon(post: Post) async {
        guard post.subredditOrUserIcon == nil else { return }
        
        do {
            try await historyPostListingRepository.loadIcon(post: post)
        } catch {
            print("Load icon failed")
        }
    }
    
    func setSensitiveContent(_ sensitiveContent: Bool) {
        if sensitiveContent != self.sensitiveContent {
            self.sensitiveContent = sensitiveContent
            self.postFilter?.allowSensitive = sensitiveContent
            refreshPosts()
        }
    }
    
    func setSpoilerContent(_ spoilerContent: Bool) {
        if spoilerContent != self.spoilerContent {
            self.spoilerContent = spoilerContent
            self.postFilter?.allowSpoiler = spoilerContent
            refreshPosts()
        }
    }
    
    func changePostLayout(to newLayout: PostLayoutType) {
        Self.saveCustomLayout(newLayout, for: postFeedID)
        layout = newLayout
        print("Changed layout to \(newLayout) (custom saved for \(postFeedID))")
    }
    
    func resetToDefaultLayout() {
        Self.removeCustomLayout(for: postFeedID)
        layout = PostLayoutType(rawValue: InterfacePostUserDefaultsUtils.defaultPostLayout) ?? .card
    }
    
    private static let perFeedPrefix = "post_layout_"
    
    private static func key(for postFeedID: String) -> String {
        "\(perFeedPrefix)\(postFeedID.lowercased())"
    }
    
    private static func loadCustomLayout(for postFeedID: String) -> PostLayoutType? {
        if let value = UserDefaults.interfacePost.object(forKey: key(for: postFeedID)) as? Int {
            return PostLayoutType(rawValue: value)
        }
        return nil
    }
    
    private static func saveCustomLayout(_ layout: PostLayoutType, for postFeedID: String) {
        UserDefaults.interfacePost.set(layout.rawValue, forKey: key(for: postFeedID))
    }
    
    private static func removeCustomLayout(for postFeedID: String) {
        UserDefaults.interfacePost.removeObject(forKey: key(for: postFeedID))
    }
    
    private static func hasCustomLayout(for postFeedID: String) -> Bool {
        UserDefaults.interfacePost.object(forKey: key(for: postFeedID)) != nil
    }
}
