//
//  LoginViewControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class LoginViewControllerTests: XCTestCase {
    
    var sut : LoginViewController!
    var authDelegate : MockAuthenticationDelegate!
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        authDelegate = MockAuthenticationDelegate()
        sut.authenticateionDelegate = authDelegate
        
        //To force view did load to be called
        _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitialization_ShouldHideBackButton(){
        XCTAssertTrue(sut.navigationItem.hidesBackButton)
    }
    
    func testInitialization_ShouldConnectCallbackToAppDelegate(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        XCTAssertNotNil(appDelegate.userAuthenticated)
    }
    
    func testViewDidLoad_ShouldAttemptSilentLogin(){
        XCTAssertNotNil(sut)
        XCTAssertEqual(authDelegate.performSilentLoginCount, 1)
    }
    
    func testUserChange_ShouldSegueWhenUserChange(){
        class MockLoginViewController : LoginViewController {
            var segueIdentifier : String?
            var user : User?
            override func performSegue(withIdentifier identifier: String, sender: Any?) {
                segueIdentifier = identifier
                user = sender as? User
            }
        }
        
        let mockVC = MockLoginViewController(nibName: nil, bundle: nil)
        
        let user = User(enfocaId: 0, name: "bob", email: "whatever@who.com")
        
        mockVC.userAuthenticated(user: user)
        
        XCTAssertEqual(mockVC.segueIdentifier, "WelcomeVC")
        XCTAssertEqual(mockVC.user, user)
    }
    
    func testUserChange_ShouldPrepareForSegueWithUser(){
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeViewController
        let segue = UIStoryboardSegue(identifier: "WelcomeVC", source: sut, destination: destVC)
        
        let user = User(enfocaId: 0, name: "bob", email: "whatever@who.com")
        
        sut.prepare(for: segue, sender: user)
        
        XCTAssertEqual(destVC.user, user)
        
    }

}


