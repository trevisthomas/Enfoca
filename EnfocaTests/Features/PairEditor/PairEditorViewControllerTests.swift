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
    
    let tagsNoneMessage = "Tags: (none)"
    
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
        XCTAssertEqual(sut.tagSummaryLabel.text, tagsNoneMessage)
        
        XCTAssertTrue(sut.deleteButton.isHidden)
        let list = segues(ofViewController: sut)
        XCTAssertTrue(list.contains("TagEditorSegue"))
        
        XCTAssertNotNil(sut.tagButton)
        
    }
    
    func testInit_ShouldBeInAddModeIfWordPairIsNotProvided(){
        viewDidLoad()
        
        XCTAssertEqual(sut.saveOrCreateButton.title(for: .normal), "Create")
        
        XCTAssertEqual(sut.tagSummaryLabel.text, tagsNoneMessage)
        
    }
    
    
    func testInit_ShouldBeInEditModeIfWordPairIsProvided(){
        let tag1 = Tag(tagId: "shrug", name: "Noun")
        let wp = WordPair(pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])
        
        sut.wordPair = wp
        
        viewDidLoad()
        
        XCTAssertEqual(sut.saveOrCreateButton.title(for: .normal), "Save")
        XCTAssertEqual(sut.wordTextField.text, wp.word)
        XCTAssertEqual(sut.definitionTextField.text, wp.definition)
        XCTAssertEqual(sut.tagSummaryLabel.text, "Noun")
        XCTAssertFalse(sut.deleteButton.isHidden)
        
    }
    
    func testInit_TitleShouldBeAppropriateWhenNoTags(){
        let wp = WordPair(pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date())
        
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
        
        let mockVC = PairEditorViewControllerMockVCTests.MockPairEditorViewController(nibName: nil, bundle: nil)
        
        let tag1 = Tag(tagId: "shrug", name: "Noun")
        
        let wp = WordPair(pairId: "pear-id", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])
        
        
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
        let tag1 = Tag(tagId: "shrug", name: "Noun")
        let wp = WordPair(pairId: "thisIsCrap", word: "Red", definition: "Rojo", dateCreated: Date(), tags: [tag1])

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
        
        let tag2 = Tag(tagId: "shrug", name: "Proverb")
        sut.selectedTags.append(tag2)
        
        sut.tagFilterUpdated(nil)
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Noun, Proverb")
    }

    func testUpdated_RemovingAllTagsShouldResetTagMessage(){
        let wp = makeWordPair()
        sut.wordPair = wp
        
        viewDidLoad()
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Noun")
        
        sut.selectedTags.removeAll()
        
        sut.tagFilterUpdated(nil)
        
        XCTAssertEqual(sut.tagSummaryLabel.text, tagsNoneMessage)
    }
    
    func testSave_ShouldNotifyDelegateUpdated(){
        
        let wp = makeWordPair()
        let mockDelegate = PairEditorViewControllerMockVCTests.MockPairEditorDelegate()
        
        sut.wordPair = wp
        sut.delegate = mockDelegate
        
        let word = "new word"
        let def = "it's definition"
        let example = "it's a word, Bird."
        
        viewDidLoad()
        
        sut.wordTextField.text = word
        sut.definitionTextField.text = def
        sut.exampleTextView.text = example
        
        let tag1 = Tag(tagId: "shrug", name: "Noun")
        
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
        XCTAssertEqual(mockDelegate.updated?.gender, wp.gender)
        XCTAssertEqual(mockDelegate.updated?.example, example)
    }
    
    func testCreate_ShouldNotifyDelegateAdded(){
        let mockDelegate = PairEditorViewControllerMockVCTests.MockPairEditorDelegate()
        
        sut.delegate = mockDelegate
        
        let word = "new word"
        let def = "it's definition"
        let example = "Ejemplo"
        let gender : Gender = .masculine
        
        viewDidLoad()
        
        sut.wordTextField.text = word
        sut.definitionTextField.text = def
        sut.exampleTextView.text = example
        sut.gender = gender
        
        let tag1 = Tag(tagId: "shrug", name: "Noun")
        let tag2 = Tag(tagId: "shrug", name: "Vurbe")
        
        sut.selectedTags.append(tag1)
        sut.selectedTags.append(tag2)
        
        XCTAssertEqual(mockDelegate.updatedCallCount, 0)
        XCTAssertEqual(mockDelegate.addedCallCount, 0)
        
        XCTAssertEqual(mockWebservice.createCalledCount, 0)
        
        sut.saveOrCreateButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(mockWebservice.createCalledCount, 1)
        
        XCTAssertNil(mockDelegate.updated)
        XCTAssertNotNil(mockDelegate.added)
        XCTAssertEqual(mockDelegate.addedCallCount, 1)
        XCTAssertEqual(mockDelegate.updatedCallCount, 0)
        
        XCTAssertEqual(mockDelegate.added?.word, word)
        XCTAssertEqual(mockDelegate.added?.definition, def)
        XCTAssertEqual((mockDelegate.added?.tags)!, sut.selectedTags)
        XCTAssertEqual(mockDelegate.added?.gender, gender)
        XCTAssertEqual(mockDelegate.added?.example, example)
    }
    
   
}



extension PairEditorViewControllerTests {
    

    
    
    
}
