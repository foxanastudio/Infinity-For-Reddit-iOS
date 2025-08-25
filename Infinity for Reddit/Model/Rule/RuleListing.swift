//
// RuleListing.swift
// Infinity for Reddit
//
// Created by joeylr2042 on 2025-08-24

import Foundation
import SwiftyJSON


class RuleRootClass : NSObject, NSCoding {

    var rules : [RuleListing]!
    var siteRules : [String]!
    var siteRulesFlow : [SiteRulesFlow]!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        rules = [RuleListing]()
        let rulesArray = json["rules"].arrayValue
        for rulesJson in rulesArray{
            let value = RuleListing(fromJson: rulesJson)
            rules.append(value)
        }
        siteRules = [String]()
        let siteRulesArray = json["site_rules"].arrayValue
        for siteRulesJson in siteRulesArray{
            siteRules.append(siteRulesJson.stringValue)
        }
        siteRulesFlow = [SiteRulesFlow]()
        let siteRulesFlowArray = json["site_rules_flow"].arrayValue
        for siteRulesFlowJson in siteRulesFlowArray{
            let value = SiteRulesFlow(fromJson: siteRulesFlowJson)
            siteRulesFlow.append(value)
        }
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if rules != nil{
            var dictionaryElements = [[String:Any]]()
            for rulesElement in rules {
                dictionaryElements.append(rulesElement.toDictionary())
            }
            dictionary["rules"] = dictionaryElements
        }
        if siteRules != nil{
            dictionary["site_rules"] = siteRules
        }
        if siteRulesFlow != nil{
            var dictionaryElements = [[String:Any]]()
            for siteRulesFlowElement in siteRulesFlow {
                dictionaryElements.append(siteRulesFlowElement.toDictionary())
            }
            dictionary["site_rules_flow"] = dictionaryElements
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         rules = aDecoder.decodeObject(forKey: "rules") as? [RuleListing]
         siteRules = aDecoder.decodeObject(forKey: "site_rules") as? [String]
         siteRulesFlow = aDecoder.decodeObject(forKey: "site_rules_flow") as? [SiteRulesFlow]

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
    {
        if rules != nil{
            aCoder.encode(rules, forKey: "rules")
        }
        if siteRules != nil{
            aCoder.encode(siteRules, forKey: "site_rules")
        }
        if siteRulesFlow != nil{
            aCoder.encode(siteRulesFlow, forKey: "site_rules_flow")
        }

    }
    
    public func toRules() -> [Rule] {
        guard let rules = self.rules else { return [] }
        
        return rules.compactMap { rule in
            guard let shortName = rule.shortName else { return nil }
            let descriptionHtml = rule.descriptionHtml ?? ""
            
            return Rule(shortName: shortName, descriptionHtml: descriptionHtml)
        }
    }
}

class SiteRulesFlow : NSObject, NSCoding {

    var nextStepHeader : String!
    var nextStepReasons : [NextStepReason]!
    var reasonText : String!
    var reasonTextToShow : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        nextStepHeader = json["nextStepHeader"].stringValue
        nextStepReasons = [NextStepReason]()
        let nextStepReasonsArray = json["nextStepReasons"].arrayValue
        for nextStepReasonsJson in nextStepReasonsArray{
            let value = NextStepReason(fromJson: nextStepReasonsJson)
            nextStepReasons.append(value)
        }
        reasonText = json["reasonText"].stringValue
        reasonTextToShow = json["reasonTextToShow"].stringValue
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if nextStepHeader != nil{
            dictionary["nextStepHeader"] = nextStepHeader
        }
        if nextStepReasons != nil{
            var dictionaryElements = [[String:Any]]()
            for nextStepReasonsElement in nextStepReasons {
                dictionaryElements.append(nextStepReasonsElement.toDictionary())
            }
            dictionary["nextStepReasons"] = dictionaryElements
        }
        if reasonText != nil{
            dictionary["reasonText"] = reasonText
        }
        if reasonTextToShow != nil{
            dictionary["reasonTextToShow"] = reasonTextToShow
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         nextStepHeader = aDecoder.decodeObject(forKey: "nextStepHeader") as? String
         nextStepReasons = aDecoder.decodeObject(forKey: "nextStepReasons") as? [NextStepReason]
         reasonText = aDecoder.decodeObject(forKey: "reasonText") as? String
         reasonTextToShow = aDecoder.decodeObject(forKey: "reasonTextToShow") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
    {
        if nextStepHeader != nil{
            aCoder.encode(nextStepHeader, forKey: "nextStepHeader")
        }
        if nextStepReasons != nil{
            aCoder.encode(nextStepReasons, forKey: "nextStepReasons")
        }
        if reasonText != nil{
            aCoder.encode(reasonText, forKey: "reasonText")
        }
        if reasonTextToShow != nil{
            aCoder.encode(reasonTextToShow, forKey: "reasonTextToShow")
        }

    }

}

class NextStepReason : NSObject, NSCoding {

