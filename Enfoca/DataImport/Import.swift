//
//  Import.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Import {
    
    var tagDict : [String: OldTag] = [:]
    var wordPairDict : [String: OldWordPair] = [:]
    var tagAssociations : [OldTagAssociation] = []
    let dateformatter = DateFormatter()
    let enfocaId = NSNumber(value: 3)
    
    init(){
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    func process(){
        loadWordPairs()
        loadTags()
        loadTagAssociations()
        print("Saving to cloud kit")
        saveDataToCloudKit()
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
//        guard let path = Bundle.main.path(forResource: "test", ofType: "json") else { fatalError() }
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
//        guard let path = Bundle.main.path(forResource: "test_ass", ofType: "json") else { fatalError() }
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
    
    func saveDataToCloudKit() {
        let db = CKContainer.default().publicCloudDatabase
        let errorHandler = ImportErrorHandler()
        
        let queue = OperationQueue()
        for oldTag in tagDict.values{
            let tagOp = OperationCreateTag(tagName: oldTag.tagName, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
            queue.addOperations([tagOp], waitUntilFinished: true)
//            oldTag.ckTagId = tagOp.tag?.tagId as! CKRecordID
            oldTag.newTag = tagOp.tag
            print("Created Tag: \(tagOp.tag?.name)")
        }
        
        
        for oldWordPair in wordPairDict.values{
            let wordPairOp = OperationCreateWordPair(wordPairSource: toRealWordPair(oldWordPair: oldWordPair), enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
            queue.addOperations([wordPairOp], waitUntilFinished: true)
//            oldWordPair.ckPairid = wordPairOp.wordPair?.pairId as? CKRecordID
            oldWordPair.newWordPair = wordPairOp.wordPair
            
            print("Created word pair: \(wordPairOp.wordPair?.word)")
        }
        
        for ass in tagAssociations {
            let tag = tagDict[ass.tagId]!.newTag!
            
            if let wp = wordPairDict[ass.studyItemId]?.newWordPair {
                //            let wp = wordPairDict[ass.studyItemId]!.newWordPair!
                
                let assOp = OperationCreateTagAssociation(tagId: tag.tagId, wordPairId: wp.pairId, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
                
                queue.addOperations([assOp], waitUntilFinished: true)
                
                print("created association \(wp.word) tagged \(tag.name)")

            } else {
                print("Failed to find: \(ass.studyItemId)")
            }
        }
    }
    
//    private func saveRecords(db: CKDatabase,records : [CKRecord]) -> CKDatabaseOperation{
//        let saveRecordsOperation = CKModifyRecordsOperation()
//        
//        saveRecordsOperation.database = db
//        
//        saveRecordsOperation.recordsToSave = records
//        saveRecordsOperation.savePolicy = .allKeys
////        saveRecordsOperation.perRecordCompletionBlock
//        saveRecordsOperation.perRecordCompletionBlock = { record, error in
//            // deal with conflicts
//            // set completionHandler of wrapper operation if it's the case
//            let wordPair = CloudKitConverters.toWordPair(from: record)
//            
//            let oldWordPair = self.wordPairDict.values.first(where: { (oldWordPair:OldWordPair) -> Bool in
//                return wordPair.word == oldWordPair.word && wordPair.definition == oldWordPair.definition
//            })
//            
//            oldWordPair?.ckPairid = wordPair.pairId as? CKRecordID
//            
//            print("Created word pair: \(wordPair.word)")
//            
//            
////            oldTag.ckTagId = tagOp.tag?.tagId as! CKRecordID
//        }
//        
//        saveRecordsOperation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
//            // deal with conflicts
//            // set completionHandler of wrapper operation if it's the case
//            
//            print("Created \(savedRecords?.count) word pairs.")
//        }
//        
//        
////        db.add(saveRecordsOperation)
//        return saveRecordsOperation
//    }
    
    private func toRealWordPair(oldWordPair : OldWordPair) -> WordPair{
        return WordPair(pairId: "", word: oldWordPair.word, definition: oldWordPair.definition, dateCreated: oldWordPair.creationDate, gender: .notset, tags: [], example: oldWordPair.example)
    }

}

class ImportErrorHandler : ErrorDelegate {
    func onError(message: String) {
        print(message)
        fatalError()
    }
}

