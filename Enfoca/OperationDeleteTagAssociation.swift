//
//  OperationDeleteTagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/19/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationDeleteTagAssociation: BaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private var tagAssociation: TagAssociation
    private(set) var associationId: String?
    
    
    init (tagAssociation: TagAssociation, enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        self.tagAssociation = tagAssociation
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: tagAssociation.associationId)
        
        db.delete(withRecordID: recordId) { (recordId:CKRecordID?, error:Error?) in
            if let error = error {
                self.handleError(error)
            }
            if let recordId = recordId {
                self.associationId = recordId.recordName
            }
            self.done()
        }
    }
}
