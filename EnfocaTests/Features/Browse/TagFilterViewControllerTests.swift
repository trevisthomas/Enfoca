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
    var mockWebService : MockWebService!
    override func setUp() {
        super.setUp()
        
        mockWebService =  MockWebService()
        
        getAppDelegate().webService = mockWebService
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        
        let delegate = MockTagFilterDelegate()
        sut.tagFilterDelegate = delegate
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ViewModelShouldBeWiredToDelegate(){
        
        let _ = sut.view //View Did Load
        let viewModel = sut.tableView.dataSource as! TagFilterViewModel
        XCTAssertNotNil(viewModel.tagFilterDelegate)
    }
    
    
    func testInit_TableViewsDataSourceAndDelegateAreWiredToViewModel(){
        let _ = sut.view //View Did Load
        
        let _ = sut.tableView.delegate as! TagFilterViewModel
        let viewModel = sut.tableView.dataSource as! TagFilterViewModel
        
        XCTAssertNotNil(viewModel.tagFilterDelegate)  //Verfies that viewDidLoad is really wiring things up.
    }
    
    func testTable_TableShouldSelectTagsFromDelegateTuple(){
        let delegate = MockTagFilterDelegate()
        
        delegate.selectedTags.append(delegate.tags[1])
        delegate.selectedTags.append(delegate.tags[3])

        sut.tagFilterDelegate = delegate
        
        let _ = sut.view //View Did Load
        
        XCTAssertTrue(sut.tableView.allowsMultipleSelection)
        
        //Made a change later where the VM does the table selection instead in ViewDidLoad to fix this test, i'm going to ask for the cells which will cause them to be selected.  This all works because filter apply also relies on the VM, not the actual selected rows.  The selected rows are just cosmetic now.
        
        for i in 0 ..< delegate.tags.count {
            _ = sut.viewModel.tableView(sut.tableView, cellForRowAt: IndexPath(row: i, section: 0))
        }
        
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
        let delegate = sut.tagFilterDelegate as! MockTagFilterDelegate
        let _ = sut.view //View Did Load
        let path = IndexPath(row: 2, section: 0)
        XCTAssertFalse(delegate.updateCalled)
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: path)
        XCTAssertFalse(delegate.updateCalled) //Stil false!
        
    }
    
   
    func testTableView_ShouldDequeueMyCell() {
        let _ = sut.view //View Did Load
        
        //This test is insuring that the expected cell is registered.  At the moment IB does it.
        guard let cell = sut.tableView.dataSource?.tableView(sut.tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! TagCell? else{
            XCTFail()
            return
        }
        
        XCTAssertNotNil(cell)
        
        let tag = sut.viewModel.allTags[0]
        XCTAssertEqual(cell.tagTitleLabel?.text, tag.name)
    }
    
    func testApplyFilter_ButtonShoudldExist(){
        let _ = sut.view //View Did Load
        
        let applyButton = sut.navigationItem.rightBarButtonItem!
        XCTAssertEqual(applyButton.title, "Apply")
    }
    
    func testClear_ButtonShouldExist() {
        let _ = sut.view //View Did Load
        
        let clearButton = sut.clearButton
        XCTAssertEqual(clearButton?.title(for: .normal), "Clear")
    }
    
    func testClear_ClearButtonShouldClearSelections(){
        let _ = sut.view //View Did Load
        
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        
        let tag1 = sut.viewModel.allTags[1]
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Selected: \(tag1.name)")
        
        
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
        
        let tag2 = sut.viewModel.allTags[2]
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Selected: \(tag2.name), \(tag1.name)")
        
        XCTAssertEqual(sut.viewModel.getSelectedTags().count, 2)
        
        sut.clearButton.sendActions(for: .touchUpInside)
        
        XCTAssertEqual(sut.viewModel.getSelectedTags().count, 0)
        
    }
    
    
    func testApplyFilter_ShouldBeAbleToUnselectASelectedItem(){
        let delegate = sut.tagFilterDelegate as! MockTagFilterDelegate
        
        let _ = sut.view //View Did Load
        let path = IndexPath(row: 2, section: 0)
        XCTAssertFalse(delegate.updateCalled)
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: path)
        XCTAssertFalse(delegate.updateCalled) //Stil false!
        
        let selectedTag = delegate.tags[2]
        
        XCTAssertFalse(delegate.selectedTags.contains(selectedTag))
        
        sut.applyFilterAction(sut.applyButton)
        XCTAssertTrue(delegate.updateCalled)
        
        XCTAssertTrue(delegate.selectedTags.contains(selectedTag))
        
        sut.tableView.delegate?.tableView!(sut.tableView, didDeselectRowAt: path) //This should deselect
        sut.applyFilterAction(sut.applyButton)
        XCTAssertFalse(delegate.selectedTags.contains(selectedTag))
    }
    
    func testTableView_ApplyFilterShouldUpdateDelegateAndCloseView(){
        let delegate = sut.tagFilterDelegate as! MockTagFilterDelegate
        let _ = sut.view //View Did Load
        let path = IndexPath(row: 2, section: 0)
        let selectedTag = delegate.tags[2]
        
        XCTAssertFalse(delegate.selectedTags.contains(selectedTag)) //Assert that this is not selected in the delegate
        XCTAssertFalse(delegate.updateCalled)
        
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: path)
        XCTAssertFalse(delegate.updateCalled) //Stil false!
        XCTAssertFalse(delegate.selectedTags.contains(selectedTag)) //Assert that this is still not selected in the delegate
        
        let applyButton = sut.applyButton!
        XCTAssertEqual(applyButton.title(for: .normal), "Apply")
        applyButton.sendActions(for: .touchUpInside)
        
        //Verify that it is selected now and that it has been notified
        XCTAssertTrue(delegate.updateCalled)
        XCTAssertTrue(delegate.selectedTags.contains(selectedTag))
        
        //TODO: How to test if popover is closed?
        
    }

    
    func testSearch_ShouldExist(){
        let _ = sut.view //View Did Load
        
        XCTAssertNotNil(sut.tagSearchBar)
        XCTAssertNotNil(sut.tagSearchBar.backgroundImage) //Setting a blank image keeps the ugly borders from showing up
        XCTAssertNotNil(sut.tagSearchBar.delegate)
        
        XCTAssert(TagFilterViewController.conforms(to: UISearchBarDelegate.self))
        
        XCTAssertEqual(sut.tagSearchBar.placeholder, "Tag Search")
    }
    
    func testSearch_ChangingTextShouldCallSearch(){
        let viewModel = MockTagFilterViewModel()
        let _ = sut.view //View Did Load
        
        let mockTableView = MockTableView()
        sut.tableView = mockTableView
        sut.viewModel = viewModel
        
        sut.searchBar(sut.tagSearchBar, textDidChange: "L")
        XCTAssertEqual(viewModel.searchFor, "L")
        
        XCTAssertTrue(mockTableView.dataReloaded)
    }
    
    //This break was missed initially!
    func testSearch_ApplyFilterShoudSelectProperTag(){
        let delegate = sut.tagFilterDelegate as! MockTagFilterDelegate
        
        let _ = sut.view //View Did Load
        
        let selectedTag = delegate.tags[2]
        
        XCTAssertFalse(delegate.selectedTags.contains(selectedTag)) //Assert that this is not selected in the delegate
        XCTAssertFalse(delegate.updateCalled)
        
        
        sut.searchBar(sut.tagSearchBar, textDidChange: selectedTag.name) //Search for this tag
        
        //Post search, the list should contain only this tag (and the create cell!)
        XCTAssertEqual(sut.viewModel.tableView(sut.tableView, numberOfRowsInSection: 0), 2)
        
        let path = IndexPath(row: 0, section: 0) //The only row post search
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: path)
        
        let applyButton = sut.applyButton!
        XCTAssertEqual(applyButton.title(for: .normal), "Apply")
        
        applyButton.sendActions(for: .touchUpInside)
        
        //Verify that it is selected now and that it has been notified
        XCTAssertTrue(delegate.updateCalled)
        XCTAssertTrue(delegate.selectedTags.contains(selectedTag))
        
        //TODO: How to test if popover is closed?
        
    }
    
    func testSearch_IfSearchIsBlankDontPresentCreate(){
        let delegate = sut.tagFilterDelegate as! MockTagFilterDelegate
        
        let _ = sut.view //View Did Load
        
        let selectedTag = delegate.tags[2]
        
        XCTAssertFalse(delegate.selectedTags.contains(selectedTag)) //Assert that this is not selected in the delegate
        XCTAssertFalse(delegate.updateCalled)
        
        
        sut.searchBar(sut.tagSearchBar, textDidChange: "") //Search for this tag
        
        //Blank search, AKA clearing, should show all, and no create button
        XCTAssertEqual(sut.viewModel.tableView(sut.tableView, numberOfRowsInSection: 0), delegate.tags.count)
        
    }

    
    func testTagSummary_LabelShouldExist(){
        let _ = sut.view //View Did Load
        XCTAssertNotNil(sut.tagSummaryLabel)
        XCTAssertEqual(sut.tagSummaryLabel.text, "Selected: (none)")
    }
    
    func testTagSummary_LabelShouldShowProperSummary(){
        let _ = sut.view //View Did Load
        
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        
        let tag1 = sut.viewModel.allTags[1]
        
        XCTAssertEqual(sut.tagSummaryLabel.text, "Selected: \(tag1.name)")
        
        
        sut.tableView.delegate?.tableView!(sut.tableView, didSelectRowAt: IndexPath(row: 2, section: 0))
        
        let tag2 = sut.viewModel.allTags[2]
        XCTAssertEqual(sut.tagSummaryLabel.text, "Selected: \(tag2.name), \(tag1.name)")
    }
    
    func testTagFilterViewModelDelegate_TableShouldReload(){
        let _ = sut.view //View Did Load
        
        let mockTable = MockTableView()
        sut.tableView = mockTable
        
        sut.reloadTable()
        
        XCTAssertTrue(mockTable.dataReloaded)
    }
    
    func testTagFilterViewModelDelegate_AlertShouldAlert(){
        let vc = MockTagFilterViewController()
        
        vc.alert(title: "Error", message: "Message")
        
        let alertVC = vc.viewControllerPresented as! UIAlertController
        
        XCTAssertEqual(alertVC.title, "Error")
        XCTAssertEqual(alertVC.message, "Message")
    }
}

extension TagFilterViewControllerTests {
    class MockTagFilterViewModel : TagFilterViewModel {
        var searchFor : String?
        override func searchTagsFor(prefix: String) {
            searchFor = prefix
        }
    }
    
    class MockTagFilterViewController : TagFilterViewController{
        var viewControllerPresented : UIViewController!
        
        override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
            viewControllerPresented = viewControllerToPresent
        }
    }
    
}
