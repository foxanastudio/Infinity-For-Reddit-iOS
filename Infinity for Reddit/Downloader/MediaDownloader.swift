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
    enum MediaDownloaderError: LocalizedError {
        case invalidURL
        case invalidRedditVideo
        case cannotLoadVideoTrack
        case cannotLoadAudioTrack
        case cannotAddVideoOrAudioTrackToExportedVideo
        case cannotGetVideoExportSession
        case failedToExportRedditVideoToTempDirectory
        case decodeImageError
        case saveToPhotosLibraryFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL."
            case .invalidRedditVideo:
                return "Invalid Reddit Video URL."
            case .cannotLoadVideoTrack:
                return "Cannot load video track."
            case .cannotLoadAudioTrack:
                return "Cannot load audio track."
            case .cannotAddVideoOrAudioTrackToExportedVideo:
                return "Cannot add video or audio track to exported video."
            case .cannotGetVideoExportSession:
                return "Cannot get video export session."
            case .failedToExportRedditVideoToTempDirectory:
                return "Failed to export Reddit video to temp directory."
            case .decodeImageError:
                return "Decode image error."
            case .saveToPhotosLibraryFailed:
                return "Save to photos library failed."
            }
        }
    }
    
    static let shared = MediaDownloader()
    
    private let session: Session
    private let possibleRedditVideoAudioTrackURLSuffices = ["/CMAF_AUDIO_128.mp4", "/CMAF_AUDIO_64.mp4", "/DASH_AUDIO_128.mp4", "/DASH_audio.mp4", "/DASH_audio", "/audio.mp4", "/audio"]
    
    private init() {
        guard let resolvedSession = DependencyManager.shared.container.resolve(Session.self, name: "plain") else {
            fatalError("Failed to resolve plain Session in MediaDownloader")
        }
        self.session = resolvedSession
    }
    
    func download(downloadMediaType: DownloadMediaType, onProgressWithTitle: @escaping (String, Double) async -> Void) async throws {
        if case .redditVideo(let post) = downloadMediaType {
            return try await downloadRedditVideo(post: post, fileName: downloadMediaType.fileName, onProgressWithTitle: onProgressWithTitle)
        }
        
        let downloadedFileURL = try await downloadFile(
            downloadURL: await downloadMediaType.getDownloadUrl(),
            fileName: downloadMediaType.fileName,
            onProgress: { progress in
                await onProgressWithTitle("Downloading...", progress)
            }
        )
        
        switch downloadMediaType {
        case .image, .gif:
            try await saveImageOrGifToPhotosLibrary(downloadedFileURL)
        case .redditVideo:
            //Impossible to reach here
            break
        case .video:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .vReddIt:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .redgifs:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .streamable:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .imgurVideo:
            try await saveVideoToPhotosLibrary(downloadedFileURL)
        case .gallery:
            // TODO
            break
        }
    }
    
    private func downloadFile(downloadURL: URL?, fileName: String, onProgress: @escaping (Double) async -> Void) async throws -> URL {
        guard let downloadURL = downloadURL else {
            throw MediaDownloaderError.invalidURL
        }
        
        let destination: DownloadRequest.Destination = { _, _ in
            let fileURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        let request = session.download(downloadURL, to: destination).validate()
        
        Task {
            for await progress in request.downloadProgress() {
                if progress.isFinished {
                    break
                }
                print("Progress: \(downloadURL.absoluteString) \(progress.fractionCompleted)")
                await onProgress(progress.fractionCompleted)
            }
        }
        
        return try await request.serializingDownloadedFileURL().value
    }
    
    private func downloadRedditVideo(post: Post, fileName: String, onProgressWithTitle: @escaping (String, Double) async -> Void) async throws {
        guard case .redditVideo(_, let downloadUrlString) = post.postType, let downloadURL = URL(string: downloadUrlString) else {
            throw MediaDownloaderError.invalidRedditVideo
        }

        let videoTrackDownloadedFileURL = try await downloadFile(downloadURL: downloadURL, fileName: "video_track.mp4", onProgress: { progress in
            await onProgressWithTitle("Downloading video track...", progress)
        })
        var audioTrackDownloadedFileURL: URL?
        if let lastSlashIndex = downloadUrlString.lastIndex(of: "/") {
            let audioUrlPrefix = String(downloadUrlString[..<lastSlashIndex])
            for suffix in possibleRedditVideoAudioTrackURLSuffices {
                if let audioUrl = URL(string: audioUrlPrefix + suffix) {
                    print(audioUrl)
                    do {
                        audioTrackDownloadedFileURL = try await downloadFile(downloadURL: audioUrl, fileName: "audio_track.mp4", onProgress: { progress in
                            await onProgressWithTitle("Downloading audio track...", progress)
                        })
                        break
                    } catch {
                        // Ignore
                        audioTrackDownloadedFileURL = nil
                    }
                }
            }
        }

        if let audioTrackDownloadedFileURL {
            do {
                await onProgressWithTitle("Muxing video and audio...", 0)
                let exportedMuxedVideoURL = try await muxVideoAndAudio(downloadedVideoURL: videoTrackDownloadedFileURL, downloadedAudioURL: audioTrackDownloadedFileURL, fileName: fileName)
                try await saveVideoToPhotosLibrary(exportedMuxedVideoURL)
            } catch {
                try await saveRedditVideoWithOnlyVideoTrackToPhotosLibrary(videoTrackDownloadedFileURL, fileName: fileName)
            }
        } else {
            try await saveRedditVideoWithOnlyVideoTrackToPhotosLibrary(videoTrackDownloadedFileURL, fileName: fileName)
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
        
        let exportedURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
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
    
    private func saveRedditVideoWithOnlyVideoTrackToPhotosLibrary(_ videoTrackDownloadedFileURL: URL, fileName: String) async throws {
        let newFileNamePath = videoTrackDownloadedFileURL.deletingLastPathComponent().appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: newFileNamePath.path()) {
            try FileManager.default.removeItem(at: newFileNamePath)
        }
        try FileManager.default.moveItem(at: videoTrackDownloadedFileURL, to: newFileNamePath)
        try await saveVideoToPhotosLibrary(newFileNamePath)
    }
    
    private func saveImageOrGifToPhotosLibrary(_ downloadedFileURL: URL) async throws {
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
    case vReddIt(urlString: String, downloadUrlString: String?)
    case redgifs(redgifsId: String, downloadUrlString: String?)
    case streamable(shortCode: String, downloadUrlString: String?)
    case imgurVideo(downloadUrlString: String, fileName: String)
    case gallery(galleryItems: [GalleryItem], fileName: String)
    
    var fileName: String {
        switch self {
        case .image(_, let fileName):
            return fileName
        case .gif(_, let fileName):
            return fileName
        case .redditVideo(let post):
            return "\(post.fileNameWithoutExtension).mp4"
        case .video(_, let fileName):
            return fileName
        case .vReddIt(urlString: let urlString, downloadUrlString: let downloadUrlString):
            // Should not get file name here
            return "vReddIt-\(Utils.randomString()).mp4"
        case .redgifs(let redgifsId, _):
            return "Redgifs-\(redgifsId).mp4"
        case .streamable(let shortCode, _):
            return "Streamable-\(shortCode).mp4"
        case .imgurVideo(_, let fileName):
            return fileName
        case .gallery(_, let fileName):
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
        case .vReddIt(let urlString, let downloadUrlString):
            if let downloadUrlString {
                return URL(string: downloadUrlString)
            }
            if let url = URL(string: urlString) {
                return try? await VideoFetcher.shared.fetchVReddItVideo(url: url)
            }
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
        case .gallery(_, let fileName):
            // Handle gallery media download
            return nil
        }
    }
}
