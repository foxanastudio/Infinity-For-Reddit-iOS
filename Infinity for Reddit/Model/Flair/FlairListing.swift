//
// FlairListing.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-28
        
import Foundation
import SwiftyJSON


class FlairListing: NSObject, NSCoding {
    
    var id: String?
    var text: String?
    var textEditable: Bool?
    var type: String?
    
    init(fromJson json: JSON) {
        id = json["id"].string
        text = json["text"].string
        textEditable = json["text_editable"].bool
        type = json["type"].string
    }
    
    
    @objc required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? String
        text = aDecoder.decodeObject(forKey: "text") as? String
        textEditable = aDecoder.decodeObject(forKey: "text_editable") as? Bool
        type = aDecoder.decodeObject(forKey: "type") as? String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(text, forKey: "text")
        aCoder.encode(textEditable, forKey: "text_editable")
        aCoder.encode(type, forKey: "type")
    }

}