    var reasonText : String!
    var reasonTextToShow : String!
    var canSpecifyUsernames : Bool!
    var complaintButtonText : String!
    var complaintPageTitle : String!
    var complaintPrompt : String!
    var complaintUrl : String!
    var fileComplaint : Bool!
    var nextStepHeader : String!
    var nextStepReasons : [NextStepReason]!
    var oneUsername : Bool!
    var requestCrisisSupport : Bool!
    var usernamesInputTitle : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        reasonText = json["reasonText"].stringValue
        reasonTextToShow = json["reasonTextToShow"].stringValue
        canSpecifyUsernames = json["canSpecifyUsernames"].boolValue
        complaintButtonText = json["complaintButtonText"].stringValue
        complaintPageTitle = json["complaintPageTitle"].stringValue
        complaintPrompt = json["complaintPrompt"].stringValue
        complaintUrl = json["complaintUrl"].stringValue
        fileComplaint = json["fileComplaint"].boolValue
        nextStepHeader = json["nextStepHeader"].stringValue
        nextStepReasons = [NextStepReason]()
        let nextStepReasonsArray = json["nextStepReasons"].arrayValue
        for nextStepReasonsJson in nextStepReasonsArray{
            let value = NextStepReason(fromJson: nextStepReasonsJson)
            nextStepReasons.append(value)
        }
        oneUsername = json["oneUsername"].boolValue
        requestCrisisSupport = json["requestCrisisSupport"].boolValue
        usernamesInputTitle = json["usernamesInputTitle"].stringValue
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if reasonText != nil{
            dictionary["reasonText"] = reasonText
        }
        if reasonTextToShow != nil{
            dictionary["reasonTextToShow"] = reasonTextToShow
        }
        if canSpecifyUsernames != nil{
            dictionary["canSpecifyUsernames"] = canSpecifyUsernames
        }
        if complaintButtonText != nil{
            dictionary["complaintButtonText"] = complaintButtonText
        }
        if complaintPageTitle != nil{
            dictionary["complaintPageTitle"] = complaintPageTitle
        }
        if complaintPrompt != nil{
            dictionary["complaintPrompt"] = complaintPrompt
        }
        if complaintUrl != nil{
            dictionary["complaintUrl"] = complaintUrl
        }
        if fileComplaint != nil{
            dictionary["fileComplaint"] = fileComplaint
        }
        if nextStepHeader != nil{
            dictionary["nextStepHeader"] = nextStepHeader
        }
        if nextStepReasons != nil{
            var dictionaryElements = [[String:Any]]()
            for nextStepReasonsElement in nextStepReasons {
                dictionaryElements.append(nextStepReasonsElement.toDictionary())
            }
            dictionary["nextStepReasons"] = dictionaryElements
        }
        if oneUsername != nil{
            dictionary["oneUsername"] = oneUsername
        }
        if requestCrisisSupport != nil{
            dictionary["requestCrisisSupport"] = requestCrisisSupport
        }
        if usernamesInputTitle != nil{
            dictionary["usernamesInputTitle"] = usernamesInputTitle
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         reasonText = aDecoder.decodeObject(forKey: "reasonText") as? String
         reasonTextToShow = aDecoder.decodeObject(forKey: "reasonTextToShow") as? String
         canSpecifyUsernames = aDecoder.decodeObject(forKey: "canSpecifyUsernames") as? Bool
         complaintButtonText = aDecoder.decodeObject(forKey: "complaintButtonText") as? String
         complaintPageTitle = aDecoder.decodeObject(forKey: "complaintPageTitle") as? String
         complaintPrompt = aDecoder.decodeObject(forKey: "complaintPrompt") as? String
         complaintUrl = aDecoder.decodeObject(forKey: "complaintUrl") as? String
         fileComplaint = aDecoder.decodeObject(forKey: "fileComplaint") as? Bool
         nextStepHeader = aDecoder.decodeObject(forKey: "nextStepHeader") as? String
         nextStepReasons = aDecoder.decodeObject(forKey: "nextStepReasons") as? [NextStepReason]
         oneUsername = aDecoder.decodeObject(forKey: "oneUsername") as? Bool
         requestCrisisSupport = aDecoder.decodeObject(forKey: "requestCrisisSupport") as? Bool
         usernamesInputTitle = aDecoder.decodeObject(forKey: "usernamesInputTitle") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
    {
        if reasonText != nil{
            aCoder.encode(reasonText, forKey: "reasonText")
        }
        if reasonTextToShow != nil{
            aCoder.encode(reasonTextToShow, forKey: "reasonTextToShow")
        }
        if canSpecifyUsernames != nil{
            aCoder.encode(canSpecifyUsernames, forKey: "canSpecifyUsernames")
        }
        if complaintButtonText != nil{
            aCoder.encode(complaintButtonText, forKey: "complaintButtonText")
        }
        if complaintPageTitle != nil{
            aCoder.encode(complaintPageTitle, forKey: "complaintPageTitle")
        }
        if complaintPrompt != nil{
            aCoder.encode(complaintPrompt, forKey: "complaintPrompt")
        }
        if complaintUrl != nil{
            aCoder.encode(complaintUrl, forKey: "complaintUrl")
        }
        if fileComplaint != nil{
            aCoder.encode(fileComplaint, forKey: "fileComplaint")
        }
        if nextStepHeader != nil{
            aCoder.encode(nextStepHeader, forKey: "nextStepHeader")
        }
        if nextStepReasons != nil{
            aCoder.encode(nextStepReasons, forKey: "nextStepReasons")
        }
        if oneUsername != nil{
            aCoder.encode(oneUsername, forKey: "oneUsername")
        }
        if requestCrisisSupport != nil{
            aCoder.encode(requestCrisisSupport, forKey: "requestCrisisSupport")
        }
        if usernamesInputTitle != nil{
            aCoder.encode(usernamesInputTitle, forKey: "usernamesInputTitle")
        }

    }

}

class RuleListing : NSObject, NSCoding{

