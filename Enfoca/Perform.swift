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
    
    class func createDataStore(enfocaId: NSNumber, db: CKDatabase, progressObserver: ProgressObserver, callback : @escaping (DataStore?, EnfocaError?)->()){
        let errorHandler = ErrorHandler(callback: callback)
        
        let queue = OperationQueue()
        
        let fetchTagAssociations = OperationFetchTagAssociations(enfocaId: enfocaId, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchTags = OperationFetchTags(enfocaId: enfocaId, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchWordPairs = OperationFetchWordPairs(enfocaId: enfocaId, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            print("Initializing data store")
            let dataStore = DataStore()
            dataStore.initialize(tags: fetchTags.tags, wordPairs: fetchWordPairs.wordPairs, tagAssociations: fetchTagAssociations.tagAssociations, progressObserver: progressObserver)
            
            print("DataStore initialized with \(dataStore.wordPairDictionary.count) word pairs, \(dataStore.tagDictionary.count) tags and \(dataStore.tagAssociations.count) associations.")
            
            
            OperationQueue.main.addOperation{
                callback(dataStore, nil)
            }
        }
        
        completeOp.addDependency(fetchTagAssociations)
        completeOp.addDependency(fetchTags)
        completeOp.addDependency(fetchWordPairs)
        
        queue.addOperations([fetchWordPairs, fetchTags, fetchTagAssociations, completeOp], waitUntilFinished: false)
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

