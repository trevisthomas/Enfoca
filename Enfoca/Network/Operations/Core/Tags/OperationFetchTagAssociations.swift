//
//  OperationFetchTagAssociations.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/6/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationFetchTagAssociations : BaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var tagAssociations : [TagAssociation] = []
    
    init (enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@", enfocaId)
        
        let query: CKQuery = CKQuery(recordType: "TagAssociation", predicate: predicate)
        
        
        let operation = CKQueryOperation(query: query)
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            self.tagAssociations.append(CloudKitConverters.toTagAssociation(from: record))
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
