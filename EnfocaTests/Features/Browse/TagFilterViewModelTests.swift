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
    
    override func setUp() {
        super.setUp()
        
        sut = TagFilterViewModel()
        
        let tagTuples = makeTags().map({
            (value : Tag) -> (Tag, Bool) in
            return (value, false)
        })
        
        let delegate = MockTagFilterDelegate()
        delegate.tagTuples = tagTuples
        sut.configureFromDelegate(delegate: delegate)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTuple_SizeShouldMatchSize(){
        let tableView = UITableView()
        
        let tagTuples = sut.tagFilterDelegate.tagTuples
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), tagTuples.count)

    }
    
    func testTable_ShouldDequeExpectedCellIdentifier(){
        let tableView = MockTableView()
        let _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(tableView.identifier, "TagFilterCell")
        //I'd like to test cell style but appearently it's not public
    }
    
    func testCells_ShouldContainTagData(){
        let tableView = MockTableView()
        
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) 
        
        let (tag, _) = sut.tagFilterDelegate.tagTuples[1]
        
        XCTAssertEqual(cell.textLabel?.text, tag.name)
        //Note: The detailTextLabel will be nil if the cell style isnt set
        XCTAssertEqual(cell.detailTextLabel?.text, sut.formatDetailText(tag.count))
    }
    
    func testTagSearch_SearchShouldLimitReultsToThoseMatchingSearchPattern() {
        let tableView = MockTableView()
        
        XCTAssertEqual(sut.tagFilterDelegate.tagTuples.count, sut.tableView(tableView, numberOfRowsInSection: 0))
        
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), sut.tagFilterDelegate.tagTuples.count) //Assert initial state of all tags shown
        
        sut.searchTagsFor(prefix: "Ph")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
        let cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text, "Phrase")
        
        
        sut.searchTagsFor(prefix: "Xa")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 0)
        
        sut.searchTagsFor(prefix: "Ad")
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 2)
        
        sut.searchTagsFor(prefix: "nOun") //case insensitivie
        
        XCTAssertEqual(sut.tableView(tableView, numberOfRowsInSection: 0), 1)
    }
    
   //You dont need to track the state this way.  The controller will deal with this
//    func testTuple_ShouldToggleSelectedWhenTouched(){
//        let tableView = UITableView()
//        
//        XCTAssertFalse(sut.tagFilterDelegate.tagTuples![1].1)
//        
//        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
//        
//        XCTAssertTrue(sut.tagFilterDelegate.tagTuples![1].1)
//        
//        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
//        
//        XCTAssertFalse(sut.tagFilterDelegate.tagTuples![1].1)
//        
//    }

    //This never made sense here, the controller owns the table
//    func testTuple_InitialStateOfTableShouldReflectTupleSelectionState(){
//        let tableView = UITableView()
//        
//        
//        tableView.selected
//        XCTAssertFalse(sut.tagFilterDelegate.tagTuples![1].1)
//        
//        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
//        
//        XCTAssertTrue(sut.tagFilterDelegate.tagTuples![1].1)
//        
//        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
//        
//        XCTAssertFalse(sut.tagFilterDelegate.tagTuples![1].1)
//        
//    }
    
}

extension TagFilterViewModelTests {
    class MockTagFilterDelegate : TagFilterDelegate{
        var tagTuples : [(Tag, Bool)] = []
        func updated(_ callback : (() -> ())? = nil) {
            //noop
        }
        
        
    }
}
