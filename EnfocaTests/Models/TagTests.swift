//
//  TagTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class TagTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_PropertiesShoudBeSet(){
        let tag = Tag(tagId: "12345", name: "Noun")
        XCTAssertEqual(tag.tagId, "12345")
        XCTAssertEqual(tag.name, "Noun")
    }
    
    func testEquatible_ShouldWork(){
        let tag = Tag(tagId: "12345", name: "Noun")
        let tag1 = Tag(tagId: "12345", name: "Noun")
        let tag2 = Tag(tagId: "54321", name: "Not")
        
        XCTAssertNotEqual(tag, tag2)
        XCTAssertEqual(tag, tag1)
    }
    
    
}
