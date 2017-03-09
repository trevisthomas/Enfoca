//
//  Import.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import UIKit

class Import {
    
    var tagDict : [String: OldTag] = [:]
    var wordPairDict : [String: OldWordPair] = [:]
    var tagAssociations : [OldTagAssociation] = []
    let dateformatter = DateFormatter()
    
    init(){
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    
    func loadTags(){
        if let path = Bundle.main.path(forResource: "tag", ofType: "json") {
            if let jsonData =  try? NSData(contentsOfFile: path, options: [.mappedIfSafe]) as Data{
                if let jsonResult: NSArray = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                    
                    for raw in jsonResult{
                        let tag = raw as! NSDictionary
                        
                        guard let id = tag["tagId"] as? String else {fatalError()}
                        guard let name = tag["tagName"] as? String else {fatalError()}
                        let oldTag = OldTag(tagId: id, tagName: name)
                        
                        tagDict[oldTag.tagId] = oldTag
                        
                    }
                }
            }
        }
        print("Loaded \(tagDict.count) tags.")
    }
    
    func loadWordPairs(){
        guard let path = Bundle.main.path(forResource: "study_item", ofType: "json") else { fatalError() }
        guard let jsonData =  try? NSData(contentsOfFile: path, options: [.mappedIfSafe]) as Data  else { fatalError() }
        guard let jsonResult: NSArray = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray else { fatalError() }
        
        for raw in jsonResult{
            let pair = raw as! NSDictionary
            
            guard let id = pair["studyItemId"] as? String else {fatalError()}
            guard let dateString = pair["createDate"] as? String else {fatalError()}
            guard let date  = dateformatter.date(from: dateString) else {fatalError()}
            guard let word = pair["word"] as? String else {fatalError()}
            guard let definition = pair["definition"] as? String else {fatalError()}
            let example = pair["example"] as? String
            
            let oldWordPair = OldWordPair(studyItemId: id, creationDate: date, word: word, definition: definition, example: example)
            
            wordPairDict[oldWordPair.studyItemId] = oldWordPair
//            print("\(oldWordPair.word) : \(oldWordPair.definition)")
        }
        print("Loaded \(wordPairDict.count) word pairs.")
    }
    
    func loadTagAssociations(){
        guard let path = Bundle.main.path(forResource: "tag_associations", ofType: "json") else { fatalError() }
        guard let jsonData =  try? NSData(contentsOfFile: path, options: [.mappedIfSafe]) as Data  else { fatalError() }
        guard let jsonResult: NSArray = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray else { fatalError() }
        
        for raw in jsonResult{
            let ass = raw as! NSDictionary

            guard let studyItemId = ass["studyItemId"] as? String else {fatalError()}
            guard let tagId = ass["tagId"] as? String else {fatalError()}
            
            let tagAss = OldTagAssociation(tagId: tagId, studyItemId: studyItemId)
            
            tagAssociations.append(tagAss)
            
        }
        print("Loaded \(tagAssociations.count) tag associations.")
        
    }
    

    
}
