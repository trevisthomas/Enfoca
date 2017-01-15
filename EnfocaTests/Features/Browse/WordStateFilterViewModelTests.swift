//
//  WordStateFilterViewModelTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class WordStateFilterViewModelTests: XCTestCase {
    
    var sut : WordStateFilterViewModel!
    
    override func setUp() {
        super.setUp()
        sut = WordStateFilterViewModel()
        sut.delegate = MockWordStateFilterDelegate()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTableView_ShouldDequeueExpectedIdentifier() {
        let tableView = MockTableView()
        _ = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(tableView.identifier, "WordStateFilterCell")
    }
    
    func testTableView_CheckCellCount(){
        let tableView = UITableView()
        let rowsInSection = sut.tableView(tableView, numberOfRowsInSection: 0)
        XCTAssertEqual(rowsInSection, 3)
    }
    
    func testForTableView_ShouldContainAllWordStateFilters(){
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "WordStateFilterVC") as! WordStateFilterViewController
        
        //To force view did load to be called
        _ = vc.view
        
        let tableView = vc.tableView!

        var cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertEqual(cell.textLabel?.text, WordStateFilter.all.rawValue)
        
        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0))
        XCTAssertEqual(cell.textLabel?.text, WordStateFilter.active.rawValue)
        
        cell = sut.tableView(tableView, cellForRowAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(cell.textLabel?.text, WordStateFilter.inactive.rawValue)
        
    }
    
    func testTableView_DidSelectShouldNotifyDelegate(){
        XCTAssertEqual(sut.delegate.currentWordStateFilter, .all)
        let tableView = UITableView()
        
        sut.tableView(tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
        XCTAssertEqual(sut.delegate.currentWordStateFilter, .inactive)
    }
    
}

extension WordStateFilterViewModelTests {

    
//    class MockDelegate : WordStateFilterDelegate {
//        var currentWordStateFilter: WordStateFilter = .all
//    }
}
