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
            
            if let ds = self.loadDataStore() {
                self.dataStore = ds
                callback(true, nil)
                return
            }
            
            Perform.createDataStore(enfocaId: self.enfocaId, db: self.db, progressObserver: progressObserver) { (dataStore : DataStore?, error: EnfocaError?) in
                if let error = error {
                    callback(false, error)
                }
                guard let dataStore = dataStore else {
                    callback(false, "DataStore was nil.  This is a fatal error.")
                    return;
                }
                self.dataStore = dataStore
                
                self.saveDataStore(dataStore)
                
                callback(true, nil)
            }
        }
    }
    
    let dataStoreKey : String = "DataStoreKey"
    
    
    private func saveDataStore(_ dataStore: DataStore){
        let defaults = UserDefaults.standard
        
        defaults.setValue(dataStore.toJson(), forKey: dataStoreKey)
    }
    
    private func loadDataStore() -> DataStore? {
        let defaults = UserDefaults.standard
        guard let json = defaults.value(forKey: dataStoreKey) as? String else { return nil }
        
        let ds = DataStore(json: json)
        
        return ds
        
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
        
        let newWordPair = WordPair(pairId: "", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        
        Perform.createWordPair(wordPair: newWordPair, enfocaId: enfocaId, db: db) { (wordPair:WordPair?, error:String?) in
            
            if let error = error {
                callback(nil, error)
            }
            
            guard let wordPair = wordPair else { return }
            
            self.dataStore.add(wordPair: newWordPair)
            callback(wordPair, error)
        }
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()){
        
        let tuple = dataStore.applyUpdate(oldWordPair: oldWordPair, word: word, definition: definition, gender: gender, example: example, tags: tags)
        
        //TODO: Update cloud
        
        callback(tuple.0, nil)
        
    }
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->()){
        
        Perform.createTag(tagName: tagValue, enfocaId: enfocaId, db: db) { (tag:Tag?, error: String?) in
            
            if let error = error {
                callback(nil, error)
            }
            
            guard let tag = tag else { return }
            
            self.dataStore.add(tag: tag)
            callback(tag, nil)
        }
        
        
    }
    
    func updateTag(oldTag : Tag, newTagName: String, callback: @escaping(Tag?, EnfocaError?)->()) {
        
        //TODO: Update in cloud
        
        let newTag = dataStore.applyUpdate(oldTag: oldTag, name: newTagName)
        
        callback(newTag, nil)
    }
}
