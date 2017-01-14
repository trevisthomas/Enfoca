//
//  PairEditorTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class PairEditorViewControllerTests: XCTestCase {
    
    var sut : PairEditorViewController!
//    var authDelegate : MockAuthenticationDelegate!
    let currentUser = User(enfocaId: 99, name: "Agent", email: "nintynine@agent.net")
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "PairEditor", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "PairEditor") as! PairEditorViewController
//        authDelegate = MockAuthenticationDelegate(user: currentUser)
//        sut.authenticateionDelegate = authDelegate
//        sut.webService = MockWebService()
        
        
    }
    
    func viewDidLoad(){
        let _ = sut.view
    }

    
    func testInit_ViewControllerShouldBeWired(){
        viewDidLoad()
        
        XCTAssertNotNil(sut.wordTextField)
        XCTAssertNotNil(sut.definitionTextField)
        
        XCTAssertEqual(sut.saveOrCreateButton.title(for: .normal), "Create")
    }
    
    func testInit_ShouldBeInEditModeIfWordPairIsProvided(){
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
        sut.wordPair = wp
        
        viewDidLoad()
        
        XCTAssertEqual(sut.saveOrCreateButton.title(for: .normal), "Save")
        XCTAssertEqual(sut.wordTextField.text, wp.word)
        XCTAssertEqual(sut.definitionTextField.text, wp.definition)
    }
    
    
    
    func testBackButton_ShouldGoBack(){
        
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
}
