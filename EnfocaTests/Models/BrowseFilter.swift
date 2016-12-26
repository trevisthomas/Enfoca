//
//  BrowseFilter.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class BrowseFilterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ShouldContainProperRawValue(){
        
        XCTAssertEqual(BrowseFilter.all.rawValue, "All")
        XCTAssertEqual(BrowseFilter.active.rawValue, "Active Only")
        XCTAssertEqual(BrowseFilter.inactive.rawValue, "Inactive Only")
        
    }
    
    
}
