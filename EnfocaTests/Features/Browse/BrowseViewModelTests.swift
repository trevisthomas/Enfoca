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
        tags.append(Tag(tagId: "guid100", name: "Noun"))
        
        sut.performWordPairFetch(tagFilter: tags, pattern: "", wordPairOrder: .wordAsc) { (count) in
            //Dont care
        }
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), mockService.wordPairs.count)
    }
    
    func testTableView_ShouldCreatePopulatedCell(){
        let tableView = MockWordPairTableView()
        
        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
            //Dont care
        }
        
        sut.reverseWordPair = true

        let wp = mockService.wordPairs[1]
        
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        
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
        
        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
            callbackCalled = true
        }
        
        XCTAssertTrue(callbackCalled)
        
        
    }
    
    func testTableView_AnimateShouldBeCalledOnCell(){
        
        let tableView = MockWordPairTableView()
        
        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
            //Dont care
        }
        
        sut.reverseWordPair = true
        
        let wp = mockService.wordPairs[1]
        
        sut.animating = true
        
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        
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
        
        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
            //Dont care
        }
        sut.reverseWordPair = true
        
        let wp = mockService.wordPairs[1]
        
        sut.animating = false
        
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        
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
        
        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
            //Dont care
        }
        
        //You have to touch it first or else the data is not there.
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: rut, section: 0))
        
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: rut, section: 0))
        
        XCTAssertEqual(wp, mockBVMDelegate.editCalledWithWordPair)
    }
    
//    func testReloadPaths_AfterWordPairDataIsLoadedFromServiceDelegateShouldBeNotified(){
//        let rut = 1
//        let tableView = MockWordPairTableView()
//        let wp = mockService.wordPairs[rut]
//        
//        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
//            //Dont care
//        }
//        
//        XCTAssertEqual(mockBVMDelegate.pathsReloaded.count, 0)
//        
//        XCTAssertEqual(mockService.fetchWordPairCallCount, 1)
//        
//        //This will cause a fetch call to happen
//        var cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: rut, section: 0)) as! WordPairCell
//        
//        XCTAssertNil(cell.wordPair) //Cell should be nil because the call above would have returned immediately and then made a network request for the data
//        
//        //Since the network request in the tests is all on one thread it will have happened immediately.  So check, to make sure that it was called.
//        XCTAssertEqual(mockService.fetchWordPairCallCount, 2)
//        
//        //Confirm that the delegate was notified that the results are now in
//        XCTAssertEqual(mockBVMDelegate.pathsReloaded.count, mockService.wordPairs.count)
//        
//        
//        for i in 0..<mockService.wordPairs.count {
//            let path = IndexPath(row: i, section: 0)
//            XCTAssertTrue(mockBVMDelegate.pathsReloaded.contains(path))
//        }
//        
//        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: rut, section: 0)) as! WordPairCell
//        //Check that the cel is populated now
//        XCTAssertEqual(cell.wordPair.word, wp.word)
//        XCTAssertEqual(cell.wordPair.definition, wp.definition)
//        
//
//    }

    
//    func testEdit_SelectingRowThatIsLoadingDataShouldDoNothing(){
//        let rut = 1
//        let tableView = MockWordPairTableView()
//        
//        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
//            //Dont care
//        }
//        
//        sut.tableView(tableView, didSelectRowAt: IndexPath(row: rut, section: 0))
//        
//        XCTAssertNil(mockBVMDelegate.editCalledWithWordPair)
//    }
    
//    func testWebService_WordPairCountShouldHitServiceAndBuildDictionary(){
//        
//        var count = 0;
//        
//        let tagFilter : [Tag] = [makeTags()[0]]
//        let pattern : String = "Fa"
//        let wordPairOrder : WordPairOrder = .wordAsc
//        
//        
//        sut.performWordPairFetch(tagFilter: tagFilter, pattern: pattern, wordPairOrder: wordPairOrder) { (c : Int) in
//            count = c
//        }
//        
//        XCTAssertEqual(mockService.wordPairs.count, count)
//        XCTAssertEqual(sut.wordPairDictionary.count, count)
//        
//        XCTAssertEqual(tagFilter, sut.currentTagFilter!)
//        XCTAssertEqual(pattern, sut.currentPattern)
//        XCTAssertEqual(wordPairOrder, sut.currentWordPairOrder)
//        
//    }
    
