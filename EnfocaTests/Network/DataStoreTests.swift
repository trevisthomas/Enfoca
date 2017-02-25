//
//  DataStoreTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/24/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class DataStoreTests: XCTestCase {
    var sut : DataStore!
    
    var tags : [Tag] = []
    var wordPairs : [WordPair] = []
    var wpAss : [TagAssociation] = []
    
    override func setUp() {
        super.setUp()
        
        sut = DataStore()
        sut.initialize(tags: tags, wordPairs: wordPairs, tagAssociations: wpAss)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit(){
        mockDataOne()
        
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
    }
    
    func testInit_PairShouldHaveExpectedTags(){
        mockDataOne()
        
        guard let wp : WordPair = sut.findWordPair(withId: "100") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(wp.tags.count, 2)
        XCTAssertEqual(wp.tags.tagsToText(), "Adjective, Noun")
    }
    
    func testTagAssociation_AddTagShouldWork() {
        mockDataOne()
        
        let tag = sut.tags["1"]!
        let wordPair = sut.wordPairs["102"]!
        
        XCTAssertEqual(tag.count, 2) //Initial state
        
        let newAssociation = sut.createTagAssociation(tag: tag, wordPair: wordPair)
        
        XCTAssertEqual(tag.count, 3)
        XCTAssertTrue(tag.wordPairs.contains(wordPair))
        XCTAssertTrue(wordPair.tags.contains(tag))
        XCTAssertTrue(sut.tagAssociations.contains(where: { (tagAss : TagAssociation) -> Bool in
            return tagAss.tagId == tag.tagId && tagAss.wordPairId == wordPair.pairId
        }))
        
        XCTAssertEqual(newAssociation.tagId, tag.tagId)
        XCTAssertEqual(newAssociation.wordPairId, wordPair.pairId)
    }
    
    func testTagAssociation_RemoveTagShouldWork(){
        mockDataOne()
        
        let tag = sut.tags["1"]!
        let wordPair = sut.wordPairs["100"]!
        
        XCTAssertEqual(wordPair.tags.count, 2) //initial state
        XCTAssertEqual(tag.count, 2) //Initial state
        XCTAssertTrue(wordPair.tags.contains(tag)) //Initial
        
        guard let tagAssociation = sut.remove(tag: tag, from: wordPair) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(tagAssociation.tagId, tag.tagId)
        XCTAssertEqual(tagAssociation.wordPairId, wordPair.pairId)
        
        XCTAssertFalse(tag.wordPairs.contains(wordPair))
        XCTAssertFalse(wordPair.tags.contains(tag))
        XCTAssertEqual(tag.count, 1)
        XCTAssertEqual(wordPair.tags.count, 1)
    }
    
    //TODO
    
    // create WordPair
    // create Tag
    // delete WP
    // delete Tag
    // modify WP
    // modify Tag
    // search for WP by word
    // search for WP by definition
    // search for Tag by name
    // search for WP with n-tags
}


extension DataStoreTests{
    func mockDataOne(){
        tags.append(Tag(tagId: "1", name: "Noun"))
        tags.append(Tag(tagId: "2", name: "Verb"))
        tags.append(Tag(tagId: "3", name: "Adjective"))
        
        wordPairs.append(WordPair(pairId: "100", word: "Azul", definition: "Blue"))
        wordPairs.append(WordPair(pairId: "101", word: "Amarillo", definition: "Yellow"))
        wordPairs.append(WordPair(pairId: "102", word: "Clave", definition: "Nail"))
        
        wpAss.append(TagAssociation(wordPairId: wordPairs[0].pairId, tagId: tags[0].tagId))
        wpAss.append(TagAssociation(wordPairId: wordPairs[0].pairId, tagId: tags[2].tagId))
        
        wpAss.append(TagAssociation(wordPairId: wordPairs[1].pairId, tagId: tags[0].tagId))
        
        
        
        sut.initialize(tags: tags, wordPairs: wordPairs, tagAssociations: wpAss)
    }
}
