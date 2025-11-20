//
//  FontUtils.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2025-11-19.
//

import Foundation
import CoreText

class FontUtils {
    private static var customFontsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("CustomFonts")
    }

    static func uploadCustomFontFamily(from sourceURL: URL) -> Bool {
        let destinationURL = customFontsDirectory.appendingPathComponent(sourceURL.lastPathComponent)

        try? FileManager.default.createDirectory(at: customFontsDirectory, withIntermediateDirectories: true)

        try? FileManager.default.removeItem(at: destinationURL)
        guard (try? FileManager.default.copyItem(at: sourceURL, to: destinationURL)) != nil else {
            print("Failed to copy font file.")
            return false
        }

        guard let fontData = try? Data(contentsOf: destinationURL),
              let provider = CGDataProvider(data: fontData as CFData),
              let font = CGFont(provider),
              let postScriptName = font.postScriptName as String? else {
            print("Failed to process font file.")
            try? FileManager.default.removeItem(at: destinationURL)
            return false
        }

        guard registerFont(from: destinationURL) else {
            try? FileManager.default.removeItem(at: destinationURL)
            return false
        }

        UserDefaults.interfaceFont.set(postScriptName, forKey: InterfaceFontUserDefaultsUtils.customFontPostScriptNameKey)
        UserDefaults.interfaceFont.set(sourceURL.lastPathComponent, forKey: InterfaceFontUserDefaultsUtils.customFontFileNameKey)
        UserDefaults.interfaceFont.set(font.fullName as String? ?? postScriptName, forKey: InterfaceFontUserDefaultsUtils.customFontDisplayNameKey)

        return true
    }

    static func registerCustomFonts() {
        guard let fileName = InterfaceFontUserDefaultsUtils.customFontFileName else {
            return
        }

        let fontURL = customFontsDirectory.appendingPathComponent(fileName)

        guard FileManager.default.fileExists(atPath: fontURL.path) else {
            return
        }

        registerFont(from: fontURL)
    }

    private static func registerFont(from url: URL) -> Bool {
        var error: Unmanaged<CFError>?

        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)

        if let error = error {
            let cfError = error.takeRetainedValue() as Error as NSError
            if cfError.code == 105 || cfError.code == 305 {
                print("Font already registered.")
                return true
            }
            print("Failed to register font: \(cfError)")
            return false
        }

        return true
    }
}
