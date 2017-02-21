//
//  Perform+Tags.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

extension Perform{
    class func fetchTags(enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ tags : [Tag]?, _ error : String?) -> ()){
        let errorHandler = ErrorHandler(callback: callback)
        let fetchTagsOperation = OperationFetchTags(enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(fetchTagsOperation.tags, nil)
            }
        }
        
        let queue = OperationQueue()
        
        completeOp.addDependency(fetchTagsOperation)
        
        queue.addOperations([fetchTagsOperation, completeOp], waitUntilFinished: false)
    }
    
    
    
    class func createTag(tagName: String, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ tag : Tag?, _ error : String?) -> ()){
        
        let errorHandler = ErrorHandler(callback: callback)
        let createTagOperation = OperationCreateTag(tagName: tagName, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(createTagOperation.tag, nil)
            }
        }
        
        let queue = OperationQueue()
        completeOp.addDependency(createTagOperation)
        queue.addOperations([createTagOperation, completeOp], waitUntilFinished: false)
    }
}

