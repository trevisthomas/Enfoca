//
//  TagAssociationTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class TagAssociationTests: XCTestCase {
    
//    var sut = TagAssociation()
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
//        let me = User(enfocaId: 1, name: "Player 1", email: "anemaim@email.com")
        let t = Tag(ownerId: 1, tagId: "GUID", name: "Noun")
        let ass = TagAssociation(ownerId: 1, tag: t)
        
        XCTAssertEqual(ass.ownerId, 1)
        XCTAssertEqual(ass.tag.tagId, t.tagId)
    }
    
    
}
