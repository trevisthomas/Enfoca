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
    
    var mockWebservice : MockWebService!
    
    override func setUp() {
        super.setUp()
        
        mockWebservice = MockWebService()
        getAppDelegate().webService = mockWebservice
        
        let storyboard = UIStoryboard(name: "PairEditor", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "PairEditor") as! PairEditorViewController
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
        
        XCTAssertNotNil(sut.tagButton)
        
    }
    
    func testInit_ShouldBeInAddModeIfWordPairIsNotProvided(){
        viewDidLoad()
        
        XCTAssertEqual(sut.saveOrCreateButton.title(for: .normal), "Create")
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Tags: (none)")
        
    }
    
    
    func testInit_ShouldBeInEditModeIfWordPairIsProvided(){
        let tag1 = Tag(ownerId: -1, tagId: "shrug", name: "Noun")
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])
        
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
        
        let tag1 = Tag(ownerId: -1, tagId: "shrug", name: "Noun")
        
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])
        
        
        mockVC.configureForEdit(wordPair: wp);
        
        mockVC.tagButtonAction(UIButton())
        
        XCTAssertEqual(mockVC.identifier, "TagEditorSegue")
        XCTAssertNotNil(mockVC.sender)
        XCTAssertEqual(mockVC.selectedTags, wp.tags)
        
    }
    
    
    
    func testSegue_SegueShouldPrepareWithDelegate(){
        viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        
        let segue = UIStoryboardSegue(identifier: "TagEditorSegue", source: sut, destination: destVC)
        
        sut.prepare(for: segue, sender: [])
        
        XCTAssertNotNil(destVC.tagFilterDelegate)
        
    }
    
    func testSegue_TagEditorShouldPopover(){
        
        viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        
        let segue = UIStoryboardSegue(identifier: "TagEditorSegue", source: sut, destination: destVC)
        
        sut.prepare(for: segue, sender: [])
        
        XCTAssertNotNil(destVC.tagFilterDelegate)

        let popover: UIPopoverPresentationController = destVC.popoverPresentationController!
        
        XCTAssertEqual(popover.delegate as? PairEditorViewController, sut)
        XCTAssertEqual(sut.tagButton.frame, popover.sourceRect)
        XCTAssertEqual(destVC.modalPresentationStyle, .popover)
        XCTAssertFalse(popover.permittedArrowDirections.contains(.down))
        XCTAssertTrue(popover.permittedArrowDirections.contains(.left))
        XCTAssertTrue(popover.permittedArrowDirections.contains(.right))
        XCTAssertFalse(popover.permittedArrowDirections.contains(.up))
    }
    
    func testSegue_SegueShouldPrepareWithSelectedTags(){
        let tag1 = Tag(ownerId: -1, tagId: "shrug", name: "Noun")
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])

        sut.wordPair = wp
        
        viewDidLoad()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        
        let destVC = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        
        let segue = UIStoryboardSegue(identifier: "TagEditorSegue", source: sut, destination: destVC)
        
        
        sut.prepare(for: segue, sender: wp.tags)
        
        XCTAssertNotNil(destVC.tagFilterDelegate)
        XCTAssertEqual(wp.tags, destVC.tagFilterDelegate.selectedTags);
        
    }
    
   
    func testUpdated_UpdatedShouldUpdateTagSummary(){
        let wp = makeWordPair()
        sut.wordPair = wp
        
        viewDidLoad()
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Noun")
        
        let tag2 = Tag(ownerId: -1, tagId: "shrug", name: "Proverb")
        sut.selectedTags.append(tag2)
        
        sut.updated(nil)
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Noun, Proverb")
    }

    func testSave_ShouldNotifyDelegateUpdated(){
        
        let wp = makeWordPair()
        let mockDelegate = MockPairEditorDelegate()
        
        sut.wordPair = wp
        sut.delegate = mockDelegate
        
        let word = "new word"
        let def = "it's definition"
        
        
        
        viewDidLoad()
        
        sut.wordTextField.text = word
        sut.definitionTextField.text = def
        
        let tag1 = Tag(ownerId: -1, tagId: "shrug", name: "Noun")
        
        sut.selectedTags.append(tag1)
        
        XCTAssertEqual(mockDelegate.updatedCallCount, 0)
        XCTAssertEqual(mockDelegate.addedCallCount, 0)
        
        sut.saveOrCreateButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(mockWebservice.updateCalledCount, 1)
        XCTAssertEqual(mockWebservice.createCalledCount, 0)
        
        XCTAssertNotNil(mockDelegate.updated)
        XCTAssertNil(mockDelegate.added)
        XCTAssertEqual(mockDelegate.addedCallCount, 0)
        XCTAssertEqual(mockDelegate.updatedCallCount, 1)
        
        XCTAssertEqual(mockDelegate.updated?.word, word)
        XCTAssertEqual(mockDelegate.updated?.definition, def)
        XCTAssertEqual((mockDelegate.updated?.tags)!, sut.selectedTags)
    }
    
    func testCreate_ShouldNotifyDelegateAdded(){
        let mockDelegate = MockPairEditorDelegate()
        
        sut.delegate = mockDelegate
        
        viewDidLoad()
        
        XCTAssertEqual(mockDelegate.updatedCallCount, 0)
        XCTAssertEqual(mockDelegate.addedCallCount, 0)
        
        XCTAssertEqual(mockWebservice.createCalledCount, 0)
        
        sut.saveOrCreateButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(mockWebservice.createCalledCount, 1)
        
        XCTAssertNil(mockDelegate.updated)
        XCTAssertNotNil(mockDelegate.added)
        XCTAssertEqual(mockDelegate.addedCallCount, 1)
        XCTAssertEqual(mockDelegate.updatedCallCount, 0)
    }
    
    //Validation!
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
    
    class MockPairEditorDelegate : PairEditorDelegate {
        var added : WordPair?
        var updated : WordPair?
        
        var addedCallCount : Int = 0
        var updatedCallCount : Int = 0
        
        func added(wordPair: WordPair) {
            addedCallCount += 1
            added = wordPair
        }
        
        func updated(wordPair: WordPair) {
            updatedCallCount += 1
            updated = wordPair
        }
    }
    
    func makeWordPair() -> WordPair {
        let tag1 = Tag(ownerId: -1, tagId: "shrug", name: "Noun")
        
        let wp = WordPair(creatorId: 1, pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])
        
        return wp
    }
    
}
