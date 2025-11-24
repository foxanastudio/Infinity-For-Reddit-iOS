//
//  Utils.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-10-01.
//

import AVFoundation

class Utils {
    static func randomString(length: Int = 6) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap { _ in letters.randomElement() })
    }
    
    static func checkCameraAvailability() -> Bool {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified) != nil
    }
    
    static func getFileExtension(from urlString: String) -> String? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        let ext = url.pathExtension
        return ext.isEmpty ? nil : ext
    }
    
    static func isGIF(imageData: Data) -> Bool {
        guard imageData.count >= 4 else {
            return false
        }
        let signature = String(bytes: imageData.prefix(4), encoding: .ascii)
        return signature == "GIF8"
    }
    
    static func getFormattedCakeDay(_ epochTime: Int64?) -> String {
        guard let epochTime else {
            return "Unknown"
        }
        
        let date = Date(timeIntervalSince1970: TimeInterval(epochTime))
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: date)
    }
    
    static func getCurrentTimeEpoch() -> Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
}