//    func testWebService_FetchShouldBeCalledWhenPaging(){
//        
//        let tableView = MockWordPairTableView()
//        
//        
//        let tagFilter : [Tag] = [makeTags()[0]]
//        let pattern : String = "Fa"
//        let wordPairOrder : WordPairOrder = .wordAsc
//        
//        let pagingWebService = MockPagingWebService()
//        mockBVMDelegate.webService = pagingWebService
//        
//        let wordPairs = makeWordPairs()
//        
//        pagingWebService.wordPairCountValue = wordPairs.count * 2
//        
//        var returnedCount : Int = 0
//        sut.performWordPairFetch(tagFilter: tagFilter, pattern: pattern, wordPairOrder: wordPairOrder) { (c : Int) in
//            returnedCount = c
//        }
//        
//        XCTAssertEqual(returnedCount, pagingWebService.wordPairCountValue) //Verifying that things are wired.
//        
//        XCTAssertEqual(pagingWebService.fetchWordPairCallCount, 0)
//        XCTAssertFalse(sut.isFetchInProgress)
//        
//        guard let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? MockWordPairCell else {
//            XCTFail("Cell is not the expected type")
//            fatalError()
//        }
//        
//        XCTAssertEqual(pagingWebService.fetchWordPairCallCount, 1)
//        XCTAssertTrue(sut.isFetchInProgress)
//        XCTAssertTrue(cell.activityIndicator.isAnimating)
//        
//        //Verifying that the fetch service was called with the initial params
//        XCTAssertEqual(pagingWebService.fetchWordPairTagFilter!, tagFilter)
//        XCTAssertEqual(pagingWebService.fetchWordPairPattern, pattern)
//        XCTAssertEqual(pagingWebService.fetchWordPairOrder, wordPairOrder)
//        
//        guard let _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: wordPairs.count-1, section: 0)) as? MockWordPairCell else {
//            XCTFail("Cell is not the expected type")
//            fatalError()
//        }
//        
//        XCTAssertEqual(pagingWebService.fetchWordPairCallCount, 1) //Still at 1 because this was on the same page.
//        
//        pagingWebService.fetchCallback(wordPairs, nil) //return them.
//        XCTAssertFalse(sut.isFetchInProgress)
//        
//        guard let cellExists = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as? MockWordPairCell else {
//            XCTFail("Cell is not the expected type")
//            fatalError()
//        }
//        
//        XCTAssertFalse(cellExists.activityIndicator.isAnimating) // Not animating because the data is here now
//        XCTAssertEqual(pagingWebService.fetchWordPairCallCount, 1) //Still at 1 because the data is in the dictionary now
//        
//        
//        let wp = mockService.wordPairs[1]
//        XCTAssertEqual(cellExists.wordPair.definition, wp.definition)
//        XCTAssertEqual(cellExists.wordPair.word, wp.word)
//        
//        //Calling for a cell on the next page should fetch!
//        
//        var cellPage2 : MockWordPairCell
//        cellPage2 = sut.tableView(tableView, cellForRowAt: IndexPath(row: wordPairs.count+1, section: 0)) as! MockWordPairCell
//        
//        XCTAssertTrue(sut.isFetchInProgress)
//        XCTAssertTrue(cellPage2.activityIndicator.isAnimating) 
//        XCTAssertEqual(pagingWebService.fetchWordPairCallCount, 2) //New fetch because data was on a new page
//        
//        
//        //Return some data
//        pagingWebService.fetchCallback(wordPairs, nil) //return them.
//        XCTAssertFalse(sut.isFetchInProgress)
//        
//        //check to see if page two data exists now
//        cellPage2 = sut.tableView(tableView, cellForRowAt: IndexPath(row: wordPairs.count+1, section: 0)) as! MockWordPairCell
//        
//        let wp2 = mockService.wordPairs[1]
//        XCTAssertEqual(cellPage2.wordPair.definition, wp2.definition)
//        XCTAssertEqual(cellPage2.wordPair.word, wp2.word)
//    }
    
