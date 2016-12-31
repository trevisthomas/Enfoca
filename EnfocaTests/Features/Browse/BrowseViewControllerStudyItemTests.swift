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
    
        
}
