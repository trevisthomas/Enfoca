//
//  CloudKitConverters.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitConverters{
    class func toTag(from record: CKRecord) -> Tag {
        guard let name = record.value(forKey: "name") as? String else {
            //This is really bad.  Should probably delete this record
            fatalError()
        }
        
        guard let count = record.value(forKey: "count") as? Int else {
            //This is really bad.  Should probably delete this record
            fatalError()
        }
        
        let t = Tag(tagId: record.recordID, name: name, count: count)
        return t
    }
    
    class func toWordPair(from record : CKRecord) -> WordPair {
        guard let word = record.value(forKey: "word") as? String else { fatalError() }
        
        guard let definition = record.value(forKey: "definition") as? String else { fatalError() }
        
        guard let dateCreated = record.value(forKey: "dateCreated") as? Date else { fatalError() }
        
        let gender : Gender
        if let g = record.value(forKey: "gender") as? String {
            gender = Gender.fromString(g)
        } else {
            gender = .notset
        }
        
        let example = record.value(forKey: "example") as? String
        
        return WordPair(pairId: record.recordID, word: word, definition: definition, dateCreated: dateCreated, gender: gender, tags: [], example: example)
    }
}
