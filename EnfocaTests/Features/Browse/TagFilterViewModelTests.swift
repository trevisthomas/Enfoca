//
//  TagFilterViewModelTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class TagFilterViewModelTests: XCTestCase {
    
    var sut : TagFilterViewModel!
    var vc : TagFilterViewController!
    var mockWebService : MockWebService!
    
    override func setUp() {
        super.setUp()
        
        sut = TagFilterViewModel()
        
        let delegate = MockTagFilterDelegate()
        mockWebService = MockWebService()
        getAppDelegate().webService = mockWebService

        sut.configureFromDelegate(delegate: delegate){}
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        vc = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        vc.tagFilterDelegate = delegate
    }
    
    func testTuple_SizeShouldMatchSize(){
        let tableView = UITableView()
        
        let tags = sut.allTags
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), tags.count)

    }
    
    func testTable_ShouldDequeExpectedCellIdentifier(){
        let tableView = MockTableView()
        
        let _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(tableView.identifier, "TagFilterCell")
        //I'd like to test cell style but appearently it's not public
    }

    func testTable_ShouldNotBeAbleToSelectPendingRow(){
        let tableView = MockTableView()
        sut.localTagDictionary.removeValue(forKey: sut.allTags[1])
        
        XCTAssertNil(sut.tableView(tableView, willSelectRowAt: IndexPath(row: 1, section: 0)))
        XCTAssertNotNil(sut.tableView(tableView, willSelectRowAt: IndexPath(row: 0, section: 0)))
    }
    
    func testCells_ShouldContainTagData(){
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        let delegate = MockTagFilterDelegate()
        vc.tagFilterDelegate = delegate
        let _ = vc.view //View Did Load
        
        vc.tableView.delegate = sut
        vc.tableView.dataSource = sut
        
        
        let cell = sut.tableView(vc.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! TagCell
        
        let tag = sut.allTags[1]
        
        XCTAssertEqual(cell.tagTitleLabel?.text, tag.name)
        //Note: The detailTextLabel will be nil if the cell style isnt set
//        XCTAssertEqual(cell.tagSubtitleLabel?.text, sut.formatDetailText(tag.count))
    }
    
    func testTagSearch_SearchShouldLimitReultsToThoseMatchingSearchPattern() {
        
        let _ = vc.view //View Did Load
        
        
        vc.tableView.delegate = sut
        vc.tableView.dataSource = sut
        
        let tableView = vc.tableView!
        
        XCTAssertEqual(sut.allTags.count, sut.tableView(tableView, numberOfRowsInSection: 0))
        
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), sut.allTags.count) //Assert initial state of all tags shown
        
        sut.searchTagsFor(prefix: "Ph")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TagCell
        XCTAssertEqual(cell.tagTitleLabel?.text, "Phrase")
        XCTAssertTrue(cell.createButton.isHidden) //Asserting that create is hidden!
        
        let cell2 = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! TagCell
        XCTAssertEqual(cell2.tagTitleLabel?.text, "Ph")
        XCTAssertFalse(cell2.createButton.isHidden) //Asserting that it is in create mode!
        
        
        sut.searchTagsFor(prefix: "Xa")
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        
        sut.searchTagsFor(prefix: "Ad")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 3)
        
        sut.searchTagsFor(prefix: "nOun") //case insensitivie
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)

    }
    
    
    func testTagSearch_SearchShouldNotClearSelection() {
        
        let _ = vc.view //View Did Load
        
        vc.tableView.delegate = sut
        vc.tableView.dataSource = sut
        
        let tableView = vc.tableView!
        
        XCTAssertTrue(sut.allTags.count > 0)
        
        XCTAssertEqual(sut.allTags.count, sut.tableView(tableView, numberOfRowsInSection: 0))
        
        var cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0)) as! TagCell
        XCTAssertEqual(cell.tagTitleLabel?.text, "Phrase")
        XCTAssertFalse(cell.isSelected)
        
        var path = IndexPath(row: 2, section: 0)
        sut.tableView(vc.tableView, didSelectRowAt: path)
        
        cell = sut.tableView(tableView, cellForRowAt: path) as! TagCell
        XCTAssertEqual(cell.tagTitleLabel?.text, "Phrase")
        //XCTAssertTrue(cell.isSelected) //Irrelevant.  The table decides.
        XCTAssertTrue((vc.tableView.indexPathsForSelectedRows?.contains(path))!)
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), sut.allTags.count) //Assert initial state of all tags shown
        
        sut.searchTagsFor(prefix: "Ph")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2) //2 because of create cell
        path = IndexPath(row: 0, section: 0)
        cell = sut.tableView(tableView, cellForRowAt: path) as! TagCell
        XCTAssertEqual(cell.tagTitleLabel?.text, "Phrase")
        XCTAssertTrue((vc.tableView.indexPathsForSelectedRows?.contains(path))!)
        
    }
    
    func testGetSelected_ShouldReturnSelectedTags() {
        
        let _ = vc.view //View Did Load
        
        vc.tableView.delegate = sut
        vc.tableView.dataSource = sut
        
        let tableView = vc.tableView!
        
        XCTAssertTrue(sut.allTags.count > 0)
        
        XCTAssertEqual(sut.allTags.count, sut.tableView(tableView, numberOfRowsInSection: 0))
        
        
        var path = IndexPath(row: 2, section: 0)
        sut.tableView(vc.tableView, didSelectRowAt: path)
        
        let tag1 = sut.localTempTagFilters[path.row]
        
        path = IndexPath(row: 3, section: 0)
        sut.tableView(vc.tableView, didSelectRowAt: path)
        
        let tag2 = sut.localTempTagFilters[path.row]
        
        let selectedTags = sut.getSelectedTags()
        
        XCTAssertTrue(selectedTags.contains(tag1))
        XCTAssertTrue(selectedTags.contains(tag2))
    }
    
    func testDeselect_ShouldCallCallback(){
        
        
        let _ = vc.view
        
        let delegate = MockTagFilterViewModelDelegate()
        sut.tagFilterViewModelDelegate = delegate
        
        sut.deselectAll()
        
        XCTAssertTrue(delegate.selectedTagsChangedCalled)
        
    }
    
    func testTagSearch_CreateTagCreateButtonShouldCreate() {
        helperTestTagSearch()
    }
    
    func testTagSearch_CreateTagButtonShouldWorkEvenIfCreateCellDisapearedDuringWebCall(){
        helperTestTagSearch(disapear: true)
    }
    
    private func helperTestTagSearch(disapear : Bool = false){
        let _ = vc.view //View Did Load
        
        vc.tableView.delegate = sut
        vc.tableView.dataSource = sut
        
        let tableView = vc.tableView!
        
        let mockDelegate = MockTagFilterViewModelDelegate()
        sut.tagFilterViewModelDelegate = mockDelegate
        
        XCTAssertEqual(sut.allTags.count, sut.tableView(tableView, numberOfRowsInSection: 0))
        
        XCTAssertEqual(mockWebService.createTagCallCount, 0) //Assumed starting condition
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), sut.allTags.count) //Assert initial state of all tags shown
        
        sut.searchTagsFor(prefix: "Poptastic")
        
        mockWebService.createTagBlockCallback = true
        
        XCTAssertFalse(mockDelegate.reloadTableCalled)
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TagCell
        XCTAssertEqual(cell.tagTitleLabel?.text, "Poptastic")
        XCTAssertFalse(cell.createButton.isHidden) //Asserting that it is in create mode!
        
        cell.createButton.sendActions(for: .touchUpInside)
        
        guard let callback = mockWebService.createTagBlockedCallback else {
            XCTFail()
            return
        }
        
        if disapear {
            sut.localTempTagFilters.removeAll()
        }
        
        XCTAssertTrue(cell.createButton.isHidden)
        XCTAssertTrue(cell.activityIndicator.isAnimating)
        
        
        XCTAssertEqual(mockWebService.createTagCallCount, 1)
        XCTAssertEqual(mockWebService.createTagValue, "Poptastic")
        
        let tag = Tag(tagId: "id", name: "Poptastic")
        callback(tag, nil)
        
        XCTAssertTrue(sut.localTempTagFilters.index(of: tag)! >= 0) //Make sure that the tag is here
        XCTAssertNotNil(sut.localTagDictionary[tag]) //Tag should be in dicionary
        XCTAssertFalse(sut.localTagDictionary[tag]!) //Because new tag should not be selected.
        XCTAssertTrue(sut.allTags.index(of: tag)! >= 0) //New tag should be in all tags.
        XCTAssertTrue(mockDelegate.reloadTableCalled)

    }
    
    func testTagCreate_WebServiceErrorShouldAlert(){
        let _ = vc.view //View Did Load
        
        vc.tableView.delegate = sut
        vc.tableView.dataSource = sut
        
        let tableView = vc.tableView!
        
        let mockDelegate = MockTagFilterViewModelDelegate()
        sut.tagFilterViewModelDelegate = mockDelegate
        
        XCTAssertEqual(sut.allTags.count, sut.tableView(tableView, numberOfRowsInSection: 0))
        
        XCTAssertEqual(mockWebService.createTagCallCount, 0) //Assumed starting condition
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), sut.allTags.count) //Assert initial state of all tags shown
        
        sut.searchTagsFor(prefix: "Poptastic")
        
        mockWebService.createTagBlockCallback = true
        
        XCTAssertFalse(mockDelegate.reloadTableCalled)
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TagCell
        XCTAssertEqual(cell.tagTitleLabel?.text, "Poptastic")
        XCTAssertFalse(cell.createButton.isHidden) //Asserting that it is in create mode!
        
        cell.createButton.sendActions(for: .touchUpInside)
        
        guard let callback = mockWebService.createTagBlockedCallback else {
            XCTFail()
            return
        }
        
        callback(nil, "Network error fool")
        
        XCTAssertEqual(mockDelegate.alertMessage, "Network error fool")
        
        XCTAssertEqual(mockDelegate.alertTitle, "Error")
        
        XCTAssertFalse(cell.createButton.isHidden)
        XCTAssertFalse(cell.activityIndicator.isAnimating)
        
    }
    
    
}

extension TagFilterViewModelTests {
    class MockTagFilterDelegate : TagFilterDelegate{
        var tags: [Tag] = []
        var selectedTags: [Tag] = []
        func tagFilterUpdated(_ callback : (() -> ())? = nil) {
            //noop
        }
    }
    
    
}
