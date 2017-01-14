//
//  SharedMocks.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

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
    var fetchWordPairWordStateFilter : WordStateFilter?
    var fetchWordPairCallCount : Int = 0
    var wordPairs : [WordPair] = []
    var fetchWordPairOrder : WordPairOrder?
    var fetchWordPairPattern : String?
    
    var activateCalled : Bool = false
    var activeCalledWithWordPair : WordPair!
    
    var deactivateCalled : Bool = false
    var deactiveCalledWithWordPair : WordPair!
    
    
    func fetchWordPairs(wordStateFilter: WordStateFilter, tagFilter: [Tag], wordPairOrder : WordPairOrder, pattern : String? = nil, callback: @escaping ([WordPair]) -> ()) {
        fetchWordPairTagFilter = tagFilter
        fetchWordPairWordStateFilter = wordStateFilter
        fetchWordPairCallCount += 1
        fetchWordPairOrder = wordPairOrder
        fetchWordPairPattern = pattern
        
        callback(wordPairs)
    }
    
    var fetchCallCount : Int = 0
    var tags : [Tag] = []
    
    func fetchUserTags(callback : @escaping([Tag])->()){
        fetchCallCount += 1
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
    
}

class MockDefaults : ApplicationDefaults {
    var wordStateFilter: WordStateFilter
    var reverseWordPair: Bool = false
    var tagFilters:[(Tag, Bool)] = []
    var saveCount = 0
    
    init(defaultWordStateFilter: WordStateFilter = .active){
        self.wordStateFilter = defaultWordStateFilter
    }
    
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

class MockWordStateFilterDelegate : WordStateFilterDelegate {
    var currentWordStateFilter: WordStateFilter = .all
    var updatedCalled : Bool = false
    func updated(_ callback: (() -> ())? = nil) {
        updatedCalled = true
    }
}
