//
//  TagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

struct TagAssociation{
    private(set) var wordPairId : String
    private(set) var tagId : String
    
    init (wordPairId: String, tagId : String) {
        self.wordPairId = wordPairId
        self.tagId = tagId
    }
    
    public init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        guard let wordPairId = jsonResult["wordPairId"] as? String else {fatalError()}
        guard let tagId = jsonResult["tagId"] as? String else {fatalError()}
        
        self.wordPairId = wordPairId
        self.tagId = tagId
        
    }
    
    public func toJson() -> String {
        var representation = [String: AnyObject]()
        representation["wordPairId"] = wordPairId as AnyObject?
        representation["tagId"] = tagId as AnyObject?
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
}
