//
//  BrowseViewModelTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class BrowseViewModelTests: XCTestCase {
    var sut : BrowseViewModel!
    
    override func setUp() {
        super.setUp()
        sut = BrowseViewModel()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWebService_FetchShouldFetchDataFromService(){
        let mockService = MockWebService()
        mockService.wordPairs = makeWordPairs()
        sut.webService = mockService
        let tableView = UITableView()
        
        var tags : [Tag] = []
        tags.append(Tag(ownerId: -1, tagId: "guid100", name: "Noun"))
        
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: tags)
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), mockService.wordPairs.count)
    }
    
    func testTableView_ShouldCreatePopulatedCell(){
        let mockService = MockWebService()
        mockService.wordPairs = makeWordPairs()
        sut.webService = mockService
        let tableView = MockWordPairTableView()
        
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: [])
        
        sut.reverseWordPair = true

        let wp = mockService.wordPairs[1]
        
        guard let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? WordPairCell else {
            XCTFail("Cell is not the expected type")
            fatalError()
        }
        
        XCTAssertEqual(tableView.identifier, "WordPairCell")
        XCTAssertEqual(cell.wordPair.definition, wp.definition)
        XCTAssertEqual(cell.wordPair.word, wp.word)
        XCTAssertTrue(cell.reverseWordPair)
    }
    
//    func testTableView_TogglingReverseShouldNotifyVisibleCells(){
//        let mockService = MockWebService()
//        mockService.wordPairs = makeWordPairs()
//        sut.webService = mockService
//        let tableView = MockTableView()
//        
//        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: [])
//        
//        sut.reverseWordPair = false
//        
//        let wp = mockService.wordPairs[1]
//        
//        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! WordPairCell
//        
//        XCTAssertFalse(cell.reverseWordPair) //Asserting initial state
//        
//        sut.reverseWordPair = true
//        
//        XCTAssertFalse(cell.reverseWordPair) //Asserting initial state
//    }
    
    
}

extension BrowseViewModelTests {
    
    
   
}
