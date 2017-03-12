//
//  Perform+WordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

extension Perform{
    class func createWordPair(wordPair : WordPair, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ wordPair : WordPair?, _ error : String?) -> ()){
        
        let errorHandler = ErrorHandler(callback: callback)
        let createWordPairOperation = OperationCreateWordPair(wordPairSource: wordPair, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            
            guard let wp = createWordPairOperation.wordPair else { fatalError() }
            
            //Create any tag associations for this new word.
            for tag in wordPair.tags {
                createTagAssociation(wordPair: wp, tag: tag, enfocaId: enfocaId, db: db, callback: { (tagAss:TagAssociation?, error:String?) in
                    guard let _ = tagAss else { fatalError() }
                    wp.addTag(tag)
                })
            }
            
            OperationQueue.main.addOperation{
                callback(wp, nil)
            }
        }
        
        let queue = OperationQueue()
        completeOp.addDependency(createWordPairOperation)
        queue.addOperations([createWordPairOperation, completeOp], waitUntilFinished: false)
    }
    
    class func createTagAssociation(wordPair: WordPair, tag: Tag, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ tagAssociation : TagAssociation?, _ error : String?) -> ()){
        
        let errorHandler = ErrorHandler(callback: callback)
        
        let createTagAssociation = OperationCreateTagAssociation(tag: tag, wordPair: wordPair, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(createTagAssociation.tagAssociation, nil)
            }
        }
        
        let queue = OperationQueue()
        completeOp.addDependency(createTagAssociation)
        queue.addOperations([createTagAssociation, completeOp], waitUntilFinished: false)
        
    }
    
    class func countWordPairs(withTags tags : [Tag], phrase : String?, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ count : Int?, _ error : String?) -> ()) {
        
        let errorHandler = ErrorHandler(callback: callback)
        let countWordPairsOperation = OperationCountWordPairs(tags: tags, phrase: phrase, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(countWordPairsOperation.count, nil)
            }
        }
        
        let queue = OperationQueue()
        completeOp.addDependency(countWordPairsOperation)
        queue.addOperations([countWordPairsOperation, completeOp], waitUntilFinished: false)
    }
    
    class func fetchNextWordPairs(cursor : CKQueryCursor, db: CKDatabase, callback : @escaping([WordPair]?,EnfocaError?)->(), cursorCallback : @escaping(CKQueryCursor)->()){
        
        let errorHandler = ErrorHandler(callback: callback)
        let fetchWordPairsOperation = OperationPagedWordPairs(cursor: cursor, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(fetchWordPairsOperation.wordPairs, nil)
                if let cursor = fetchWordPairsOperation.cursor {
                    cursorCallback(cursor)
                }
            }
        }
        
        let queue = OperationQueue()
        completeOp.addDependency(fetchWordPairsOperation)
        queue.addOperations([fetchWordPairsOperation, completeOp], waitUntilFinished: false)
    }
    
    class func fetchWordPairs(tags: [Tag], wordPairOrder: WordPairOrder, phrase : String?, enfocaId: NSNumber, db: CKDatabase, callback : @escaping([WordPair]?,EnfocaError?)->(), cursorCallback : @escaping(CKQueryCursor)->()){
        let errorHandler = ErrorHandler(callback: callback)
        let fetchWordPairsOperation = OperationPagedWordPairs(tags: tags, phrase: phrase, order: wordPairOrder, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(fetchWordPairsOperation.wordPairs, nil)
                if let cursor = fetchWordPairsOperation.cursor {
                    cursorCallback(cursor)
                }
            }
        }
        
        let queue = OperationQueue()
        completeOp.addDependency(fetchWordPairsOperation)
        queue.addOperations([fetchWordPairsOperation, completeOp], waitUntilFinished: false)
    }
}
