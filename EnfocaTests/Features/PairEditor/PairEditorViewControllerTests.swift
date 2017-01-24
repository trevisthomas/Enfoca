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
        XCTAssertEqual(sut.tagSummaryLabel.text, "Tags: (none)")
        
        let list = segues(ofViewController: sut)
        XCTAssertTrue(list.contains("TagEditorSegue"))
    }
    
    func testInit_ShouldBeInEditModeIfWordPairIsProvided(){
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
        
        let tag1 = Tag(ownerId: -1, tagId: "shrug", name: "Noun")
        wp.tags.append(tag1)
        
        sut.wordPair = wp
        
        viewDidLoad()
        
        XCTAssertEqual(sut.saveOrCreateButton.title(for: .normal), "Save")
        XCTAssertEqual(sut.wordTextField.text, wp.word)
        XCTAssertEqual(sut.definitionTextField.text, wp.definition)
        XCTAssertEqual(sut.tagSummaryLabel.text, "Noun")
        
    }
    
    func testInit_TitleShouldBeAppropriateWhenNoTags(){
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
        
        sut.wordPair = wp
        
        viewDidLoad()
        
        XCTAssertEqual(sut.saveOrCreateButton.title(for: .normal), "Save")
        XCTAssertEqual(sut.wordTextField.text, wp.word)
        XCTAssertEqual(sut.definitionTextField.text, wp.definition)
        XCTAssertEqual(sut.tagSummaryLabel.text, "Tags: (none)")
        
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
    
    func testTagButton_ShouldSegueWhenTapped(){
        
        let mockVC = MockPairEditorViewController(nibName: nil, bundle: nil)
        
        mockVC.tagButtonAction(UIButton())
        
        XCTAssertEqual(mockVC.identifier, "TagEditorSegue")
        XCTAssertNotNil(mockVC.sender)
        
    }
    
    func testSegue_SegueShouldPrepareWithDelegate(){
        viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        
        let segue = UIStoryboardSegue(identifier: "TagEditorSegue", source: sut, destination: destVC)
        
        sut.prepare(for: segue, sender: [])
        
        XCTAssertNotNil(destVC.tagFilterDelegate)
        
    }
    
//    func testSegue_SegueShouldPrepareWithSelectedTags(){
//        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
//
//        let tag1 = Tag(ownerId: -1, tagId: "shrug", name: "Noun")
//        wp.tags.append(tag1)
//
//        sut.wordPair = wp
//        
//        viewDidLoad()
//        
//        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
//        
//        let destVC = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
//        
//        let segue = UIStoryboardSegue(identifier: "TagEditorSegue", source: sut, destination: destVC)
//        
//        //        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
//        
//        sut.prepare(for: segue, sender: [])
//        
//        XCTAssertNotNil(destVC.tagFilterDelegate)
//        
//    }
    
    //TODO: Test when performSegue is called that the destVC is passed the proper tuple stuff.  Look at 'testEdit_EditingWordPairShouldSegue' in the BVC StudyItemTests
    
    
}

extension PairEditorViewControllerTests {
    class MockPairEditorViewController : PairEditorViewController {
        var identifier : String!
        var sender : Any?
        override func performSegue(withIdentifier identifier: String, sender: Any?) {
            self.identifier = identifier
            self.sender = sender
        }
    }
}
