//
//  DemoWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class DemoWebService : WebService {
    internal func createTag(tagValue: String, callback: @escaping (Tag?, EnfocaError?) -> ()) {
        
        delay(1) {
            let t = Tag(ownerId: -1, tagId: "eyedee", name: tagValue)
            
            print("Dummy create tag \(tagValue)")
            
            callback(t, nil)
        }

    }

  
    var showNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }

    private var list : [WordPair]
    private var order = WordPairOrder.wordAsc
    
    private static var guidIndex = 0
    
    class func nextIndex() -> Int{
        guidIndex += 1
        return guidIndex
    }
    
    init () {
        
        let tags = DemoWebService.makeTags()
        
        let d = Date()
        list = []
        list.append(DemoWebService.makeWordPairWithTag(word: "blacksmith", definition: "herrero", tags: [tags[0], tags[2]]))
        list.append(WordPair(creatorId: -1, pairId: "guid\(DemoWebService.nextIndex())", word: "English", definition: "Espanol", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid\(DemoWebService.nextIndex()))", word: "Black", definition: "Negro", dateCreated: d))
//        list.append(DemoWebService.makeWordPairWithTag(word: "Party", definition: "Fiesta", tags: [tags[0]]))
//        list.append(DemoWebService.makeWordPairWithTag(word: "to forge", definition: "forjar", tags: [tags[3], tags[4]]))
//        list.append(WordPair(creatorId: -1, pairId: "guid\(DemoWebService.nextIndex()))", word: "Tall", definition: "Alta", dateCreated: d))
//        
        
//        list.append(DemoWebService.makeWordPairWithTag(word: "i got to speak with him", definition: "yo conseguí hablar con el", tags: [tags[0], tags[2], tags[3]]))
//        
//        list.append(DemoWebService.makeWordPair( word: "To Run", definition: "Correr"))
//        list.append(DemoWebService.makeWordPair( word: "Clean", definition: "Limpo"))
//        list.append(DemoWebService.makeWordPair( word: "Fat", definition: "Gordo"))
//        list.append(DemoWebService.makeWordPair( word: "To Please", definition: "Gustar"))
//        list.append(DemoWebService.makeWordPair( word: "To Call", definition: "Llamar"))
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
    
    
    internal func wordPairCount(tagFilter: [Tag], pattern: String?, callback: @escaping (Int) -> ()) {
        callback(list.count)
    }
    
    internal func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern: String? = nil, callback: @escaping ([WordPair]) -> ()) {
        
        delay(1) {
            let tagNames : [String] = tagFilter.map { (tag) -> String in
                return tag.name
            }
            
            print("Dummy fetch called with tags \(tagNames)")
            
            if wordPairOrder != self.order {
                self.order = wordPairOrder
                self.list.reverse()
            }
            
            callback(self.list)
        }
    }
    

    private class func makeWordPairWithTag(word: String, definition: String, tags : [Tag]) -> WordPair{
        let wp = WordPair(creatorId: -1, pairId: "1-0-0-1\(nextIndex())", word: word, definition: definition, dateCreated: Date(), tags : tags)
        return wp
    }
    
    private class func makeWordPair(word: String, definition: String) -> WordPair{
        return WordPair(creatorId: -1, pairId: "1-0-0-1\(nextIndex())", word: word, definition: definition, dateCreated: Date())
    }

    func fetchUserTags(callback : @escaping([Tag])->()){
        delay(1){
             callback(DemoWebService.makeTags())
        }
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
        
        print("Created \(word) : \(definition) with tags \(tags.tagsToText())")
        let wp = WordPair(creatorId: -1, pairId: "1-0-0-1\(DemoWebService.nextIndex())", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(wp, nil)
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String? = nil, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()) {
        
        print("Updated \(word) : \(definition) with tags \(tags.tagsToText())")
        
        let wp = WordPair(creatorId: oldWordPair.creatorId, pairId: oldWordPair.pairId, word: word, definition: definition, dateCreated: oldWordPair.dateCreated, gender: gender, tags: tags, example: example)
        callback(wp, nil)
    }
    
    private func delay(_ seconds : Int, callback : @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + .seconds(seconds)) {
            callback()
        }
    }
}
