//
//  WordPairTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class WordPairTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ShouldBeInitialized(){
        
        let d = Date()
        let wp = WordPair(creatorId: 1, pairId: "guid", word: "hello", definition: "hola", dateCreated: d )
        
        XCTAssertEqual(wp.pairId, "guid")
        XCTAssertEqual(wp.word, "hello")
        XCTAssertEqual(wp.definition, "hola")
        XCTAssertEqual(wp.dateCreated, d)
        XCTAssertEqual(wp.creatorId, 1)
        
    }
    
}
