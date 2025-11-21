//
//  UserDetail.swift
//  Infinity for Reddit
//
//  Created by joeylr2042 on 2024-12-02.
//

import Foundation
import SwiftyJSON
import GRDB

class UserDetailRootClass: NSObject {
    var data : User!
    var kind : String!
    
    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        let dataJson = json["data"]
        if !dataJson.isEmpty {
            do {
                data = try User(fromJson: dataJson)
            } catch {
                throw JSONError.invalidData
            }
        }
        kind = json["kind"].stringValue
    }
    
    // Helper method
    public func toUserData() -> UserData {
        return data.toUserData()
    }
}
