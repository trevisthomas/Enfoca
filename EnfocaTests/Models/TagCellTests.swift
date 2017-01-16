//
//  TagCellTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/15/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class TagCellTests: XCTestCase {
    
    var sut : TagCell!
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Browse", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TagFilterVC") as! TagFilterViewController
        let delegate = MockTagFilterDelegate()
        vc.tagFilterDelegate = delegate
        let _ = vc.view //View Did Load
        
        sut = vc.viewModel.tableView(vc.tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as! TagCell
    }
    
    func testInit_SelectedShouldSetSelected(){
        
        XCTAssertNotNil(sut.tagSelectedView)
        
        sut.setSelected(false, animated: false)
        XCTAssertFalse(sut.isSelected)
        XCTAssertTrue((sut.tagSelectedView?.isHidden)!)
        sut.setSelected(true, animated: false)
        XCTAssertTrue(sut.isSelected)
        XCTAssertFalse((sut.tagSelectedView?.isHidden)!)
    }
    
    
}
