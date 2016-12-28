//
//  WordStateFilterViewControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class WordStateFilterViewControllerTests: XCTestCase {
    var sut : WordStateFilterViewController!
    
    override func setUp() {
        super.setUp()
        
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        sut = storyboard.instantiateViewController(withIdentifier: "WordStateFilterVC") as! WordStateFilterViewController
        
        //To force view did load to be called
        _ = sut.view
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ComponentsShouldBeWired(){
        XCTAssertNotNil(sut.tableView)
    }
    
    func testInit_ViewModelShouldHaveDelegateReference(){
        let viewModel = sut.tableView.dataSource as! WordStateFilterViewModel
        XCTAssertNotNil(viewModel.delegate)  //Verfies that viewDidLoad is really wiring things up.
    }
    
    func testInit_ShouldImplementWordStateFilterDelegate() {
        let optionalSut : WordStateFilterViewController? = sut
        
        guard let _ = optionalSut as? WordStateFilterDelegate else{
            XCTFail()
            return
        }
    }
    
    func testInit_VerifyDefaultIsSelected(){
        let mockVC = MockWordStateFilterViewController()
        let delegate = MockWordStateFilterDelegate()
        
        delegate.currentWordStateFilter = .active
        
        let tableView = MockTableView()
        mockVC.tableView = tableView
        mockVC.wordStateFilterDelegate = delegate
        
        mockVC.viewDidLoad() //Causes the currentVelue to be selcted
        
        XCTAssertNotNil(tableView.selectedIndexPath)
        XCTAssertEqual(tableView.selectedIndexPath?.row, WordStateFilter.asArray().index(of: .active))
    }
    
    func testInit_VerifyWordFilterDelegateClosesViewControler(){
        
        let mockVC = MockWordStateFilterViewController()
        
        let delegate = MockWordStateFilterDelegate()
        XCTAssertEqual(delegate.currentWordStateFilter, .all) //Asserting default state
        XCTAssertFalse(mockVC.dismissed) //Asserting that it was not initially dismissed
        mockVC.wordStateFilterDelegate = delegate
        mockVC.currentWordStateFilter = .inactive
        
        XCTAssertEqual(delegate.currentWordStateFilter, .inactive) //Asserting state changed
        
        XCTAssertTrue(mockVC.dismissed) // Asserting that VC was dismissed
        
    }
    
    func testTableView_ShouldContainAllWordFilters(){
        XCTAssertNotNil(sut.tableView)
        
        //Beaware that you *have* to create the ViewModel and use IB to wire it to the table's delegae if you want to unit test it this way. Or else it will be nil and will confuse the hell out of you.  You saw that technique in the Lynda unit testing video!
        guard let _ = sut.tableView.dataSource as? WordStateFilterViewModel else {
            XCTFail("Table dataSource is not a valid WordStateFilterViewModel")
            return
        }
        
        guard let _ = sut.tableView.delegate as? WordStateFilterViewModel else {
            XCTFail("Table delegate is not a valid WordStateFilterViewModel")
            return
        }
    }
    
    func testInit_PreferredContentSizeSouldBeWhatISay(){
        XCTAssertEqual(sut.preferredContentSize, CGSize(width: 250, height: 200))
    }
}

extension WordStateFilterViewControllerTests {
    class MockWordStateFilterDelegate : WordStateFilterDelegate {
        var currentWordStateFilter: WordStateFilter = .all
    }
    
    class MockWordStateFilterViewController : WordStateFilterViewController {
        var dismissed = false
        
        override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
            dismissed = true
            completion!()
        }
    }
    
    class MockTableView : UITableView {
        var selectedIndexPath : IndexPath?
        
        override func selectRow(at indexPath: IndexPath?, animated: Bool, scrollPosition: UITableViewScrollPosition) {
            selectedIndexPath = indexPath
        }
    }
}
