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
        
        XCTAssertNotNil(vm.delegate)
    }
    
    
    func testInit_CellsShouldBeInflatedAndPoulated(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.tableView)
        
        let cell = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! WordPairCell
        
        let wp = mockWebService.wordPairs[2]
        
        XCTAssertNotNil(cell.wordLabel)
        XCTAssertNotNil(cell.definitionLabel)
        
        XCTAssertEqual(cell.wordLabel?.text, wp.word)
        XCTAssertEqual(cell.definitionLabel?.text, wp.definition)
    }
    
    func testInit_ViewModelShouldNotAnimateCellsDuringInit(){
        _ = sut.view
        XCTAssertFalse(sut.viewModel.animating)
    }
    
    func testWebService_ShouldFetchWordsFromServiceWithCurrentFilterParams(){
        overrideWithMocks()
        
        let defaults = MockDefaults(defaultWordStateFilter: .inactive)
        sut.appDefaults = defaults
        
        let service = sut.webService as! MockWebService //Just making sure
        
        viewDidLoad()
        
        //The webservice should be called!
        XCTAssertEqual(service.fetchWordPairTagFilter!, [])
        XCTAssertEqual(service.fetchWordPairWordStateFilter, sut.currentWordStateFilter)
    }
    
    func testWebService_WebserviceShouldBeCalledWhenFilterIsUpdated(){
        
        overrideWithMocks()
        
        let defaults = MockDefaults(defaultWordStateFilter: .inactive)
        sut.appDefaults = defaults
        
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
        
        mockDefaults.reverseWordPair = true
        sut.appDefaults = mockDefaults
        
        viewDidLoad()
        
        XCTAssertTrue(sut.viewModel.reverseWordPair)
        XCTAssertEqual(mockWebService.fetchWordPairOrder!, .definitionAsc)
    }
    
    func testAppDefaults_ViewModelShouldReflectNormalWordPairSetting(){
        overrideWithMocks()
        
        let mockDefaults = MockDefaults()
        
        mockDefaults.reverseWordPair = false
        sut.appDefaults = mockDefaults
        
        viewDidLoad()
        
        XCTAssertFalse(sut.viewModel.reverseWordPair)
        
        XCTAssertEqual(mockWebService.fetchWordPairOrder!, .wordAsc)
    }
    
    func testAppDefaults_ViewModelShouldReflectReverseWordPairSettingWhenFalse(){
        overrideWithMocks()
        
        let mockDefaults = MockDefaults()
        mockDefaults.reverseWordPair = false
        sut.appDefaults = mockDefaults
        viewDidLoad()
        
       XCTAssertFalse(sut.viewModel.reverseWordPair)
    }
    
    func testAppDefaults_ChangesToBrowseVCShouldUpdateAppDefaults(){
        overrideWithMocks()
        
        let mockDefaults = MockDefaults()
        mockDefaults.reverseWordPair = false
        sut.appDefaults = mockDefaults
        viewDidLoad()
        
        XCTAssertEqual(mockDefaults.saveCount, 0)
        XCTAssertFalse(sut.reverseWordPair)
        
        XCTAssertEqual(sut.reverseWordPairSegmentedControl.selectedSegmentIndex, 0) //Confirming initial state

        //Toggle the selector
        sut.reverseWordPairSegmentedControl.selectedSegmentIndex = 1
        sut.reverseWordPairSegmentedControl.sendActions(for: .valueChanged)
        
        //Verify that save was called and that the value was updated
        XCTAssertEqual(mockDefaults.saveCount, 1)
        XCTAssertTrue(mockDefaults.reverseWordPair)
    }
    
    func testAppDefaults_WordStateFilterChangeShouldUpdateAppDefaults(){
        overrideWithMocks()
        
        let mockDefaults = MockDefaults()
        mockDefaults.wordStateFilter = .inactive
        sut.appDefaults = mockDefaults
        viewDidLoad()
        
        
        XCTAssertEqual(mockDefaults.wordStateFilter, .inactive)
        XCTAssertEqual(mockDefaults.saveCount, 0)
        
        sut.currentWordStateFilter = .active
        sut.updated()
        
        //Verify that save was called and that the value was updated
        XCTAssertEqual(mockDefaults.saveCount, 1)
        XCTAssertEqual(mockDefaults.wordStateFilter, .active)
    }

    func testAppDefaults_TagFilterChangeShouldUpdateAppDefaults(){
        overrideWithMocks()
        
        viewDidLoad()
        
        let mockDefaults = MockDefaults()
        mockDefaults.tagFilters = makeTagTuples()
        sut.appDefaults = mockDefaults
        
        sut.tagTuples = mockDefaults.tagFilters //Doing this to bypass the service call.  That stuff is tested elsewhere
        
        XCTAssertEqual(mockDefaults.saveCount, 0)
        XCTAssertFalse(sut.tagTuples[3].1) //Assert initial state
        XCTAssertFalse(mockDefaults.tagFilters[3].1) //Trevis you asserted this a different way because you were amazed by the fact that just setting a value on a tuple called the didSet.  Still amazed by that.
        
        //Simulating what the tag filter view controller does.
        sut.tagTuples[3].1 = true
        sut.updated()
        
        //Verify that save was called and that the value was updated
        XCTAssertEqual(mockDefaults.saveCount, 1)
        
        XCTAssertTrue(mockDefaults.tagFilters[3].1)
    }

    
    func testSegmented_ShouldBeSetToDefault(){
        overrideWithMocks()
        mockWebService.wordPairs = makeWordPairs()
        let delegate = MockDefaults()
        delegate.reverseWordPair = true
        
        sut.appDefaults = delegate
        
        viewDidLoad()
        
        XCTAssertNotNil(sut.reverseWordPairSegmentedControl)
        XCTAssertEqual(sut.reverseWordPairSegmentedControl.selectedSegmentIndex, 1)
    }
    
    
    func testTableView_TogglingReverseShouldNotifyVisibleCells(){
        overrideWithMocks()

        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        XCTAssertEqual(mockWebService.fetchWordPairCallCount, 1)
        
        //Real tables dont say that their cells are visible because they have been dequeued.  This might be a problem but i'm going to make this test work this way (with this hacked TabieView) and see what happens in the real thing.
        let tableView = MockWordPairTableView()
        tableView.dataSource = sut.viewModel
        sut.tableView = tableView
 
        sut.reverseWordPairSegmentedControl.selectedSegmentIndex = 1
        sut.reverseWordPairSegmentedControl.sendActions(for: .valueChanged)
        
        let cell = sut.tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! WordPairCell
        
        XCTAssertTrue(cell.reverseWordPair)
        XCTAssertEqual(mockWebService.fetchWordPairCallCount, 2)
        
        //I'm buildint this test based on the assumption that calling cellForRow means that the cell is visible.  I am trying to verify that visible cells are notified when the order changes
        
        XCTAssertTrue(sut.viewModel.reverseWordPair)
        XCTAssertTrue(sut.reverseWordPair)
        
        sut.reverseWordPairSegmentedControl.selectedSegmentIndex = 0
        sut.reverseWordPairSegmentedControl.sendActions(for: .valueChanged)
        
        XCTAssertFalse(sut.reverseWordPair)
        XCTAssertFalse(sut.viewModel.reverseWordPair)
        
        XCTAssertEqual(mockWebService.fetchWordPairCallCount, 3)
//        XCTAssertFalse(cell.reverseWordPair) - I dont notify active cells anymore since i reload data.
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
    
    func testViewModel_TogglingReverseShouldAskViewModelToAnimateCells(){
        overrideWithMocks()
        
        mockWebService.wordPairs = makeWordPairs()
        
        viewDidLoad()
        
        //Real tables dont say that their cells are visible because they have been dequeued.  This might be a problem but i'm going to make this test work this way (with this hacked TabieView) and see what happens in the real thing.
        let tableView = MockWordPairTableView()
        let mockViewModel = MockViewModel()

        sut.webService = mockWebService
        
        mockViewModel.delegate = sut
        sut.viewModel = mockViewModel
        tableView.dataSource = sut.viewModel
        sut.tableView = tableView
        
        sut.reverseWordPairSegmentedControl.selectedSegmentIndex = 1
        sut.reverseWordPairSegmentedControl.sendActions(for: .valueChanged)
        
        let cell = sut.tableView.dataSource?.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! WordPairCell
        
        XCTAssertTrue(cell.reverseWordPair)
        
        XCTAssertEqual(mockViewModel.animatingSetCount, 1)
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
    
    func testSearch_TapOutsideShouldResignFirstResponder(){
        overrideWithMocks()
        
        viewDidLoad()
        
        let search = MockUISearchBar()
        sut.wordPairSearchBar = search
        
        XCTAssertEqual(sut.view.gestureRecognizers?.count, 1) //There should be one
        
        guard let tap = sut.view.gestureRecognizers?.first as? UITapGestureRecognizer else {
            XCTFail()
            return
        }
        
        
        //I cant figure out how to tap the tap :-(
        sut.dismissKeyboard()
        
        XCTAssertTrue(search.endEditingCalled)
        
        
    }
    
    func testTap_GestureRecognizerShouldCancelTouchesOnlyWhenKeyboardIsOpen(){
        overrideWithMocks()
        
        viewDidLoad()
        
        let search = MockUISearchBar()
        sut.wordPairSearchBar = search
        
        XCTAssertEqual(sut.view.gestureRecognizers?.count, 1) //There should be one
        
        guard let tap = sut.view.gestureRecognizers?.first as? UITapGestureRecognizer else {
            XCTFail()
            return
        }
        
        XCTAssertFalse(tap.cancelsTouchesInView)
        
        let notification = NSNotification(name: NSNotification.Name("Mock"), object: nil)
        
        sut.keyboardWillShow(notification)
        
        XCTAssertTrue(tap.cancelsTouchesInView)
        
        sut.keyboardDidHide(notification)
        
        XCTAssertFalse(tap.cancelsTouchesInView)
        
    }
    
    func testKeyboard_ShouldRegisterForKeyboardOpenCloseNotifications(){
        
        let mockCenter = MockNotificationCenter()
        sut.registerForKeyboardNotifications(mockCenter)
        
        XCTAssertTrue(mockCenter.list.contains(NSNotification.Name.UIKeyboardWillShow))
        XCTAssertTrue(mockCenter.list.contains(NSNotification.Name.UIKeyboardDidHide))
    }
    
    func testStorybard_ShoudContainSegues(){
        //To force view did load to be called
        _ = sut.view
        
        let list = segues(ofViewController: sut)
        XCTAssertTrue(list.contains("PairEditorSegue"))
    }
    
    func testEdit_EditingWordPairShouldSegue(){
        class MockBrowseViewController : BrowseViewController {
            var segueIdentifier : String?
            var sender : Any?
            override func performSegue(withIdentifier identifier: String, sender: Any?) {
                self.segueIdentifier = identifier
                self.sender = sender
            }
        }
        
        let mockVC = MockBrowseViewController(nibName: nil, bundle: nil)
        
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
        
        mockVC.edit(wordPair: wp)
        
        XCTAssertEqual(mockVC.segueIdentifier, "PairEditorSegue")
        XCTAssertEqual(mockVC.sender as! WordPair, wp)
    }
    
    func testEdit_SegueShouldPrepareForEdit(){
        overrideWithMocks()
        
        viewDidLoad()
        
        let storyboard = UIStoryboard(name: "PairEditor", bundle: nil)
        
        let destVC = storyboard.instantiateInitialViewController() as! PairEditorViewController
        let segue = UIStoryboardSegue(identifier: "PairEditorSegue", source: sut, destination: destVC)
        
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
        
        sut.prepare(for: segue, sender: wp)
        
        XCTAssertNotNil(destVC.wordPair)
        XCTAssertEqual(destVC.wordPair, wp)
    }
    
}

extension BrowseViewControllerStudyItemTests {
    
    class MockNotificationCenter : NotificationCenter{
        var list : [NSNotification.Name] = []
        override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
            list.append(aName!)
        }
    }
    
    
    class MockUISearchBar : UISearchBar{
        var endEditingCalled : Bool = false
        override func endEditing(_ force: Bool) -> Bool {
            endEditingCalled = true
            return true
        }
    }
    
    class MockViewModel : BrowseViewModel {
        var animatingSetCount = 0
        override var animating: Bool {
            didSet{
                animatingSetCount += 1
            }
        }
    }
}

