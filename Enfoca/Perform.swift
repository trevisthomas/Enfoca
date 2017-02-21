//
//  OperationsDemo.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class Perform {
    class func authentcate(db: CKDatabase, callback : @escaping (_ userTuple : (Int, CKRecordID)?,_ error : String?) -> ()){
        
        let user : InternalUser = InternalUser()
        let errorHandler = ErrorHandler(callback: callback)
        
        let completeOp = BlockOperation {
            //            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //            print ("Tags loaded: \(fetchOp.tags)")
            OperationQueue.main.addOperation{
                print(user.recordId)
                callback((user.enfocaId, user.recordId), nil)
            }
        }
        
        let queue = OperationQueue()
        
        let fetchUserId = FetchUserRecordId(user: user, db: db, errorDelegate: errorHandler)
        let cloudAuth = CloudAuthOperation(user: user, db: db, errorDelegate: errorHandler)
        let fetchUserRecord = FetchUserRecordOperation(user: user, db: db, errorDelegate: errorHandler)
        let fetchOrCreateEnfocaId = FetchOrCreateEnfocaId(user: user, db: db, errorDelegate: errorHandler)
        let fetchIncrementAndSaveSeedIfNecessary = FetchIncrementAndSaveSeedIfNecessary(user: user, db: db, errorDelegate: errorHandler)
        
        fetchUserId.addDependency(cloudAuth)
        fetchUserRecord.addDependency(fetchUserId)
        fetchIncrementAndSaveSeedIfNecessary.addDependency(fetchUserRecord)
        fetchOrCreateEnfocaId.addDependency(fetchIncrementAndSaveSeedIfNecessary)
        completeOp.addDependency(fetchOrCreateEnfocaId)
        
        queue.addOperations([fetchUserId, cloudAuth, fetchUserRecord, fetchOrCreateEnfocaId, fetchIncrementAndSaveSeedIfNecessary, completeOp], waitUntilFinished: false)
        
    }
        
}

class ErrorHandler<T> : ErrorDelegate {
    let callback: ( T?, _ error : String?) -> ()
    init (callback : @escaping ( T?, _ error : String?) -> ()) {
        self.callback = callback
    }
    
    func onError(message: String) {
        OperationQueue.main.addOperation {
            self.callback(nil, message)
        }
    }
}

