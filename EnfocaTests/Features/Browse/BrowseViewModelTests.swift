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
    var mockService: MockWebService!
    var mockBVMDelegate : MockBrowseViewModelDelegate!
    
    override func setUp() {
        super.setUp()
        sut = BrowseViewModel()
        
        mockService = MockWebService()
        mockService.wordPairs = makeWordPairs()
        
        mockBVMDelegate = MockBrowseViewModelDelegate()
        
        mockBVMDelegate.webService = mockService
        sut.delegate = mockBVMDelegate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testWebService_FetchShouldFetchDataFromService(){
        let tableView = UITableView()
        
        var tags : [Tag] = []
        tags.append(Tag(ownerId: -1, tagId: "guid100", name: "Noun"))
        
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: tags, wordPairOrder: .wordAsc)
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), mockService.wordPairs.count)
    }
    
    func testTableView_ShouldCreatePopulatedCell(){
        let tableView = MockWordPairTableView()
        
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: [], wordPairOrder: .wordAsc)
        
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
    
    func testWebService_CallbackShouldNotifyCallerUponComplete(){
        var callbackCalled = false
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: [], wordPairOrder: .wordAsc, callback: {
            callbackCalled = true
        })
        
        XCTAssertTrue(callbackCalled)
        
        
    }
    
    func testTableView_AnimateShouldBeCalledOnCell(){
        
        let tableView = MockWordPairTableView()
        
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: [], wordPairOrder: .wordAsc)
        
        sut.reverseWordPair = true
        
        let wp = mockService.wordPairs[1]
        
        sut.animating = true
        
        guard let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? MockWordPairCell else {
            XCTFail("Cell is not the expected type")
            fatalError()
        }
        
        XCTAssertEqual(cell.setContentPositionCalledCount, 1)
        XCTAssertEqual(cell.animateCallCount, 1) //Confirm that dequing calls animate.
        XCTAssertEqual(cell.wordPair.definition, wp.definition)
        XCTAssertEqual(cell.wordPair.word, wp.word)
        XCTAssertTrue(cell.reverseWordPair)
    }
    
    func testTableView_AnimateShouldNotBeCalled(){
        
        let tableView = MockWordPairTableView()
        
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: [], wordPairOrder: .wordAsc)
        
        sut.reverseWordPair = true
        
        let wp = mockService.wordPairs[1]
        
        sut.animating = false
        
        guard let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? MockWordPairCell else {
            XCTFail("Cell is not the expected type")
            fatalError()
        }
        
        XCTAssertEqual(cell.setContentPositionCalledCount, 1)
        XCTAssertEqual(cell.animateCallCount, 0) //Confirm that dequing calls animate.
        XCTAssertEqual(cell.wordPair.definition, wp.definition)
        XCTAssertEqual(cell.wordPair.word, wp.word)
        XCTAssertTrue(cell.reverseWordPair)
    }
    
    //TODO, Row tap on ViewModel should tell VC to edit
    func testEdit_SelectingRowShouldNotifyViewController(){
        let rut = 1
        let tableView = MockWordPairTableView()
        
        let wp = mockService.wordPairs[rut]
        
        sut.fetchWordPairs(wordStateFilter: .all, tagFilter: [], wordPairOrder: .wordAsc) //This forces the VM to load data.
        
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: rut, section: 0))
        
        XCTAssertEqual(wp, mockBVMDelegate.editCalledWithWordPair)
    }
}

extension BrowseViewModelTests{
    class MockBrowseViewModelDelegate : BrowseViewModelDelegate {
        var webService: WebService!
        
        var editCalledWithWordPair : WordPair!
        func edit(wordPair: WordPair) {
            editCalledWithWordPair = wordPair
        }
    }
}

