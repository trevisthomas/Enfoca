//
//  Sequence+Tests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class Sequence_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testOperation_ShuoldCompareSize(){
        let tagTuples = makeTags().map({
            (value : Tag) -> (Tag, Bool) in
            return (value, false)
        })
        
        var tagTuples2 = makeTags().map({
            (value : Tag) -> (Tag, Bool) in
            return (value, false)
        })
        
        XCTAssertTrue(tagTuples.compare(tagTuples2))
        
        tagTuples2.removeLast()
        
        XCTAssertFalse(tagTuples.compare(tagTuples2))
        XCTAssertFalse(tagTuples2.compare(tagTuples))
    }
    
    func testOperation_ShuoldBoolean(){
        let tagTuples = makeTags().map({
            (value : Tag) -> (Tag, Bool) in
            return (value, false)
        })
        
        var tagTuples2 = makeTags().map({
            (value : Tag) -> (Tag, Bool) in
            return (value, false)
        })
        
        XCTAssertTrue(tagTuples.compare(tagTuples2)) //Asserting initial state
        
        tagTuples2[1].1 = true
        tagTuples2[3].1 = true
        
        XCTAssertFalse(tagTuples.compare(tagTuples2))
        XCTAssertFalse(tagTuples2.compare(tagTuples))
    }
       
}
