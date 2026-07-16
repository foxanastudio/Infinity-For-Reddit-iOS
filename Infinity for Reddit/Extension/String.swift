//
//  String.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-06-24.
//

import Foundation

extension String {
    func matches(_ pattern: String) -> Bool {
        return self.range(of: pattern, options: .regularExpression) != nil
    }
    
    func substring(from index: Int) -> String {
        guard index < count else {
            return ""
        }
        
        let start = self.index(startIndex, offsetBy: index)
        return String(self[start...])
    }
    
    func substring(to index: Int) -> String {
        guard index < count else {
            return self
        }
        
        let end = self.index(startIndex, offsetBy: index)
        return String(self[...end])
    }
    
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }
    
    func inserting(_ new: String, at index: Int) -> String {
        let i = self.index(self.startIndex, offsetBy: index)
        return String(self[..<i]) + new + String(self[i...])
    }
    
    func ensureHTTPS() -> String {
        guard var components = URLComponents(string: self) else {
            return self
        }

        if components.scheme?.lowercased() == "http" {
            components.scheme = "https"
        }

        return components.string ?? self
    }
}
