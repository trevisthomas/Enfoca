//
//  WordPairCellTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class WordPairCellTests: XCTestCase {
    
    var sut : BrowseViewController!
    var authDelegate : MockAuthenticationDelegate!
    let currentUser = User(enfocaId: 99, name: "Agent", email: "nintynine@agent.net")
    var mockWebService : MockWebService!
    var mockAppDefaults : MockDefaults!
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func overrideWithMocks(){
        authDelegate = MockAuthenticationDelegate(user: currentUser)
        sut.authenticateionDelegate = authDelegate
        mockWebService = MockWebService()
        sut.webService = mockWebService
        
        mockAppDefaults = MockDefaults()
        sut.appDefaults = mockAppDefaults
    }
    
    func viewDidLoad(){
        let _ = sut.view
    }
    
    func testInit_CellShouldBeLoaded(){
        overrideWithMocks()
        
        let row = 1
        
        var wordPairs = makeWordPairs()
        
        let tag1 = Tag(ownerId: -1, tagId: "notimportant", name: "Noun")
        let tag2 = Tag(ownerId: -1, tagId: "notimportant", name: "Home")
        
        let wp = WordPair(creatorId: -1, pairId: "guid", word: "To Run", definition: "Correr", dateCreated: Date(), tags: [tag1, tag2])
        
    
        wordPairs[row] = wp
        
        mockWebService.wordPairs = wordPairs
        
        mockAppDefaults.reverseWordPair = true
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.tableView)
        
        _ = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: row, section: 0))
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! WordPairCell

        XCTAssertTrue(sut.appDefaults.reverseWordPair) //Confirming initial state
        
        XCTAssertNotNil(cell)
        
        XCTAssertNotNil(cell.wordLabel)
        XCTAssertNotNil(cell.definitionLabel)
        
        XCTAssertEqual(wp.word, cell.wordLabel.text)
        XCTAssertEqual(wp.definition, cell.definitionLabel.text)
        XCTAssertTrue(cell.reverseWordPair)
        XCTAssertFalse(cell.tagLabel.isHidden)
        XCTAssertEqual(cell.tagLabel.text, "Tags: Noun, Home")
    }
    
    func testInit_ConstraintsShouldBeWired(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! WordPairCell
        
        XCTAssertNotNil(cell.definitionLabelConstraint)
        XCTAssertNotNil(cell.wordLabelConstraint)
        
        XCTAssertNotNil(cell.origWordConstant)
        XCTAssertNotNil(cell.definitionLabelConstraint)
    }

}

