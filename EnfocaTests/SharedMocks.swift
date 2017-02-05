//
//  SharedMocks.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation
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
    
}

class MockDefaults : ApplicationDefaults {
    var reverseWordPair: Bool = false
    var saveCount = 0
    var selectedTags: [Tag] = []
    var tags: [Tag] = []
    
    
    func save() {
        saveCount += 1
    }
}

class MockWordPairTableView : UITableView {
    var identifier : String!
    var visibleMockCells : [UITableViewCell] = []
    
    var dataReloaded : Bool = false
    
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
//    override func animate(){
//        animateCallCount += 1
//    }
    
//    override func setContentPositions(animate : Bool) {
//        if (animate) {
//            animateCallCount += 1
//        }
//        setContentPositionCalledCount += 1
//    }
    
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

