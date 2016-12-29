//
//  TagFilterViewControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class TagFilterViewControllerTests: XCTestCase {
    var sut : TagFilterViewController!
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let destNav = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! UINavigationController
        sut = destNav.viewControllers.first as! TagFilterViewController
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testTuples_LocalChangesShouldNotNotifyDelegateUntilISaySo(){
//        let vc = TagFilterViewController()
//        let delegate = MockTagFilterDelegate()
//        vc.tagFilterDelegate = delegate
//        
//        vc.tagFilterViewModel.didtouchupinside
//        
//        XCTAssertFalse(delegate.touched) //Internal modifications dont notify delegate
//    }
    
    func testInit_ViewModelShouldBeWiredToDelegate(){
        let delegate = MockTagFilterDelegate()
        sut.tagFilterDelegate = delegate
        let _ = sut.view //View Did Load
        let viewModel = sut.tableView.dataSource as! TagFilterViewModel
        XCTAssertNotNil(viewModel.tagFilterDelegate)
    }
    
    func testInit_TableViewsDataSourceAndDelegateAreWiredToViewModel(){
        let delegate = MockTagFilterDelegate()
        sut.tagFilterDelegate = delegate
        let _ = sut.view //View Did Load
        
        let _ = sut.tableView.delegate as! TagFilterViewModel
        let viewModel = sut.tableView.dataSource as! TagFilterViewModel
        
        XCTAssertNotNil(viewModel.tagFilterDelegate)  //Verfies that viewDidLoad is really wiring things up.
    }
    
    func testTable_TableShouldSelectTagsFromDelegateTuple(){
        let delegate = MockTagFilterDelegate()
        delegate.tagTuples[1].1 = true //Select this row
        delegate.tagTuples[3].1 = true //Select this row

        sut.tagFilterDelegate = delegate
        
        let _ = sut.view //View Did Load
        
        XCTAssertTrue(sut.tableView.allowsMultipleSelection)
        
        let selected = sut.tableView.indexPathsForSelectedRows!
        XCTAssertEqual(selected.count, 2)
        let selectedRows = selected.map({
            (value : IndexPath) -> Int in
            return value.row
        })
        
        XCTAssertTrue(selectedRows.contains(1))
        XCTAssertTrue(selectedRows.contains(3))
    }
    
    func testInit_TitleIsSet(){
        XCTAssertEqual(sut.navigationItem.title, "Tag Filter")
    }
    
    func testTableView_RowSelectionShouldNotUpdateDelegate(){
        let delegate = MockTagFilterDelegate()
        sut.tagFilterDelegate = delegate
        let _ = sut.view //View Did Load
        let path = IndexPath(row: 2, section: 0)
        XCTAssertFalse(delegate.touched)
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: path)
        XCTAssertFalse(delegate.touched) //Stil false!
        
    }
    
    func testTableView_ApplyFilterShouldUpdateDelegate(){
        let delegate = MockTagFilterDelegate()
        sut.tagFilterDelegate = delegate
        let _ = sut.view //View Did Load
        let path = IndexPath(row: 2, section: 0)
        
        XCTAssertFalse(delegate.tagTuples[2].1) //Assert that this is not selected in the delegate
        XCTAssertFalse(delegate.touched)
        
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: path)
        XCTAssertFalse(delegate.touched) //Stil false!
        XCTAssertFalse(delegate.tagTuples[2].1) //Assert that this is still not selected in the delegate
        
//        sut.applyFilter()
        
        let applyButton = sut.navigationItem.rightBarButtonItem!
        XCTAssertEqual(applyButton.title, "Apply")

        UIApplication.shared.sendAction(applyButton.action!, to: applyButton.target, from: nil, for: nil)
        //Verify that it is selected now and that it has been notified
        XCTAssertTrue(delegate.touched)
        XCTAssertTrue(delegate.tagTuples[2].1)
        
    }

    func testTableView_ShouldDequeueMyCell() {
        let delegate = MockTagFilterDelegate()
        sut.tagFilterDelegate = delegate
        let _ = sut.view //View Did Load
        
        //This test is insuring that the expected cell is registered.  At the moment IB does it.
        guard let cell = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as UITableViewCell? else{
            XCTFail()
            return
        }
        
        XCTAssertNotNil(cell)
        
        let (tag, _) = sut.tagFilterDelegate.tagTuples[0]
        XCTAssertEqual(cell.textLabel?.text, tag.name)
        //Note: The detailTextLabel will be nil if the cell style isnt set
        XCTAssertNotNil(cell.detailTextLabel)
    }
    
    func testApplyFilter_ButtonShoudldExist(){
        let delegate = MockTagFilterDelegate()
        sut.tagFilterDelegate = delegate
        let _ = sut.view //View Did Load
        
        let applyButton = sut.navigationItem.rightBarButtonItem!
        XCTAssertEqual(applyButton.title, "Apply")
    }
    
//    func testApplyButton_ApplyShouldNotifyDelegateOfUpdatedTuple(){
//        let delegate = MockTagFilterDelegate()
//        sut.tagFilterDelegate = delegate
//        
//        let _ = sut.view //View Did Load
//        
//        sut.applyFilter()
//    }
    
//    func testInit_ShouldHaveAuthDelegateAndWebService() {
//        XCTAssertNotNil(sut.authenticateionDelegate)
//        XCTAssertNotNil(sut.webService)
//    }
    
}

extension TagFilterViewControllerTests {
    
    class MockTagFilterDelegate : TagFilterDelegate {
        var touched : Bool = false
        
        init(){
            self.tagTuples = makeTags().map({
                (value : Tag) -> (Tag, Bool) in
                return (value, false)
            })
        }
        var tagTuples : [(Tag, Bool)] = []
        
        func updated(){
            touched = true
        }
    }
}
