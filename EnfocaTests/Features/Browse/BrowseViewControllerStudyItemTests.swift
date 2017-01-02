//
//  BrowseViewControllerStudyItemTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class BrowseViewControllerStudyItemTests: XCTestCase {
    
    var sut : BrowseViewController!
    var authDelegate : MockAuthenticationDelegate!
    let currentUser = User(enfocaId: 99, name: "Agent", email: "nintynine@agent.net")
    var mockWebService : MockWebService!
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
    }
    
    func overrideWithMocks(){
        authDelegate = MockAuthenticationDelegate(user: currentUser)
        sut.authenticateionDelegate = authDelegate
        mockWebService = MockWebService()
        sut.webService = mockWebService
    }
    
    func viewDidLoad(){
        let _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_NonUIDelegatesShouldBeWiredFromStoryboardInit(){
        //Verifying that after storyboard init that my delegates are in place
        XCTAssertNotNil(sut.authenticateionDelegate)
        XCTAssertNotNil(sut.webService)
    }
    
    func testInit_ShouldHaveTableViewWithViewModelWiredIn(){
        overrideWithMocks()
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.tableView)
        
        let cell = sut.tableView.dequeueReusableCell(withIdentifier: "WordPairCell") as! WordPairCell
        XCTAssertNotNil(cell)
        
        guard let _ = sut.tableView.delegate as? BrowseViewModel else {
            XCTFail("View model not attached to table delegate")
            fatalError()
        }
        
        guard let vm = sut.tableView.dataSource as? BrowseViewModel else {
            XCTFail("View model not attached to table delegate")
            fatalError()
        }
        
        XCTAssertNotNil(vm.webService)
    }
    
//    func testDataSource_ShouldMakeHappyCells(){
//        overrideWithMocks()
//        
//        let mockDefaults = MockDefaults()
//        sut.appDefaultsDelegate = mockDefaults
//        mockWebService.wordPairs = makeWordPairs()
//        
//        viewDidLoad()
//        
//        let cell = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! WordPairCell
//        
//        XCTAssertNotNil(cell)
//
//    }
    
    func testInit_CellsShouldBeInflatedAndPoulated(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.tableView)
