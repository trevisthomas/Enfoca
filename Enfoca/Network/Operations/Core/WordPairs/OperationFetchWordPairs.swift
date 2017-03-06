//
//  OperationFetchWordPairs.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/5/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationFetchWordPairs : BaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var wordPairs : [WordPair] = []
    
    init (enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        let sort : NSSortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@", enfocaId)
        
        let query: CKQuery = CKQuery(recordType: "WordPair", predicate: predicate)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            self.wordPairs.append(CloudKitConverters.toWordPair(from: record))
        }
        
        operation.queryCompletionBlock = {(cursor, error) in
            if let error = error {
                self.handleError(error)
                self.done()
            }
            
            if let cursor = cursor {
                let cursorOp = CKQueryOperation(cursor: cursor)
                self.execute(operation: cursorOp)
                return
            }
            self.done()
        }
        
        db.add(operation)
    }
    
}
