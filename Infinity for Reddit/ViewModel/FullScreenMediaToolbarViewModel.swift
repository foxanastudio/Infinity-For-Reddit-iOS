//
//  FullScreenMediaToolbarViewModel.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-24.
//

import Foundation
import UIKit
import Kingfisher

class FullScreenMediaToolbarViewModel: ObservableObject {
    @Published var downloadProgress: Double = 0
    @Published var downloadGalleryAllMediaProgress: Double = 0
    @Published var downloadImgurAllMediaProgress: Double = 0
    @Published var showFinishedDownloadAllMediaMessage: Bool = false
    @Published var showFinishedDownloadMessage: Bool = false
    @Published var error: Error?
    
    private let downloadMediaType: DownloadMediaType
    private var downloadTask: Task<Void, Never>?
    private var downloadGalleryAllMediaTask: Task<Void, Never>?
    private var downloadImgurAllMediaTask: Task<Void, Never>?
    private var shareTask: Task<Void, Never>?
    
    enum FullScreenMediaToolbarError: LocalizedError {
        case invalidURL
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            }
        }
    }
    
    init(downloadMediaType: DownloadMediaType) {
        self.downloadMediaType = downloadMediaType
    }

    func downloadMedia() {
        guard downloadTask == nil else {
            return
        }
        
        downloadTask = Task {
            await self.downloadMediaAsync()
        }
    }
    
    private func downloadMediaAsync() async {
        do {
            try await MediaDownloader.shared.download(downloadMediaType: downloadMediaType, onProgressWithTitle: { _, progress in
                await MainActor.run {
                    self.downloadProgress = progress
                }
            })
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
        
        await MainActor.run {
            self.downloadProgress = 0
            self.showFinishedDownloadMessage = true
        }
        
        do {
            try await Task.sleep(for: .seconds(1))
        } catch {
            // Ignore
        }
        
        await MainActor.run {
            self.showFinishedDownloadMessage = false
            self.downloadTask = nil
        }
    }
    
    func downloadAllGalleryMedia(items: [GalleryItem], post: Post?) {
        guard downloadGalleryAllMediaTask == nil else {
            return
        }
        
        downloadGalleryAllMediaTask = Task {
            await withTaskGroup(of: Void.self) { group in
                for item in items {
                    group.addTask { [weak self] in
                        await self?.downloadGalleryOrImgurItemMediaAsync(downloadMediaType: item.toDownloadMediaType(post: post))
                    }
                }
                
                for await _ in group {
                    await MainActor.run { [weak self] in
                        self?.downloadGalleryAllMediaProgress = min(1, (self?.downloadGalleryAllMediaProgress ?? 0) + 1 / Double(items.count))
                    }
                }
                
                await MainActor.run {
                    self.downloadGalleryAllMediaProgress = 0
                    self.showFinishedDownloadAllMediaMessage = true
                }
                
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    // Ignore
                }
                
                await MainActor.run {
                    self.showFinishedDownloadAllMediaMessage = false
                    self.downloadGalleryAllMediaTask = nil
                }
            }
        }
    }
    
    func downloadAllImgurMedia(imgurMedia: ImgurMedia, post: Post?) {
        guard downloadImgurAllMediaTask == nil else {
            return
        }
        
        downloadImgurAllMediaTask = Task {
            await withTaskGroup(of: Void.self) { group in
                for item in imgurMedia.images {
                    group.addTask { [weak self] in
                        await self?.downloadGalleryOrImgurItemMediaAsync(downloadMediaType: item.toDownloadMediaType(post: post))
                    }
                }
                
                for await _ in group {
                    await MainActor.run { [weak self] in
                        self?.downloadImgurAllMediaProgress = min(1, (self?.downloadImgurAllMediaProgress ?? 0) + 1 / Double(imgurMedia.images.count))
                    }
                }
                
                await MainActor.run {
                    self.downloadImgurAllMediaProgress = 0
                    self.showFinishedDownloadAllMediaMessage = true
                }
                
                do {
                    try await Task.sleep(for: .seconds(1))
                } catch {
                    // Ignore
                }
                
                await MainActor.run {
                    self.showFinishedDownloadAllMediaMessage = false
                    self.downloadImgurAllMediaTask = nil
                }
            }
        }
    }
    
    private func downloadGalleryOrImgurItemMediaAsync(downloadMediaType: DownloadMediaType) async {
        do {
            try await MediaDownloader.shared.download(downloadMediaType: downloadMediaType, onProgressWithTitle: { _, _ in })
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    func shareImage() {
        guard shareTask == nil else {
            return
        }
        
        shareTask = Task {
            do {
                let image = try await getCachedImage()
                if let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = await windowScene.windows.first?.rootViewController {
                    let activityVC = await UIActivityViewController(activityItems: [image], applicationActivities: nil)
                    await rootVC.present(activityVC, animated: true)
                }
            } catch {
                print(error.localizedDescription)
                self.error = error
            }
            
            await MainActor.run {
                self.downloadProgress = 0
                self.shareTask = nil
            }
        }
    }
    
    private func getCachedImage() async throws -> UIImage {
        let url = await downloadMediaType.getDownloadUrl()
        
        guard let url else {
            throw FullScreenMediaToolbarError.invalidURL
        }
        
        let urlString = url.absoluteString
        
        let cache = KingfisherManager.shared.cache

        // First try memory cache
        if let image = cache.retrieveImageInMemoryCache(forKey: urlString) {
            return image
        }

        // Then try disk cache
        if let image = try await cache.retrieveImageInDiskCache(forKey: urlString) {
            return image
        }

        // If not cached, download it
        let result = try await KingfisherManager.shared.retrieveImage(with: url)
        return result.image
    }
}