//        let cell = sut.tableView.dequeueReusableCell(withIdentifier: "WordPairCell", for: IndexPath(row: 2, section: 0)) as! WordPairCell
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! WordPairCell
        
        let wp = mockWebService.wordPairs[2]
        
        XCTAssertNotNil(cell.wordLabel)
        XCTAssertNotNil(cell.definitionLabel)
        
        XCTAssertEqual(cell.wordLabel?.text, wp.word)
        XCTAssertEqual(cell.definitionLabel?.text, wp.definition)
    }
    
    func testWebService_ShouldFetchWordsFromServiceWithCurrentFilterParams(){
        overrideWithMocks()
        
        let defaults = MockDefaults(defaultWordStateFilter: .inactive)
        sut.appDefaultsDelegate = defaults
        
        let service = sut.webService as! MockWebService //Just making sure
        
        viewDidLoad()
        
        //The webservice should be called!
        XCTAssertEqual(service.fetchWordPairTagFilter!, [])
        XCTAssertEqual(service.fetchWordPairWordStateFilter, sut.currentWordStateFilter)
    }
    
    func testWebService_WebserviceShouldBeCalledWhenFilterIsUpdated(){
        
        overrideWithMocks()
        
        let defaults = MockDefaults(defaultWordStateFilter: .inactive)
        sut.appDefaultsDelegate = defaults
        
        let service = sut.webService as! MockWebService //Just making sure
        
        viewDidLoad() //View did load. Caues the service to be called with the default filters.
        
        sut.tagTuples = makeTags().map({
            (value : Tag) -> (Tag, Bool) in
            return (value, false)
        })
        
        
        var tags : [Tag] = []
        //Filtering on these two tags
        sut.tagTuples[2].1 = true
        sut.tagTuples[0].1 = true
        
        tags.append(sut.tagTuples[0].0)
        tags.append(sut.tagTuples[2].0)
        
        sut.currentWordStateFilter = .inactive
        
        sut.updated() //Causes the service to be called again with the updated filter
        
        XCTAssertEqual(service.fetchWordPairTagFilter!, tags)
        XCTAssertEqual(service.fetchWordPairWordStateFilter, .inactive)
    }
    
    func testAppDefaults_ViewModelShouldReflectReverseWordPairSetting(){
        overrideWithMocks()
        
        let mockDefaults = MockDefaults()
        
        mockDefaults.reverse = true
        sut.appDefaultsDelegate = mockDefaults
        
        viewDidLoad()
        
        XCTAssertTrue(sut.viewModel.reverseWordPair)
        XCTAssertEqual(mockWebService.fetchWordPairOrder!, .definitionAsc)
    }
    
    func testAppDefaults_ViewModelShouldReflectNormalWordPairSetting(){
        overrideWithMocks()
        
        let mockDefaults = MockDefaults()
        
        mockDefaults.reverse = false
        sut.appDefaultsDelegate = mockDefaults
        
        viewDidLoad()
        
        XCTAssertFalse(sut.viewModel.reverseWordPair)
        
        XCTAssertEqual(mockWebService.fetchWordPairOrder!, .wordAsc)
    }
    
    func testAppDefaults_ViewModelShouldReflectReverseWordPairSettingWhenFalse(){
        overrideWithMocks()
        
        let mockDefaults = MockDefaults()
        mockDefaults.reverse = false
        sut.appDefaultsDelegate = mockDefaults
        viewDidLoad()
        
       XCTAssertFalse(sut.viewModel.reverseWordPair)
    }
    
    func testSegmented_ShouldBeSetToDefault(){
        overrideWithMocks()
        mockWebService.wordPairs = makeWordPairs()
        let delegate = MockDefaults()
        delegate.reverse = true
        
        sut.appDefaultsDelegate = delegate
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.reverseWordPairSegmentedControl)
        XCTAssertEqual(sut.reverseWordPairSegmentedControl.selectedSegmentIndex, 1)
    }
    
    
    func testTableView_TogglingReverseShouldNotifyVisibleCells(){
        overrideWithMocks()

        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        //Real tables dont say that their cells are visible because they have been dequeued.  This might be a problem but i'm going to make this test work this way (with this hacked TabieView) and see what happens in the real thing.
        let tableView = MockWordPairTableView()
        tableView.dataSource = sut.viewModel
        sut.tableView = tableView
 
        sut.reverseWordPairSegmentedControl.selectedSegmentIndex = 1
        sut.reverseWordPairSegmentedControl.sendActions(for: .valueChanged)
        
        let cell = sut.tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! WordPairCell
        
        XCTAssertTrue(cell.reverseWordPair)
        
        //I'm buildint this test based on the assumption that calling cellForRow means that the cell is visible.  I am trying to verify that visible cells are notified when the order changes
        
        XCTAssertTrue(sut.viewModel.reverseWordPair)
        XCTAssertTrue(sut.reverseWordPair)
        
        sut.reverseWordPairSegmentedControl.selectedSegmentIndex = 0
        sut.reverseWordPairSegmentedControl.sendActions(for: .valueChanged)
        
        XCTAssertFalse(sut.reverseWordPair)
        XCTAssertFalse(sut.viewModel.reverseWordPair)
        
        XCTAssertFalse(cell.reverseWordPair)
        
    }
    
    func testTableView_TogglingReverseShouldReloadData(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        //Real tables dont say that their cells are visible because they have been dequeued.  This might be a problem but i'm going to make this test work this way (with this hacked TabieView) and see what happens in the real thing.
        let tableView = MockWordPairTableView()
        tableView.dataSource = sut.viewModel
        sut.tableView = tableView
        
        sut.reverseWordPairSegmentedControl.selectedSegmentIndex = 1
        sut.reverseWordPairSegmentedControl.sendActions(for: .valueChanged)
        
        let cell = sut.tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! WordPairCell
        
        XCTAssertTrue(cell.reverseWordPair)
        
        //I'm buildint this test based on the assumption that calling cellForRow means that the cell is visible.  I am trying to verify that visible cells are notified when the order changes
        
        XCTAssertTrue(sut.viewModel.reverseWordPair)
        XCTAssertTrue(sut.reverseWordPair)
        
        XCTAssertTrue(tableView.dataReloaded)
        
    }
    
    func testTableView_ShouldNotReloadDataWhenCallbackPresent(){
//        (() -> ())? = nil
        
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        //Real tables dont say that their cells are visible because they have been dequeued.  This might be a problem but i'm going to make this test work this way (with this hacked TabieView) and see what happens in the real thing.
        let tableView = MockWordPairTableView()
        tableView.dataSource = sut.viewModel
        sut.tableView = tableView
        
        var callbackCalled : Bool = false
        sut.updated({
            callbackCalled = true
        })
        
        XCTAssertTrue(callbackCalled)
        XCTAssertFalse(tableView.dataReloaded)
    }
    
    func testTableView_ShouldReloadDataWhenNoCallbackIsPassed(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        //Real tables dont say that their cells are visible because they have been dequeued.  This might be a problem but i'm going to make this test work this way (with this hacked TabieView) and see what happens in the real thing.
        let tableView = MockWordPairTableView()
        tableView.dataSource = sut.viewModel
        sut.tableView = tableView
        
        sut.updated()
        
        
        XCTAssertTrue(tableView.dataReloaded)
    }
    
    
    func testSearch_ShouldExist(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.wordPairSearchBar)
        XCTAssertNotNil(sut.wordPairSearchBar.backgroundImage) //Setting a blank image keeps the ugly borders from showing up
        XCTAssertNotNil(sut.wordPairSearchBar.delegate)
        
        XCTAssert(BrowseViewController.conforms(to: UISearchBarDelegate.self))
    }
    
    func testSearch_ChangingTextShouldCallSearch(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        let mockTableView = MockWordPairTableView()
        
        viewDidLoad()
        
        sut.tableView = mockTableView //Mock tableview is an override to the init.  Do this after view did load
        
        XCTAssertFalse(mockTableView.dataReloaded) //Assert initial state
        
        sut.searchBar(sut.wordPairSearchBar, textDidChange: "L")
        XCTAssertEqual(mockWebService.fetchWordPairPattern, "L")//Assert that webservice was called with enterted text.
        
        XCTAssertTrue(mockTableView.dataReloaded)
    }

}

