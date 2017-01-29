//
//  DemoWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class DemoWebService : WebService {
    private var list : [WordPair]
    private var order = WordPairOrder.wordAsc
    
    init () {
        
        let tags = DemoWebService.makeTags()
        
        let d = Date()
        list = []
        list.append(DemoWebService.makeWordPairWithTag(word: "blacksmith", definition: "herrero", tags: [tags[0], tags[2]]))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "English", definition: "Espanol", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Black", definition: "Negro", dateCreated: d))
        list.append(DemoWebService.makeWordPairWithTag(word: "Party", definition: "Fiesta", tags: [tags[0]]))
        list.append(DemoWebService.makeWordPairWithTag(word: "to forge", definition: "forjar", tags: [tags[3], tags[4]]))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Tall", definition: "Alta", dateCreated: d))
        
        
        list.append(DemoWebService.makeWordPairWithTag(word: "i got to speak with him", definition: "yo conseguí hablar con el", tags: [tags[0], tags[2], tags[3]]))
        
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "To Run", definition: "Correr", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Clean", definition: "Limpo", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Fat", definition: "Gordo", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "To Please", definition: "Gustar", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "To Call", definition: "Llamar", dateCreated: d))
    }
    
    internal func deactivateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
        if let callback = callback {
            callback(true)
        }
        print("Dummy de-activate called \(wordPair.word)")
    }

    
    internal func activateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
        if let callback = callback {
            callback(true)
        }
        print("Dummy activiate called \(wordPair.word)")
    }
    
    

    internal func fetchWordPairs(wordStateFilter: WordStateFilter, tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern: String? = nil, callback: @escaping ([WordPair]) -> ()) {
        
        let tagNames : [String] = tagFilter.map { (tag) -> String in
            return tag.name
        }
        
        print("Dummy fetch called with tags \(tagNames)")
        
        if wordPairOrder != self.order {
            order = wordPairOrder
            list.reverse()
        }
        
        callback(list)
        
    }
    
//    private class func makeWordPairWithTag(word: String, definition: String, tagNames : [String]) -> WordPair{
//        let wp = WordPair(creatorId: -1, pairId: "1-0-0-1", word: word, definition: definition, dateCreated: Date())
//        for name in tagNames{
//            wp.tags.append(Tag(ownerId: -1, tagId: "nothing", name: name))
//        }
//        return wp
//    }
    
    private class func makeWordPairWithTag(word: String, definition: String, tags : [Tag]) -> WordPair{
        let wp = WordPair(creatorId: -1, pairId: "1-0-0-1", word: word, definition: definition, dateCreated: Date(), tags : tags)
        return wp
    }

    func fetchUserTags(callback : @escaping([Tag])->()){
        callback(DemoWebService.makeTags())
    }
    
    private class func makeTags(ownerId : Int = 1) -> [Tag] {
        var tags: [Tag] = []
        tags.append(Tag(ownerId: ownerId, tagId: "123", name: "Noun"))
        tags.append(Tag(ownerId: ownerId, tagId: "124", name: "Verb"))
        tags.append(Tag(ownerId: ownerId, tagId: "125", name: "Phrase"))
        tags.append(Tag(ownerId: ownerId, tagId: "126", name: "Adverb"))
        tags.append(Tag(ownerId: ownerId, tagId: "127", name: "From Class #3"))
        return tags
    }
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String? = nil, callback : @escaping(WordPair?, EnfocaError?)->()) {
        
        
        let wp = WordPair(creatorId: -1, pairId: "none", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(wp, nil)
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String? = nil, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()) {
        
        
        let wp = WordPair(creatorId: -1, pairId: "none", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(wp, nil)
    }
}
