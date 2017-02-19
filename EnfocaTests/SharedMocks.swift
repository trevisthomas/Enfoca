//
//  SharedMocks.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit
import CloudKit
@testable import Enfoca

class MockAuthenticationDelegate: AuthenticationDelegate {
    var performLoginCount = 0
    var performSilentLoginCount = 0
    var performLogoffCount = 0
    var user : User?
    
    init(user : User? = nil) {
        self.user = user
    }
    
    func performLogin() {
        performLoginCount += 1
    }
    func performSilentLogin() {
        performSilentLoginCount += 1
    }
    func performLogoff(){
        performLogoffCount += 1
    }
    
    func currentUser() -> User?{
        return user
    }
}

class MockWebService : WebService {
    var fetchWordPairTagFilter : [Tag]?
    var fetchWordPairCallCount : Int = 0
    var wordPairs : [WordPair] = []
    var fetchWordPairOrder : WordPairOrder?
    var fetchWordPairPattern : String?
    
    var activateCalled : Bool = false
    var activeCalledWithWordPair : WordPair!
    
    var deactivateCalled : Bool = false
    var deactiveCalledWithWordPair : WordPair!
    
    var createCalledCount: Int = 0
    var updateCalledCount: Int = 0
    
    var createdWordPair: WordPair?
    var updatedWordPair: WordPair?
    
    var showNetworkActivityIndicatorCalledCount = 0
    var showNetworkActivityIndicator: Bool = false {
        didSet{
            showNetworkActivityIndicatorCalledCount += 1
        }
    }
    
    //Set this to non null values to get errors back in your test
    var errorOnCreateWordPair : String?
    var errorOnUpdateWordPair : String?
    
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder : WordPairOrder, pattern : String? = nil, callback: @escaping ([WordPair]) -> ()) {
        fetchWordPairTagFilter = tagFilter
        fetchWordPairCallCount += 1
        fetchWordPairOrder = wordPairOrder
        fetchWordPairPattern = pattern
        
        callback(wordPairs)
    }
    
    func wordPairCount(tagFilter: [Tag], pattern: String?, callback: @escaping (Int) -> ()) {
        fetchWordPairTagFilter = tagFilter
        fetchWordPairCallCount += 1
//        fetchWordPairOrder = wordPairOrder
        fetchWordPairPattern = pattern
        
        callback(wordPairs.count)
    }
    
    var fetchUserTagsCallCount : Int = 0
    var tags : [Tag] = []
    
    convenience init(tags : [Tag]) {
        self.init()
        self.tags = tags
    }
    
    init() {
        self.tags = makeTags()
    }
    
    func fetchUserTags(callback : @escaping([Tag])->()){
        fetchUserTagsCallCount += 1
        callback(tags)
    }
    
    func activateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
        activateCalled = true
        activeCalledWithWordPair = wordPair
        callback!(true)
    }
    
    func deactivateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
        deactivateCalled = true
        deactiveCalledWithWordPair = wordPair
        callback!(true)
    }
    

    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String? = nil, callback : @escaping(WordPair?, EnfocaError?)->()) {
        
        createCalledCount += 1
        
        if let error = errorOnCreateWordPair {
            callback(nil, error)
            return
        }
        
        createdWordPair = WordPair(creatorId: -1, pairId: "none", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(createdWordPair, nil)
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String? = nil, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()) {
        
        updateCalledCount += 1
        
        if let error = errorOnUpdateWordPair {
            callback(nil, error)
            return
        }
        
        updatedWordPair = WordPair(creatorId: oldWordPair.creatorId, pairId: oldWordPair.pairId, word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(updatedWordPair, nil)
    }
    
    var errorOnCreateTag : String? = nil
    var createTagCallCount = 0
    var createTagValue : String? = nil
    var createTagBlockedCallback : ((Tag?, EnfocaError?)->())?
    var createTagBlockCallback : Bool = false
    
    func createTag(tagValue: String, callback: @escaping (Tag?, EnfocaError?) -> ()) {
        
        createTagCallCount += 1
        createTagValue = tagValue
        
        if let error = errorOnCreateTag {
            callback(nil, error)
            return
        } else {
            let t = Tag(ownerId: -1, tagId: "eyedee", name: tagValue)
            if (createTagBlockCallback) {
                createTagBlockedCallback = callback
            } else {
                callback(t, nil)
            }
        }
    }
    
}

class MockDefaults : ApplicationDefaults {
    var reverseWordPair: Bool = false
    var saveCount = 0
    var selectedTags: [Tag] = []
    var tags: [Tag] = []
    
    var fetchWordPairPageSize: Int {
        return 10
    }
    
    func save() {
        saveCount += 1
    }
}

class MockWordPairTableView : UITableView {
    var identifier : String!
    var visibleMockCells : [UITableViewCell] = []
    
    var dataReloaded : Bool = false
    
    var strongStuff : [UIActivityIndicatorView] = []
    
    //WARNING! This is not the way these work.  dequing does not make a cell visible
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        self.identifier = identifier
        let c = MockWordPairCell()
        visibleMockCells.append(c)
        
        return c
        
    }
    
    override var visibleCells: [UITableViewCell]{
        return visibleMockCells
    }
    
    override func reloadData() {
        super.reloadData()
        dataReloaded = true
    }
}

class MockWordPairCell : WordPairCell {
    var animateCallCount = 0
    var setContentPositionCalledCount = 0
    
    var _activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 10, width: 100, height: 100))
    
    override var activityIndicator: UIActivityIndicatorView! {
        get {
            return _activityIndicator
        } set {
            //dont care
        }
    }
    
    override func updateContentPositions(animate : Bool = false) {
        if (animate) {
            animateCallCount += 1
        }
        setContentPositionCalledCount += 1
    }
    
}

class MockTableView : UITableView {
    
    var dataReloaded : Bool = false
    override func reloadData() {
        super.reloadData()
        dataReloaded = true
    }
    
    var selectedIndexPath : IndexPath?
    override func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
        selectedIndexPath = indexPath
    }
    
    var identifier : String?
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        self.identifier = identifier
        
        if(identifier == "TagFilterCell"){
            let cell = TagCell(style: .default, reuseIdentifier: identifier)
            cell.tagSubtitleLabel = UILabel(frame: CGRect.zero)
            cell.tagTitleLabel = UILabel(frame: CGRect.zero)
            cell.tagSelectedView = UIView(frame: CGRect.zero)
            return cell
        } else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: identifier)
        }

    }
    
    var reloadedRowsAtIndexPaths : [IndexPath] = []
    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        reloadedRowsAtIndexPaths = indexPaths
    }
    
    
}

class MockTagFilterDelegate : TagFilterDelegate {
    var updateCalled : Bool = false
    var tags: [Tag]
    var selectedTags: [Tag]
    
    init(){
        tags = makeTags()
        selectedTags = []
    }
    
    func tagFilterUpdated(_ callback : (() -> ())? = nil){
        updateCalled = true
    }
}

class MockTagFilterViewModelDelegate : TagFilterViewModelDelegate{
    var selectedTagsChangedCalled : Bool = false
    var reloadTableCalled : Bool = false
    func selectedTagsChanged(){
        selectedTagsChangedCalled = true
    }
    func reloadTable() {
        reloadTableCalled = true
    }
    
    var alertTitle : String?
    var alertMessage : String?
    func alert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
    }
}
