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
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        authDelegate = MockAuthenticationDelegate()
        sut.authenticateionDelegate = authDelegate
        
        //To force view did load to be called
        _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ShouldHaveAuthDelegate() {
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "BrowseVC") as! BrowseViewController
        XCTAssertNotNil(vc.authenticateionDelegate)
    }
    
    func testInit_ShouldBeWiredAndReady(){
        XCTAssertNotNil(sut.wordStateFilterButton)
        XCTAssertNotNil(sut.tagFilterButton)
    }
    
    func testInit_ShouldHaveInitialalState(){
        XCTAssertEqual(sut.currentWordStateFilter, WordStateFilter.all)
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
        
        XCTAssertNotNil(destVC.wordStateFilterDelegate)
        XCTAssertEqual(destVC.wordStateFilterDelegate.currentWordStateFilter, .active)
        
    }
    
}
