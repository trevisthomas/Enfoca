//
//  DemoWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class DemoWebService : WebService {
    
    internal func fetchWordPairs(wordStateFilter: WordStateFilter, tagFilter: [Tag], wordPairOrder: WordPairOrder, callback: @escaping ([WordPair]) -> ()) {
        
        print("Dummy fetch called")
        let d = Date()
        var list : [WordPair] = []
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "English", definition: "Espanol", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Black", definition: "Negro", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Tall", definition: "Alta", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "To Run", definition: "Correr", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Clean", definition: "Limpo", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Fat", definition: "Gordo", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Gustar", definition: "To Please", dateCreated: d))
        list.append(WordPair(creatorId: -1, pairId: "guid", word: "Llamar", definition: "To Call", dateCreated: d))
        callback(list)
        
    }

    func fetchUserTags(enfocaId : Int, callback : @escaping([Tag])->()){
        callback(makeTags(ownerId: enfocaId))
    }
    
    private func makeTags(ownerId : Int = 1) -> [Tag] {
        var tags: [Tag] = []
        tags.append(Tag(ownerId: ownerId, tagId: "123", name: "Noun"))
        tags.append(Tag(ownerId: ownerId, tagId: "124", name: "Verb"))
        tags.append(Tag(ownerId: ownerId, tagId: "125", name: "Phrase"))
        tags.append(Tag(ownerId: ownerId, tagId: "126", name: "Adverb"))
        tags.append(Tag(ownerId: ownerId, tagId: "127", name: "From Class #3"))
        return tags
    }
}
