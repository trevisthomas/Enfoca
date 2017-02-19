//
//  OperationsDemo.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationsDemo {
    class func authentcate(callback : @escaping (_ enfocaId : Int?,_ error : String?) -> ()){
        
        let user : InternalUser = InternalUser()
        let errorHandler = ErrorHandler(callback: callback)
        
        let completeOp = BlockOperation {
            //            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //            print ("Tags loaded: \(fetchOp.tags)")
            OperationQueue.main.addOperation{
                print(user.recordId)
                callback(user.enfocaId, nil)
            }
        }
        
        let queue = OperationQueue()
        
        let fetchUserId = FetchUserRecordId(user: user, errorDelegate: errorHandler)
        let cloudAuth = CloudAuthOperation(user: user, errorDelegate: errorHandler)
        let fetchUserRecord = FetchUserRecordOperation(user: user, errorDelegate: errorHandler)
        let fetchOrCreateEnfocaId = FetchOrCreateEnfocaId(user: user, errorDelegate: errorHandler)
        let fetchIncrementAndSaveSeedIfNecessary = FetchIncrementAndSaveSeedIfNecessary(user: user, errorDelegate: errorHandler)
        
        fetchUserId.addDependency(cloudAuth)
        fetchUserRecord.addDependency(fetchUserId)
        fetchIncrementAndSaveSeedIfNecessary.addDependency(fetchUserRecord)
        fetchOrCreateEnfocaId.addDependency(fetchIncrementAndSaveSeedIfNecessary)
        completeOp.addDependency(fetchOrCreateEnfocaId)
        
        queue.addOperations([fetchUserId, cloudAuth, fetchUserRecord, fetchOrCreateEnfocaId, fetchIncrementAndSaveSeedIfNecessary, completeOp], waitUntilFinished: false)
        
    }
    
    fileprivate class ErrorHandler : ErrorDelegate {
        let callback : (_ enfocaId : Int?,_ error : String?) -> ()
        init (callback : @escaping (_ enfocaId : Int?,_ error : String?) -> ()) {
            self.callback = callback
        }
        
        func onError(message: String) {
            callback(nil, message)
        }
    }
    
    
}


