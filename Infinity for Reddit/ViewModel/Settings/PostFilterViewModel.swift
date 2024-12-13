//
//  PostFilterViewModel.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-08.
//

import SwiftUI
import Combine
import GRDB

class PostFilterViewModel: ObservableObject {
    // MARK: - Properties
    @Published var postFilters: [PostFilter] = []
    private var cancellables = Set<AnyCancellable>()
    
    private let postFilterDao: PostFilterDao
    private let dbPool: DatabasePool
    
    private var listener: AnyDatabaseCancellable?
    
    // MARK: - Initializer
    init(dbPool: DatabasePool) {
        self.postFilterDao = PostFilterDao(dbPool: dbPool)
        self.dbPool = dbPool
    }
    
    // MARK: - Methods
    func loadPostFilters() {
        listener = ValueObservation
            .tracking { db in
                try PostFilter.fetchAll(db, sql: "SELECT * FROM post_filter ORDER BY name")
            }
            .start(in: dbPool) { error in
                print("Error observing post filters: \(error)")
                // Handle error
            } onChange: { (postFilters: [PostFilter]) in
                self.postFilters = postFilters
            }
    }
    
    
    func getRowCount() -> Int {
        do {
            let count = try dbPool.read { db in
                try PostFilter.fetchCount(db)
            }
            return count
        } catch {
            print("Error getting row count: \(error.localizedDescription)")
            return 0 // Or handle the error appropriately
        }
    }
    
    func savePostFilter(postFilter: PostFilter) {
        do {
            try postFilterDao.insert(postFilter: postFilter)
        } catch {
            print("Error: Failed to insert postFilter - \(error.localizedDescription)")
        }
    }
    
    func savePostFilter(
        id: Int?,
        originalProfileName: String?,
        profileName: String,
        maxVote: Int,
        minVote: Int,
        maxComments: Int,
        minComments: Int,
        onlyNSFW: Bool,
        onlySpoiler: Bool,
        onlySensitive: Bool,
        excludesKeywords: String,
        containsKeywords: String,
        excludesRegex: String,
        containsRegex: String,
        excludeSubreddits: String,
        excludeUsers: String,
        excludeFlairs: String,
        containFlairs: String,
        excludeDomains: String,
        containDomains: String,
        showText: Bool,
        showLink: Bool,
        showImage: Bool,
        showGif: Bool,
        showVideo: Bool,
        showGallery: Bool
    ) {
        let postFilterModel = PostFilter(
            id: id,
            name: profileName,
            maxVote: maxVote,
            minVote: minVote,
            maxComments: maxComments,
            minComments: minComments,
            onlyNSFW: onlySensitive,
            onlySpoiler: onlySpoiler,
            postTitleExcludesRegex: excludesRegex,
            postTitleContainsRegex: containsRegex,
            postTitleExcludesStrings: excludesKeywords,
            postTitleContainsStrings: containsKeywords,
            excludeSubreddits: excludeSubreddits,
            excludeUsers: excludeUsers,
            containFlairs: containFlairs,
            excludeFlairs: excludeFlairs,
            excludeDomains: excludeDomains,
            containDomains: containDomains,
            containTextType: showText,
            containLinkType: showLink,
            containImageType: showImage,
            containGifType: showGif,
            containVideoType: showVideo,
            containGalleryType: showGallery
        )
        if let originalProfileName = originalProfileName , originalProfileName != profileName {
            do {try postFilterDao.updatePostFilter(updatedPostFilter: postFilterModel)
            }catch {
                print("Error updating postFilter - \(error.localizedDescription)")
            }
        } else {
            do {
                try postFilterDao.insert(postFilter: postFilterModel)
            } catch {
                print("Error inserting postFilter - \(error.localizedDescription)")
            }
        }
    }
    
    func deletePostFilter(_ postfilterName: String) {
        do {
            try postFilterDao.deletePostFilter(name: postfilterName)
            
        } catch {
            print("Error deleting \(postfilterName): \(error)")
        }
    }
    
    func fetchPostFilter(_ filterName: String) throws -> PostFilter? {
        do {
            return try postFilterDao.getPostFilter(name: filterName)
        } catch {
            print("Error fetching \(filterName): \(error)")
        }
        return nil
    }
}
