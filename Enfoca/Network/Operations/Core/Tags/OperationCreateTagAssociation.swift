//
//  OperationTagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationCreateTagAssociation: BaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var tag : Tag
    private(set) var wordPair : WordPair
    private(set) var tagAssociation: TagAssociation?
    
    
    init (tag: Tag, wordPair: WordPair, enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        self.wordPair = wordPair
        self.tag = tag
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        let record : CKRecord = CKRecord(recordType: "TagAssociation")
        
        let tagRef = CKReference(recordID: tag.tagId as! CKRecordID, action: .none)
        let wpRef = CKReference(recordID: wordPair.pairId as! CKRecordID, action: .none)
        
        record.setValue(wpRef, forKey: "wordRef")
        record.setValue(tagRef, forKey: "tagRef")
        record.setValue(enfocaId, forKey: "enfocaId")
        
        db.save(record) { (newRecord: CKRecord?, error: Error?) in
            if let error = error {
                self.handleError(error)
            }
            
            guard let newRecord = newRecord else {
                self.done()
                return
            }
            
            self.tagAssociation = CloudKitConverters.toTagAssociation(from: newRecord)
            self.done()
        }
        
    }
}
