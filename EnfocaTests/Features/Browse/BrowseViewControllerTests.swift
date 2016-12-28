//
//  BrowseViewControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/27/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class BrowseViewControllerTests: XCTestCase {
    
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
        
        //To force view did load to be called
        _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ShouldHaveAuthDelegateAndWebService() {
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        XCTAssertNotNil(vc.authenticateionDelegate)
        XCTAssertNotNil(vc.webService)
    }
    
    func testInit_ShouldBeWiredAndReady(){
        XCTAssertNotNil(sut.wordStateFilterButton)
        XCTAssertNotNil(sut.tagFilterButton)
    }
    
    func testInit_ShouldHaveInitialalState(){
        XCTAssertEqual(sut.currentWordStateFilter, WordStateFilter.all)
    }
    func testInit_StateFilterButtonTextShouldMatchEnumRaw() {
        XCTAssertEqual(sut.wordStateFilterButton.currentTitle, WordStateFilter.all.rawValue)
        
    }
    
    func testStateFilterAction_ShouldCallPerformSegue(){
        
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
    
    private func makeTags() -> [Tag]{
        var tags: [Tag] = []
        tags.append(Tag(ownerId: currentUser.enfocaId, tagId: "123", name: "Noun"))
        tags.append(Tag(ownerId: currentUser.enfocaId, tagId: "124", name: "Verb"))
        tags.append(Tag(ownerId: currentUser.enfocaId, tagId: "125", name: "Phrase"))
        tags.append(Tag(ownerId: currentUser.enfocaId, tagId: "126", name: "Adverb"))
        tags.append(Tag(ownerId: currentUser.enfocaId, tagId: "127", name: "From Class #3"))
        return tags
    }
    
//    func testTagFilter_ShouldRecieveExpectedResults
}

extension BrowseViewControllerTests {
    class MockWebService : WebService {
        var fetchCallCount : Int = 0
        var tags : [Tag] = []
        var fetchUserId : Int?
        
        func fetchUserTags(enfocaId : Int, callback : @escaping([Tag])->()){
            fetchCallCount += 1
            fetchUserId = enfocaId
            
            callback(tags)
        }
        
    }
}