    var createdUtc : Int!
    var descriptionField : String!
    var descriptionHtml : String!
    var kind : String!
    var priority : Int!
    var shortName : String!
    var violationReason : String!


    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        createdUtc = json["created_utc"].intValue
        descriptionField = json["description"].stringValue
        descriptionHtml = json["description_html"].stringValue
        kind = json["kind"].stringValue
        priority = json["priority"].intValue
        shortName = json["short_name"].stringValue
        violationReason = json["violation_reason"].stringValue
    }

    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if createdUtc != nil{
            dictionary["created_utc"] = createdUtc
        }
        if descriptionField != nil{
            dictionary["description"] = descriptionField
        }
        if descriptionHtml != nil{
            dictionary["description_html"] = descriptionHtml
        }
        if kind != nil{
            dictionary["kind"] = kind
        }
        if priority != nil{
            dictionary["priority"] = priority
        }
        if shortName != nil{
            dictionary["short_name"] = shortName
        }
        if violationReason != nil{
            dictionary["violation_reason"] = violationReason
        }
        return dictionary
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
         createdUtc = aDecoder.decodeObject(forKey: "created_utc") as? Int
         descriptionField = aDecoder.decodeObject(forKey: "description") as? String
         descriptionHtml = aDecoder.decodeObject(forKey: "description_html") as? String
         kind = aDecoder.decodeObject(forKey: "kind") as? String
         priority = aDecoder.decodeObject(forKey: "priority") as? Int
         shortName = aDecoder.decodeObject(forKey: "short_name") as? String
         violationReason = aDecoder.decodeObject(forKey: "violation_reason") as? String

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
    {
        if createdUtc != nil{
            aCoder.encode(createdUtc, forKey: "created_utc")
        }
        if descriptionField != nil{
            aCoder.encode(descriptionField, forKey: "description")
        }
        if descriptionHtml != nil{
            aCoder.encode(descriptionHtml, forKey: "description_html")
        }
        if kind != nil{
            aCoder.encode(kind, forKey: "kind")
        }
        if priority != nil{
            aCoder.encode(priority, forKey: "priority")
        }
        if shortName != nil{
            aCoder.encode(shortName, forKey: "short_name")
        }
        if violationReason != nil{
            aCoder.encode(violationReason, forKey: "violation_reason")
        }

    }

}
