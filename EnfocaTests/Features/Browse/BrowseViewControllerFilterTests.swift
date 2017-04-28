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
        
        getAppDelegate().webService = MockWebService()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        authDelegate = MockAuthenticationDelegate(user: currentUser)
        sut.authenticateionDelegate = authDelegate
//        sut.webService = MockWebService()
        
        
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
    }
    
    func testInit_ShouldHaveAuthDelegateAndWebService() {
//        _ = sut.view
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        
        _ = vc.view
        XCTAssertNotNil(vc.authenticateionDelegate)
        XCTAssertNotNil(vc.webService)
        
    }
    
    func testInit_ShouldBeWiredAndReady(){
        _ = sut.view
        
        XCTAssertNotNil(sut.tagFilterButton)
        XCTAssertNotNil(sut.backButton)
    }
    
    func testBackButton_ShouldCallInvisibleNavigationController(){
        
        class MockNav : UINavigationController {
            var popped : Bool = false
            override func popViewController(animated: Bool) -> UIViewController? {
                popped = true
                return super.popViewController(animated: animated)
            }
        }
        
        let nav = MockNav()
        
        nav.pushViewController(sut, animated: false)
        
        let _ = nav.view
        let _ = sut.view
        
        
        sut.backButton.sendActions(for: .touchUpInside)
        
        XCTAssertTrue(nav.popped)
    }
    
    func testTagFilter_ShouldInitializeSelfWithExpectedDataFromMockServvice(){
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        let webservice = MockWebService()
        let mockDefaults = MockDefaults()
        
        vc.authenticateionDelegate = authDelegate
        vc.webService = webservice
        webservice.tags = makeTags()
        
        let tagRow = 3
        
        mockDefaults.tags = webservice.tags
        let tagUnderTest = mockDefaults.tags[tagRow]
        mockDefaults.selectedTags = [tagUnderTest]
        
        vc.appDefaults = mockDefaults
        
        //To force view did load to be called
        _ = vc.view
        
        XCTAssertEqual(webservice.fetchUserTagsCallCount, 1)

        XCTAssertTrue(vc.selectedTags.contains(tagUnderTest))
    }
    
    func testTagFilter_ShouldMergeStateOfLocalTagFiltersIntoServerResults(){
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        let webservice = MockWebService()
        
        vc.authenticateionDelegate = authDelegate
        vc.webService = webservice
        
        webservice.tags = makeTags()
        
        let tagCount = webservice.tags.count
        XCTAssertTrue(tagCount > 0)
        
        //To force view did load to be called
        _ = vc.view
        
        XCTAssertEqual(webservice.fetchUserTagsCallCount, 1)
        
        XCTAssertEqual(vc.tags.count, tagCount)
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
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        let segue = UIStoryboardSegue(identifier: "TagFilterSegue", source: sut, destination: destVC)
        
        sut.tags = makeTags()
        
        sut.prepare(for: segue, sender: sut.tagFilterButton)
        
        let popover: UIPopoverPresentationController = destVC.popoverPresentationController!
        
        //Alternatives?
        XCTAssertEqual((popover.delegate as! BrowseViewController), sut) //BrowseViewController should be the delegate
        XCTAssertEqual(sut.tagFilterButton.bounds, popover.sourceRect)
        
        XCTAssertEqual(destVC.modalPresentationStyle, .popover)
        
        //TODO: test VC for expected stuff
        XCTAssertNotNil(destVC.tagFilterDelegate)
        
        _ = destVC.view
        
        XCTAssertEqual(destVC.viewModel.allTags.count, sut.tags.count)
        
        XCTAssertTrue(destVC.tagFilterDelegate.selectedTags == sut.selectedTags)
        
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
        
        XCTAssertEqual(webservice.fetchUserTagsCallCount, 1)
        
        
        let testTag = vc.tags[1] //Grab a tag to test
        vc.selectedTags.append(testTag)
        
        vc.tagFilterUpdated() //Notify the VC that it should refresh
        
        XCTAssertEqual(webservice.fetchWordPairTagFilter!, [testTag]) //Assert that the testTag was passed to the service
        
        XCTAssertEqual(webservice.fetchWordPairCallCount, 2)
        
        vc.tagFilterUpdated() //Notify the VC that it should refresh
        
    }
    
   
}

