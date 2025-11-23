//
//  UserFlair.swift
//  Infinity for Reddit
//
//  Created by Docile Alligator on 2025-11-17.
//

import Foundation
import SwiftyJSON

public class UserFlair {
    var allowableContent : String
    var backgroundColor : String
    var cssClass : String
    var id : String
    var maxEmojis : Int
    var modOnly : Bool
    var overrideCss : Bool
    var richtext : [FlairRichtext]
    var text : String
    var textColor : String
    var textEditable : Bool
    var type : String

    init(fromJson json: JSON!) throws {
        if json.isEmpty {
            throw JSONError.invalidData
        }
        allowableContent = json["allowable_content"].stringValue
        backgroundColor = json["background_color"].stringValue
        cssClass = json["css_class"].stringValue
        id = json["id"].stringValue
        maxEmojis = json["max_emojis"].intValue
        modOnly = json["mod_only"].boolValue
        overrideCss = json["override_css"].boolValue
        richtext = [FlairRichtext]()
        let richtextArray = json["richtext"].arrayValue
        for richtextJson in  richtextArray {
            do {
                let value = try FlairRichtext(fromJson: richtextJson)
                richtext.append(value)
            } catch {
                // Ignore
            }
        }
        text = json["text"].stringValue
        textColor = json["text_color"].stringValue
        textEditable = json["text_editable"].boolValue
        type = json["type"].stringValue
    }
}
