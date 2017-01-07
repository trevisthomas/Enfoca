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
        sut.appDefaultsDelegate = mockAppDefaults
    }
    
    func viewDidLoad(){
        let _ = sut.view
    }
    
    func testInit_CellShouldBeLoaded(){
        overrideWithMocks()
        
        let row = 1
        
        var wordPairs = makeWordPairs()
        wordPairs[row].active = true
        
        let tag1 = Tag(ownerId: -1, tagId: "notimportant", name: "Noun")
        let tag2 = Tag(ownerId: -1, tagId: "notimportant", name: "Home")
        
        wordPairs[row].tags.append(tag1)
        wordPairs[row].tags.append(tag2)
        let wp = wordPairs[row]
        mockWebService.wordPairs = wordPairs
        
        mockAppDefaults.reverse = true
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.tableView)
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! WordPairCell

        XCTAssertTrue(sut.appDefaultsDelegate.reverseWordPair()) //Confirming initial state
        
        XCTAssertNotNil(cell)
        
        XCTAssertNotNil(cell.wordLabel)
        XCTAssertNotNil(cell.definitionLabel)
        
        XCTAssertEqual(wp.word, cell.wordLabel.text)
        XCTAssertEqual(wp.definition, cell.definitionLabel.text)
        XCTAssertTrue(cell.activeSwitch.isOn)
        XCTAssertTrue(cell.reverseWordPair)
        XCTAssertFalse(cell.tagLabel.isHidden)
        XCTAssertEqual(cell.tagLabel.text, "Tags: Noun, Home")
    }
    
    func testInit_WithActiveFalseAndNoTags(){
        overrideWithMocks()
        
        let row = 3
        
        var wordPairs = makeWordPairs()
        wordPairs[row].active = false
        
        let wp = wordPairs[row]
        mockWebService.wordPairs = wordPairs
        
        viewDidLoad()
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! WordPairCell

        XCTAssertFalse(cell.reverseWordPair)
        XCTAssertEqual(cell.activeSwitch.isOn, wp.active) //false
        XCTAssertNil(cell.tagLabel.text)
        XCTAssertTrue(cell.tagLabel.isHidden)
        
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
    
    func testActiveSwitch_SwitchingShouldActivate(){
        
        
        overrideWithMocks()
        getAppDelegate().webService = mockWebService
        
        
        let row = 1
        
        var wordPairs = makeWordPairs()

        mockWebService.wordPairs = wordPairs
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.tableView)
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! WordPairCell
        
        XCTAssertNotNil(cell)
        XCTAssertFalse(cell.wordPair.active)
        XCTAssertFalse(cell.activeSwitch.isOn)
        XCTAssertFalse(mockWebService.activateCalled) //Assert initial state
        
        //This seems to be the way to unit test a UISwitch
        cell.activeSwitch.isOn = true
        cell.activeSwitch.sendActions(for: .valueChanged)
        
        XCTAssertTrue(cell.wordPair.active)
        XCTAssertTrue(cell.activeSwitch.isOn)
        
        XCTAssertTrue(mockWebService.activateCalled)
        XCTAssertEqual(mockWebService.activeCalledWithWordPair, wordPairs[row])
        
    }
    
    func testActiveSwitch_SwitchingShouldDeactivate(){
        
        
        overrideWithMocks()
        getAppDelegate().webService = mockWebService
        
        
        let row = 3
        
        var wordPairs = makeWordPairs()
        wordPairs[row].active = true
        mockWebService.wordPairs = wordPairs
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.tableView)
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: row, section: 0)) as! WordPairCell
        
        XCTAssertNotNil(cell)
        
        XCTAssertTrue(cell.wordPair.active)
        XCTAssertTrue(cell.activeSwitch.isOn)
        XCTAssertFalse(mockWebService.deactivateCalled) //Assert initial state
        
        
        //This seems to be the way to unit test a UISwitch
        cell.activeSwitch.isOn = false
        cell.activeSwitch.sendActions(for: .valueChanged)
        
        XCTAssertFalse(cell.wordPair.active)
        XCTAssertFalse(cell.activeSwitch.isOn)
        
        XCTAssertTrue(mockWebService.deactivateCalled)
        XCTAssertEqual(mockWebService.deactiveCalledWithWordPair, wordPairs[row])
    }
}

