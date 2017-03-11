//
//  LocalCloudKitWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit
import CloudKit


class LocalCloudKitWebService : WebService {
    private(set) var enfocaId : NSNumber!
    private(set) var db : CKDatabase!
    private(set) var userRecordId : CKRecordID!
    private var dataStore: DataStore!
    
    var showNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
    
    func initialize(progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        
        db = CKContainer.default().publicCloudDatabase
        Perform.authentcate(db: db) { (userTuple : (Int, CKRecordID)?, error: String?) in
            guard let userTuple = userTuple else {
                callback(false, error)
                return
            }
            print("EnfocaId: \(userTuple.0)")
            self.enfocaId = NSNumber(value: userTuple.0)
            self.userRecordId = userTuple.1
            //            callback(true, nil)
            
            Perform.createDataStore(enfocaId: self.enfocaId, db: self.db, progressObserver: progressObserver) { (dataStore : DataStore?, error: EnfocaError?) in
                if let error = error {
                    callback(false, error)
                }
                guard let dataStore = dataStore else {
                    callback(false, "DataStore was nil.  This is a fatal error.")
                    return;
                }
                self.dataStore = dataStore
                callback(true, nil)
            }
        }
    }
    
    func initialize(callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        //Deprecated?
        fatalError()
    }
    
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->()) {
        callback(dataStore.allTags(), nil)
    }
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair]?,EnfocaError?)->()){
        
        let sorted = dataStore.search(wordPairMatching: pattern ?? "", order: wordPairOrder, withTags: tagFilter)
        callback(sorted, nil)
        
    }
    
    func fetchNextWordPairs(callback : @escaping([WordPair]?,EnfocaError?)->()){
        //Deprecated.
    }
    
    func wordPairCount(tagFilter: [Tag], pattern : String?, callback : @escaping(Int?, EnfocaError?)->()) {
        //Deprecated
        callback(dataStore.wordPairDictionary.count, nil)
        //Git rid of this method after fixing model.
    }
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->()){
        
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()){
        
    }
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->()){
        
    }
}
