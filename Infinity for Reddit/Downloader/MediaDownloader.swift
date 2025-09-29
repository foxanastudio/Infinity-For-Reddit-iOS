//
//  MediaDownloader.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-09-23.
//

import Alamofire
import Foundation
import UIKit
import Photos

class MediaDownloader {
    enum MediaDownloaderError: Error {
        case invalidURL
        case invalidRedditVideo
        case cannotLoadVideoTrack
        case cannotLoadAudioTrack
        case cannotAddVideoOrAudioTrackToExportedVideo
        case cannotGetVideoExportSession
        case failedToExportRedditVideoToTempDirectory
        case decodeImageError
        case saveToPhotosLibraryFailed
    }
    
    static let shared = MediaDownloader()
    
    private let session: Session
    private let possibleRedditVideoAudioTrackURLSuffices = ["/DASH_AUDIO_128.mp4", "/DASH_audio.mp4", "/DASH_audio", "/audio.mp4", "/audio"]
    
    private init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self, name: "plain") else {
            fatalError("Failed to resolve plain Session in MediaDownloader")
        }
        self.session = resolvedSession
    }
    
    func download(downloadMediaType: DownloadMediaType, onProgress: @escaping (Double) async -> Void) async throws {
        if case .redditVideo(let post) = downloadMediaType {
            return try await downloadRedditVideo(post: post, fileName: downloadMediaType.fileName)
        }
        
        let downloadedFileURL = try await downloadFile(
            downloadURL: await downloadMediaType.getDownloadUrl(),
            fileName: downloadMediaType.fileName,
            onProgress: onProgress
        )
        
        switch downloadMediaType {
        case .image:
            try saveImageToPhotosLibrary(downloadedFileURL)
        case .gif:
            try await saveGifToPhotosLibrary(downloadedFileURL)
        case .redditVideo:
            //Impossible to reach here
            break
        case .video:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .gallery:
            // TODO
            break
        case .redgifs:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .streamable:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .imgurVideo:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        }
    }
    
    private func downloadFile(downloadURL: URL?, fileName: String, onProgress: @escaping (Double) async -> Void) async throws -> URL {
        guard let downloadURL = downloadURL else {
            throw MediaDownloaderError.invalidURL
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let request = session.download(downloadURL, to: destination)
        
        Task {
            for await progress in request.downloadProgress() {
                print("Progress: \(progress.fractionCompleted)")
                await onProgress(progress.fractionCompleted)
            }
        }
        
        return try await request.serializingDownloadedFileURL().value
    }
    
    private func downloadRedditVideo(post: Post, fileName: String) async throws {
        guard case .video(_, let downloadUrl) = post.postType, let downloadURL = URL(string: downloadUrl) else {
            throw MediaDownloaderError.invalidRedditVideo
        }

        let videoTrackDownloadedFileURL = try await downloadFile(downloadURL: downloadURL, fileName: "video_track.mp4", onProgress: { _ in })
        var audioTrackDownloadedFileURL: URL?
        if let lastSlashIndex = downloadUrl.lastIndex(of: "/") {
            let audioUrlPrefix = String(downloadUrl[..<lastSlashIndex])
            for suffix in possibleRedditVideoAudioTrackURLSuffices {
                if let audioUrl = URL(string: audioUrlPrefix + suffix) {
                    print(audioUrl)
                    do {
                        audioTrackDownloadedFileURL = try await downloadFile(downloadURL: audioUrl, fileName: "audio_track.mp4", onProgress: { _ in })
                        break
                    } catch {
                        // Ignore
                    }
                }
            }
        }
        
        print(audioTrackDownloadedFileURL?.absoluteString ?? "No audio track")
        if let audioTrackDownloadedFileURL {
            let exportedMuxedVideoURL = try await muxVideoAndAudio(downloadedVideoURL: videoTrackDownloadedFileURL, downloadedAudioURL: audioTrackDownloadedFileURL, fileName: fileName)
            try await saveVideoToPhotosLibrary(exportedMuxedVideoURL)
        } else {
            try await saveVideoToPhotosLibrary(videoTrackDownloadedFileURL)
        }
    }
    
    private func muxVideoAndAudio(downloadedVideoURL: URL, downloadedAudioURL: URL, fileName: String) async throws -> URL {
        let exportedVideo = AVMutableComposition()
        let exportedVideoTrack = exportedVideo.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
        let exportedAudioTrack = exportedVideo.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let videoAsset = AVURLAsset(url: downloadedVideoURL)
        let audioAsset = AVURLAsset(url: downloadedAudioURL)
        
        guard let downloadedVideoTrack = try await videoAsset.loadTracks(withMediaType: .video).first else {
            throw MediaDownloaderError.cannotLoadVideoTrack
        }
        
        let tracks = try await audioAsset.loadTracks(withMediaType: .audio)
        for (index, track) in tracks.enumerated() {
            let duration = try await audioAsset.load(.duration).seconds
            print("Duration: \(String(format: "%.2f", duration)) seconds")
        }
        
        guard let downloadedAudioTrack = try await audioAsset.loadTracks(withMediaType: .audio).first else {
            throw MediaDownloaderError.cannotLoadAudioTrack
        }
        
        let exportSession = AVAssetExportSession(asset: exportedVideo,
                                            presetName: AVAssetExportPresetHighestQuality)
        guard let exportSession = exportSession else {
            throw MediaDownloaderError.cannotGetVideoExportSession
        }

        let exportedVideoRange = CMTimeRangeMake(start: CMTime.zero, duration: try await videoAsset.load(.duration))
        let exportedAudioRange = CMTimeRangeMake(start: CMTime.zero, duration: try await audioAsset.load(.duration))
        do {
            try exportedVideoTrack?.insertTimeRange(exportedVideoRange, of: downloadedVideoTrack, at: CMTime.zero)
            try exportedAudioTrack?.insertTimeRange(exportedAudioRange, of: downloadedAudioTrack, at: CMTime.zero)
        } catch {
            throw MediaDownloaderError.cannotAddVideoOrAudioTrackToExportedVideo
        }
        
        guard await AVAssetExportSession.compatibility(ofExportPreset: AVAssetExportPresetHighestQuality,
                                                       with: exportedVideo,
                                                       outputFileType: .mov) else {
            throw MediaDownloaderError.cannotGetVideoExportSession
        }
        
        let exportedURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: exportedURL.path) {
            try FileManager.default.removeItem(at: exportedURL)
        }
        exportSession.outputURL = exportedURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        do {
            try await exportSession.export(to: exportedURL, as: .mp4)
            return exportedURL
        } catch {
            print(error)
            throw MediaDownloaderError.failedToExportRedditVideoToTempDirectory
        }
    }
    
    private func saveImageToPhotosLibrary(_ downloadedFileURL: URL) throws {
        let data = try Data(contentsOf: downloadedFileURL)
        guard let image = UIImage(data: data) else {
            throw MediaDownloaderError.decodeImageError
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    private func saveGifToPhotosLibrary(_ downloadedFileURL: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: downloadedFileURL)
            }) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: MediaDownloaderError.saveToPhotosLibraryFailed)
                }
            }
        }
    }
    
    private func saveVideoToPhotosLibrary(_ downloadedFileURL: URL) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: downloadedFileURL)
            }) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: MediaDownloaderError.saveToPhotosLibraryFailed)
                }
            }
        }
    }
}

