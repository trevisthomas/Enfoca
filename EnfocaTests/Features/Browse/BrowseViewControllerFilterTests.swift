//
//  BrowseViewControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/27/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class BrowseViewControllerFilterTests: XCTestCase {
    
    var sut : BrowseViewController!
    var authDelegate : MockAuthenticationDelegate!
    let currentUser = User(enfocaId: 99, name: "Agent", email: "nintynine@agent.net")
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        authDelegate = MockAuthenticationDelegate(user: currentUser)
        sut.authenticateionDelegate = authDelegate
        sut.webService = MockWebService()
        
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testStorybard_ShoudContainSegues(){
        //To force view did load to be called
        _ = sut.view
        
        let list = segues(ofViewController: sut)
        XCTAssertTrue(list.contains("TagFilterSegue"))
        XCTAssertTrue(list.contains("WordStateFilterSegue"))
        
    }
    
    func testInit_ShouldHaveAuthDelegateAndWebService() {
        _ = sut.view
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        XCTAssertNotNil(vc.authenticateionDelegate)
        XCTAssertNotNil(vc.webService)
        
        
    }
    
    func testInit_ShouldBeWiredAndReady(){
        _ = sut.view
        
        XCTAssertNotNil(sut.wordStateFilterButton)
        XCTAssertNotNil(sut.tagFilterButton)
        XCTAssertNotNil(sut.backButton)
    }
    
    func backButton_ShouldCallInvisibleNavigationController(){
        let _ = sut.view
        
        let origCount = sut.navigationController?.viewControllers.count
        
        sut.backButton.sendActions(for: .touchUpInside)
        
        XCTAssertTrue((sut.navigationController?.viewControllers.count)! < origCount!)
    }
    
    func testInit_StateFilterButtonTextShouldMatchEnumRaw() {
        let defaults = MockDefaults(defaultWordStateFilter: .active)
        sut.appDefaultsDelegate = defaults
        _ = sut.view
        XCTAssertEqual(sut.wordStateFilterButton.currentTitle, WordStateFilter.active.rawValue)
        
    }

    
   
    
    func testStateFilterAction_ShouldCallPerformSegue(){
        _ = sut.view
        
        class MockBrowseViewController : BrowseViewController {
            var segueIdentifier : String?
            var sender : Any?
            override func performSegue(withIdentifier identifier: String, sender: Any?) {
                self.segueIdentifier = identifier
                self.sender = sender
            }
        }
        
        let mockVC = MockBrowseViewController(nibName: nil, bundle: nil)
        
        let button = UIButton()
        mockVC.wordStateFilterAction(button)
        
        XCTAssertEqual(mockVC.segueIdentifier, "WordStateFilterSegue")
        XCTAssertEqual(mockVC.sender as! UIButton, button)
    }
    
    func testSegueWordStateFilter_ShouldSegueWithWordStateFilterWhenSourceIsButton() {
        _ = sut.view
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "WordStateFilterVC") as! WordStateFilterViewController
        let segue = UIStoryboardSegue(identifier: "WordStateFilterSegue", source: sut, destination: destVC)
        
        sut.currentWordStateFilter = .active
        
        sut.prepare(for: segue, sender: sut.wordStateFilterButton)
        
        XCTAssertEqual(destVC.modalPresentationStyle, .popover)
        
        XCTAssertNotNil(destVC.wordStateFilterDelegate)
        XCTAssertEqual(destVC.wordStateFilterDelegate.currentWordStateFilter, .active)
        
        let popover: UIPopoverPresentationController = destVC.popoverPresentationController!
        
        //Alternatives?
        XCTAssertEqual(popover.delegate as! BrowseViewController, sut) //BrowseViewController should be the delegate
        XCTAssertEqual(sut.wordStateFilterButton.bounds, popover.sourceRect)
        
    }
    
    
    func testPopoverDelegate_ShouldAlwaysReturnsNone(){
        //Enforces popover style on device
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let destVC = storyboard.instantiateViewController(withIdentifier: "WordStateFilterVC") as! WordStateFilterViewController
        
        let style = sut.adaptivePresentationStyle(for: destVC.presentationController!)
        XCTAssertEqual(UIModalPresentationStyle.none, style)
    }
    
    func testTagFilter_ShouldInitializeSelfWithExpectedDataFromMockServvice(){
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        let webservice = MockWebService()
        
        vc.authenticateionDelegate = authDelegate
        vc.webService = webservice
        
        webservice.tags = makeTags()
        
        //To force view did load to be called
        _ = vc.view
        
        XCTAssertEqual(webservice.fetchCallCount, 1)
        XCTAssertEqual(webservice.fetchUserId, currentUser.enfocaId)
        
        
        let tagTuples : [(Tag, Bool)] = vc.tagTuples
        XCTAssertEqual(tagTuples.count, 5)
    }
    
    func testTagFilter_ShouldCallPerformSegue(){
        
        class MockBrowseViewController : BrowseViewController {
            var segueIdentifier : String?
            var sender : Any?
            override func performSegue(withIdentifier identifier: String, sender: Any?) {
                self.segueIdentifier = identifier
                self.sender = sender
            }
        }
        
        let mockVC = MockBrowseViewController(nibName: nil, bundle: nil)
        
        let button = UIButton()
        mockVC.tagFilterAction(button)
        
        XCTAssertEqual(mockVC.segueIdentifier, "TagFilterSegue")
        XCTAssertEqual(mockVC.sender as! UIButton, button)
    }
    
    func testSegueTagFilter_ShouldSegueWithTagTupleWhenSourceIsButton() {
        _ = sut.view
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        
        let destNav = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! UINavigationController
        let destVC = destNav.viewControllers.first as! TagFilterViewController
        let segue = UIStoryboardSegue(identifier: "TagFilterSegue", source: sut, destination: destNav)
        
//        sut.currentWordStateFilter = .active
        sut.tagTuples = makeTags().map({
            (value : Tag) -> (Tag, Bool) in
            return (value, false)
        })
        
        sut.prepare(for: segue, sender: sut.tagFilterButton)
        
        let popover: UIPopoverPresentationController = destNav.popoverPresentationController!
        
        //Alternatives?
        XCTAssertEqual(popover.delegate as! BrowseViewController, sut) //BrowseViewController should be the delegate
        XCTAssertEqual(sut.tagFilterButton.bounds, popover.sourceRect)
        
        XCTAssertEqual(destNav.modalPresentationStyle, .popover)
        
        //TODO: test VC for expected stuff
        XCTAssertNotNil(destVC.tagFilterDelegate)
        XCTAssertEqual(destVC.tagFilterDelegate.tagTuples.count, sut.tagTuples.count)
        
        XCTAssertTrue(destVC.tagFilterDelegate.tagTuples.compare(sut.tagTuples))
        
    }
    
    func testTagFilterDelegate_ShouldUpdateFromWebService(){
        
        
        let origStateFilter : WordStateFilter = .active
        let defaults = MockDefaults(defaultWordStateFilter: origStateFilter)
        sut.appDefaultsDelegate = defaults
        
        
        _ = sut.view
        
        let webService = sut.webService as! MockWebService
        
        XCTAssertEqual(webService.fetchWordPairCallCount, 1)
        sut.updated()
        XCTAssertEqual(webService.fetchWordPairCallCount, 2)
        
        
        
        XCTAssertEqual(sut.currentWordStateFilter, origStateFilter) //Just verifying that we're in a known start state
        XCTAssertEqual(webService.fetchWordPairWordStateFilter, origStateFilter)
        sut.currentWordStateFilter = origStateFilter //No change.
        XCTAssertEqual(webService.fetchWordPairCallCount, 2) //Confirm no service call
        sut.currentWordStateFilter = .inactive //A change
        sut.updated()
        XCTAssertEqual(webService.fetchWordPairCallCount, 3)
        XCTAssertEqual(webService.fetchWordPairWordStateFilter, .inactive)
    }
    
    
    func testTagFilter_UpdateShouldCallWebServiceWithFilter(){
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        let webservice = MockWebService()
        
        vc.authenticateionDelegate = authDelegate
        vc.webService = webservice
        
        webservice.tags = makeTags()
        
        //To force view did load to be called
        _ = vc.view
        
        XCTAssertEqual(webservice.fetchCallCount, 1)
        XCTAssertEqual(webservice.fetchUserId, currentUser.enfocaId)
        
        
        
        let testTag = vc.tagTuples[1].0 //Grab a tag to test
        vc.tagTuples[1].1 = true //Turn on the filter for this tag
        
        vc.updated() //Notify the VC that it should refresh
        
        XCTAssertEqual(webservice.fetchWordPairTagFilter!, [testTag]) //Assert that the testTag was passed to the service
        
        XCTAssertEqual(webservice.fetchWordPairCallCount, 2)
        
        vc.updated() //Notify the VC that it should refresh
        
    }
}

