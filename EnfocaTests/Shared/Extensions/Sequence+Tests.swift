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
    
    func testCompare_ShuoldCompareSize(){
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
    
    func testCompare_ShuoldBoolean(){
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
    
    func testTagsToText_OneTag(){
        let tag = Tag(ownerId: -1, tagId: "", name: "Noun")
        let listOfOne = [tag]
        let text = listOfOne.tagsToText()
        XCTAssertEqual(text, "Noun")
        
    }
    
    func testTagsToText_TwoTags(){
        let tag1 = Tag(ownerId: -1, tagId: "", name: "Noun")
        let tag2 = Tag(ownerId: -1, tagId: "", name: "Bird")
        let two = [tag1, tag2]
        let text = two.tagsToText()
        XCTAssertEqual(text, "Noun, Bird")
        
    }
    
    func testTagsToText_EmptyList() {
        let empty : [Tag] = []
        XCTAssertEqual(empty.tagsToText(), "")
    }

    
//    private void createCommaSeperatedListOfStrings(Collection<String> collection,
//    StringBuilder builder) {
//    boolean first = true;
//    for(String key : collection){
//    if(!first){
//				builder.append(",");
//    } else {
//				first = !first;
//    }
//    builder.append("'").append(key).append("'");
//    }
//    }
    
}
