//
//  UserProfileImageBatchLoader.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-24.
//

import Foundation
import Alamofire
import SwiftyJSON
import GRDB

actor UserProfileImageBatchLoader {
    enum UserProfileImageBatchLoaderError: Error {
        case NetworkError(String)
        case JSONDecodingError(String)
    }
    
    static let shared = UserProfileImageBatchLoader()
    
    private let session: Session
    private let userDao: UserDao
    private let partialUserDao: PartialUserDao
    public static let batchSize = 100
    private var cache: [String: String] = [:]
    private var inFlight: Set<String> = []
    private var loadingQueue: [String] = []
    private var waitingContinuations: [String: [CheckedContinuation<String, Never>]] = [:]
    
    private var isLoading = false
    
    private init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self) else {
            fatalError("Failed to resolve Session in UserProfileImageBatchLoader")
        }
        guard let resolvedDBPool = DependencyManager.shared.container.resolve(DatabasePool.self) else {
            fatalError("Failed to resolve DatabasePool in UserProfileImageBatchLoader")
        }
        self.session = resolvedSession
        self.userDao = UserDao(dbPool: resolvedDBPool)
        self.partialUserDao = PartialUserDao(dbPool: resolvedDBPool)
    }
    
    func loadIcons(for comments: [Comment]) async -> String {
        guard let callingComment = comments.first,
              let callingAuthorFullname = callingComment.authorFullname,
              let callingAuthorUsername = callingComment.author else {
            return ""
        }
        
        if let cached = cache[callingAuthorFullname] {
            return cached
        }
        
        if let partialUserData = try? await partialUserDao.getPartialUserData(username: callingAuthorUsername) {
            print("from partial database")
            let iconUrlString = partialUserData.profileImageUrlString
            cache[callingAuthorFullname] = iconUrlString
            return iconUrlString
        }
        
        if let userData = try? await userDao.getUserData(username: callingAuthorUsername) {
            print("from database")
            let iconUrlString = userData.iconUrl ?? ""
            cache[callingAuthorFullname] = iconUrlString
            return iconUrlString
        }
        
        if inFlight.contains(callingAuthorFullname) {
            return await withCheckedContinuation { continuation in
                waitingContinuations[callingAuthorFullname, default: []].append(continuation)
            }
        }
        
        let batch = comments
            .map(\.authorFullname)
            .filter { !cache.keys.contains($0) && !inFlight.contains($0) }
            .prefix(UserProfileImageBatchLoader.batchSize)
        
        for author in batch {
            inFlight.insert(author)
        }
        
        loadingQueue.append(contentsOf: batch)
        
        Task {
            await processNextBatchIfNeeded()
        }
        
        return await withCheckedContinuation { continuation in
            waitingContinuations[callingAuthorFullname, default: []].append(continuation)
        }
    }
    
    private func processNextBatchIfNeeded() async {
        guard !isLoading, !loadingQueue.isEmpty else { return }

        isLoading = true

        let batch = Array(loadingQueue.prefix(UserProfileImageBatchLoader.batchSize))
        loadingQueue.removeFirst(min(UserProfileImageBatchLoader.batchSize, loadingQueue.count))

        do {
            let result = try await fetchIcons(for: batch)

            for author in batch {
                let url = result[author]
                resumeWaiters(author: author, url: url ?? "")
            }
        } catch {
            for author in batch {
                resumeWaiters(author: author, url: "")
            }
        }

        isLoading = false
        await processNextBatchIfNeeded()
    }
    
    private func fetchIcons(for authors: [String]) async throws -> [String: String] {
        try Task.checkCancellation()
        
        let data = try await self.session.request(
            RedditAPI.getPartialUserData(queries: ["ids": authors.joined(separator: ",")])
        )
            .validate()
            .serializingData(automaticallyCancelling: true)
            .value
        
        try Task.checkCancellation()
        
        let json = JSON(data)
        if let error = json.error {
            throw UserProfileImageBatchLoaderError.JSONDecodingError(error.localizedDescription)
        }
        
        let partialUserDataListing = try PartialUserDataListing(fromJson: json)
        
        try? await partialUserDao.insertAll(Array(partialUserDataListing.partialUserDataDictionary.values))
        
        return partialUserDataListing.partialUserDataDictionary.mapValues { partialUserData in
            partialUserData.profileImageUrlString
        }
    }
    
    private func resumeWaiters(author: String, url: String) {
        cache[author] = url
        inFlight.remove(author)
        if let continuations = waitingContinuations[author] {
            for continuation in continuations {
                continuation.resume(returning: url)
            }
            waitingContinuations[author] = nil
        }
    }
}
