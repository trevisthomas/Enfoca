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
    
    override func setUp() {
        super.setUp()
        
        sut = TagFilterViewModel()
        
        let delegate = MockTagFilterDelegate()
        getAppDelegate().webService = MockWebService()
//        delegate.tags = makeTags()
        sut.configureFromDelegate(delegate: delegate)
        
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
        XCTAssertEqual(cell.tagSubtitleLabel?.text, sut.formatDetailText(tag.count))
    }
    
    func testTagSearch_SearchShouldLimitReultsToThoseMatchingSearchPattern() {
        
        let _ = vc.view //View Did Load
        
        vc.tableView.delegate = sut
        vc.tableView.dataSource = sut
        
        let tableView = vc.tableView!
        
        XCTAssertEqual(sut.allTags.count, sut.tableView(tableView, numberOfRowsInSection: 0))
        
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), sut.allTags.count) //Assert initial state of all tags shown
        
        sut.searchTagsFor(prefix: "Ph")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TagCell
        XCTAssertEqual(cell.tagTitleLabel?.text, "Phrase")
        
        
        sut.searchTagsFor(prefix: "Xa")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 0)
        
        sut.searchTagsFor(prefix: "Ad")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)
        
        sut.searchTagsFor(prefix: "nOun") //case insensitivie
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
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
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
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
        var called : Bool = false
        
        let _ = vc.view
        
        
        sut.observeChanges(callback: {
            called = true
        })
        
        sut.deselectAll()
        
        XCTAssertTrue(called)
        
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