enum DownloadMediaType {
    case image(downloadUrlString: String, fileName: String)
    case gif(downloadUrlString: String, fileName: String)
    case redditVideo(post: Post)
    case video(downloadUrlString: String, fileName: String)
    case gallery(galleryItems: [GalleryItem], fileName: String)
    case redgifs(redgifsId: String, downloadUrlString: String?)
    case streamable(shortCode: String, downloadUrlString: String?)
    case imgurVideo(downloadUrlString: String, fileName: String)
    
    var fileName: String {
        switch self {
        case .image(_, let fileName):
            return fileName
        case .gif(_, let fileName):
            return fileName
        case .redditVideo(let post):
            return post.subreddit + "-" + post.id + ".mp4"
        case .video(_, let fileName):
            return fileName
        case .gallery(_, let fileName):
            return fileName
        case .redgifs(let redgifsId, _):
            return "Redgifs-\(redgifsId).mp4"
        case .streamable(let shortCode, _):
            return "Streamable-\(shortCode).mp4"
        case .imgurVideo(_, let fileName):
            return fileName
        }
    }
    
    func getDownloadUrl() async -> URL? {
        switch self {
        case .image(let downloadUrlString, _):
            return URL(string: downloadUrlString)
        case .gif(let downloadUrlString, _):
            return URL(string: downloadUrlString)
        case .redditVideo:
            // Need to mux the video and audio tracks so don't get the download url here
            return nil
        case .video(let downloadUrlString, _):
            return URL(string: downloadUrlString)
        case .gallery(_, let fileName):
            // Handle gallery media download
            return nil
        case .redgifs(let redgifsId, let downloadUrlString):
            if let downloadUrlString {
                return URL(string: downloadUrlString)
            }
            return try? await VideoFetcher.shared.fetchRedgifsVideo(id: redgifsId)
        case .streamable(let shortCode, let downloadUrlString):
            if let downloadUrlString {
                return URL(string: downloadUrlString)
            }
            return try? await VideoFetcher.shared.fetchStreamableVideo(shortCode: shortCode)
        case .imgurVideo(let downloadUrlString, _):
            // TODO need to check if this is the real download url
            return URL(string: downloadUrlString)
        }
    }
}
