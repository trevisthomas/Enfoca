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
    
}
