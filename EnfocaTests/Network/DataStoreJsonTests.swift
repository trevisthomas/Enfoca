//
//  DataStoreJsonTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/18/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
import CloudKit
@testable import Enfoca

class DataStoreJsonTests: XCTestCase {
    
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTag_ShouldCreateTagFromJson(){
        let tag = Tag(tagId: "123-123-123", name: "noun")
        
        let json = tag.toJson()
        
        let tag2 = Tag(json: json)
        XCTAssertEqual(tag2.name, "noun")
        XCTAssertEqual(tag2.tagId, "123-123-123")
        
        XCTAssertEqual(tag2, tag)
        
    }
    
    func testWordPair_ShouldJasonify() {
        let date = Date()
        
        
        
        let id = CKRecordID(recordName: "123")
        
        
        
        let wordPair = WordPair(pairId: id.recordName, word: "azul", definition: "blue", dateCreated: date, gender: .masculine, tags: [], example: "Ejemplo")
        
        let json = wordPair.toJson()
        
        let wp2 = WordPair(json: json)
        
        XCTAssertEqual(wp2.pairId, id.recordName)
        XCTAssertEqual(wp2.word, "azul")
        XCTAssertEqual(wp2.definition, "blue")
        XCTAssertEqual(wp2.dateCreated.description, date.description)
        XCTAssertEqual(wp2.gender, .masculine)
        XCTAssertEqual(wp2.example, "Ejemplo")
        
    }
    
    func testTagAssociation_ShouldJsonify(){
        let tagAss = TagAssociation(wordPairId: "123", tagId: "456")
        
        let json = tagAss.toJson()
        
        let ass2 = TagAssociation(json: json)
        
        XCTAssertEqual(ass2.wordPairId, "123")
        XCTAssertEqual(ass2.tagId, "456")
        
    }
    
    func testDataStore_ShouldJsonify() {
        var tags : [Tag] = []
        var wordPairs : [WordPair] = []
        var wpAss : [TagAssociation] = []
        
        tags.append(Tag(tagId: "1", name: "Noun"))
        tags.append(Tag(tagId: "2", name: "Verb"))
        tags.append(Tag(tagId: "3", name: "Adjective"))
        
        wordPairs.append(WordPair(pairId: "100", word: "Azul", definition: "Blue"))
        wordPairs.append(WordPair(pairId: "101", word: "Amarillo", definition: "Yellow"))
        wordPairs.append(WordPair(pairId: "102", word: "Clave", definition: "Nail"))
        
        wpAss.append(TagAssociation(wordPairId: wordPairs[0].pairId, tagId: tags[0].tagId))
        wpAss.append(TagAssociation(wordPairId: wordPairs[0].pairId, tagId: tags[2].tagId))
        
        wpAss.append(TagAssociation(wordPairId: wordPairs[1].pairId, tagId: tags[0].tagId))
        
        
        let dataStore = DataStore()
        dataStore.initialize(tags: tags, wordPairs: wordPairs, tagAssociations: wpAss)
        
        let json = dataStore.toJson()
        
        let ds2 = DataStore(json: json)
        
        XCTAssertEqual(ds2.tagDictionary.count, 3)
        XCTAssertEqual(ds2.wordPairDictionary.count, 3)
        XCTAssertEqual(ds2.tagAssociations.count, 3)
        
        //Couple of spot checks
        XCTAssertEqual(ds2.tagDictionary["2"]?.name, "Verb")
        XCTAssertEqual(ds2.tagDictionary["1"]?.count, 2)
        XCTAssertEqual(ds2.wordPairDictionary["102"]?.word, "Clave")
    }
    
    
}


