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
    @Published var error: Error?
    
    private let downloadMediaType: DownloadMediaType
    private var downloadTask: Task<Void, Never>?
    private var shareTask: Task<Void, Never>?
    
    enum FullScreenMediaToolbarError: Error {
        case invalidURL
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
            try await MediaDownloader.shared.download(downloadMediaType: downloadMediaType, onProgress: { progress in
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
            self.downloadTask = nil
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