//    func testPairEditDelegate_AddWordPairShouldAdd(){
//        let wp = WordPair(pairId: "p-id", word: "new", definition: "nuevo", dateCreated: Date())
//        
//        
//        
//        XCTAssertFalse(mockBVMDelegate.reloadTableCalled)
//        
//        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
//            //Dont care
//        }
//        
//        XCTAssertEqual(sut.wordPairDictionary.count, mockService.wordPairs.count)
//        let count = sut.wordPairDictionary.count
//        
//        
//        
//        sut.added(wordPair: wp)
//        
////        for (key, value) in sut.wordPairDictionary {
////            
////        }
//        
//        let ip = IndexPath(row: 0, section: 0)
//        
//        //New words are inserted at the top
//        XCTAssertEqual(sut.wordPairDictionary[ip]?.wordPair, wp)
//        XCTAssertEqual(sut.wordPairDictionary.count, count + 1)
//        XCTAssertTrue(mockBVMDelegate.reloadTableCalled)
//    }
    
//    func testPairEditDelegate_UpdateWordPairShouldUpdate(){
//        XCTAssertFalse(mockBVMDelegate.reloadTableCalled)
//        
//        sut.performWordPairFetch(tagFilter: [], pattern: "", wordPairOrder: .wordAsc) { (count) in
//            //Dont care
//        }
//        
//        let ip = IndexPath(row: 2, section: 0)
//        
//        sut.fetchDataForIndexPath(path: ip)
//        
//        let wp = sut.wordPairDictionary[ip]!.wordPair!
//        
//        
//        let updatedWp = WordPair(pairId: wp.pairId, word: "new", definition: "nuevo", dateCreated: wp.dateCreated)
//        
//        XCTAssertEqual(sut.wordPairDictionary.count, mockService.wordPairs.count)
//        let count = sut.wordPairDictionary.count
//        
//        
//        sut.updated(wordPair: updatedWp)
//        
//        XCTAssertEqual(mockBVMDelegate.pathsReloaded[0], ip)
//        
//        XCTAssertEqual(sut.wordPairDictionary.count, count) // no change on update
//        
//        XCTAssertEqual(sut.wordPairDictionary[ip]?.wordPair, updatedWp)
//        
//        XCTAssertEqual(sut.wordPairDictionary[ip]?.wordPair?.word, updatedWp.word)
//        XCTAssertEqual(sut.wordPairDictionary[ip]?.wordPair?.definition, updatedWp.definition)
//
//    }
}

extension BrowseViewModelTests{
    class MockBrowseViewModelDelegate : BrowseViewModelDelegate {
        var webService: WebService!
        
        var editCalledWithWordPair : WordPair!
        func edit(wordPair: WordPair) {
            editCalledWithWordPair = wordPair
        }
        
        var pathsReloaded : [IndexPath] = []
        
        func reloadRows(withIndexPaths paths: [IndexPath]) {
            pathsReloaded = paths
        }
        
        var reloadTableCalled = false
        func reloadTable() {
            reloadTableCalled = true
        }
        
        func onError(error : EnfocaError?){
            
        }
    }
    
    class MockPagingWebService : MockWebService {
        
        var wordPairCountValue : Int = 0
        var fetchCallback : (([WordPair], EnfocaError?) -> ())!
        
        override func wordPairCount(tagFilter: [Tag], pattern: String?, callback: @escaping (Int?, EnfocaError?) -> ()) {
            callback(wordPairCountValue, nil)
        }
        
        override func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern: String?, callback: @escaping ([WordPair], EnfocaError?) -> ()) {
            super.fetchWordPairCallCount += 1
            
            fetchWordPairOrder = wordPairOrder
            fetchWordPairTagFilter = tagFilter
            fetchWordPairPattern = pattern
            
            fetchCallback = callback
        }
    }
    
}

