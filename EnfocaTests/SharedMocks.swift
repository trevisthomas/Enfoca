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
    
    func fetchWordPairs(wordStateFilter: WordStateFilter, tagFilter: [Tag], wordPairOrder : WordPairOrder, callback: @escaping ([WordPair]) -> ()) {
        fetchWordPairTagFilter = tagFilter
        fetchWordPairWordStateFilter = wordStateFilter
        callback(wordPairs)
        fetchWordPairCallCount += 1
        fetchWordPairOrder = wordPairOrder
    }
    
    var fetchCallCount : Int = 0
    var tags : [Tag] = []
    var fetchUserId : Int?
    
    func fetchUserTags(enfocaId : Int, callback : @escaping([Tag])->()){
        fetchCallCount += 1
        fetchUserId = enfocaId
        
        callback(tags)
    }
    
    
}

class MockDefaults : ApplicationDefaults {
    var wordStateFilter: WordStateFilter
    var reverse: Bool = false
    init(defaultWordStateFilter: WordStateFilter = .active){
        self.wordStateFilter = defaultWordStateFilter
    }
    
    func initialWordStateFilter() -> WordStateFilter {
        return wordStateFilter
    }
    
    func reverseWordPair() -> Bool {
        return reverse
    }
}

class MockWordPairTableView : UITableView {
    var identifier : String!
    var visibleMockCells : [UITableViewCell] = []
    
    //WARNING! This is not the way these work.  dequing does not make a cell visible
    override func dequeueReusableCell(withIdentifier identifier: String) -> UITableViewCell? {
        self.identifier = identifier
        let c = WordPairCell()
        visibleMockCells.append(c)
        return c
        
    }
    
    override var visibleCells: [UITableViewCell]{
        return visibleMockCells
    }
}

class MockWordStateFilterDelegate : WordStateFilterDelegate {
    var currentWordStateFilter: WordStateFilter = .all
    var updatedCalled : Bool = false
    func updated() {
        updatedCalled = true
    }
}
