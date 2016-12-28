//
//  WelcomeViewControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class WelcomeViewControllerTests: XCTestCase {
    var sut : WelcomeViewController!
    var authDelegate : MockAuthenticationDelegate!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeViewController
        authDelegate = MockAuthenticationDelegate()
        sut.authenticationDelegate = authDelegate
        _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialization_ShouldHideBackButton(){
        XCTAssertTrue(sut.navigationItem.hidesBackButton)
    }
    
    func testInitialState_ComponentsAreInflatedFromStoryboard(){
        XCTAssertNotNil(sut.welcomeLabel)
        XCTAssertNotNil(sut.browseButton)
        XCTAssertEqual(sut.browseButton.title(for: .normal), "Browse")
        XCTAssertNotNil(sut.quizButton)
        XCTAssertEqual(sut.quizButton.title(for: .normal), "Quiz")
        
        XCTAssertNotNil(sut.logOffButton)
        XCTAssertEqual(sut.logOffButton.title(for: .normal), "Log Off")
    }
    
    func testInitialState_ShouldShowWelcomMessage(){
        let user = User(enfocaId: 1, name: "Player 1", email: "player@email.com")
        sut.user = user
        XCTAssertEqual(sut.welcomeLabel.text, "Hi, \(user.name). Welcome to...")
    }
    
    func testLogoff_ActionShouldTellDelegateToLogOff(){
        XCTAssertEqual(authDelegate.performLogoffCount, 0)
        sut.logoffAction("not important")
        XCTAssertEqual(authDelegate.performLogoffCount, 1)
    }
    
    func testLogoff_ShouldSegueLoginAfterLogoff(){
        class MockViewController : WelcomeViewController {
            var popped = false
            
            override func popSelfFromNavStackNotUnitTestable(){
                popped = true
            }
        }
        
        let mockVC = MockViewController()
        
        mockVC.logoffAction("not important")
        
        XCTAssertTrue(mockVC.popped)
        
    }
    
    func testBrowseButtonAction_ShouldSegueToBrowseVC(){
        class MockWelcomeViewController : WelcomeViewController {
            var segueIdentifier : String?
            
            override func performSegue(withIdentifier identifier: String, sender: Any?) {
                segueIdentifier = identifier
                
            }
        }
        
        let mockVC = MockWelcomeViewController(nibName: nil, bundle: nil)
        
        mockVC.browseWordsAction(UIButton())
        //Note, if you wire directly to the button *and* initiate the segue in the button action you'll get two VC's The solution that i have settled on is to wire the segue from VC to VC, insteand of from Button to VC
        XCTAssertEqual(mockVC.segueIdentifier, "BrowseSegue")
    }
    
    func testStorybard_ShoudContainSegues(){
        let list = segues(ofViewController: sut)
        XCTAssertTrue(list.contains("BrowseSegue"))
        
    }
    
    
    

    
}
