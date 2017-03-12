//
//  DataStore.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/24/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class DataStore {
    private(set) var tagDictionary : [AnyHashable : Tag] = [:]
    private(set) var wordPairDictionary : [AnyHashable :  WordPair] = [:]
    private(set) var tagAssociations : [TagAssociation] = []
    
    var countAssociations : Int {
        return tagAssociations.count
    }
    
    var countTags : Int {
        return tagDictionary.count
    }
    
    var countWordPairs : Int {
        return wordPairDictionary.count
    }
    
    func initialize(tags: [Tag], wordPairs: [WordPair], tagAssociations: [TagAssociation], progressObserver: ProgressObserver? = nil){
        
        let key : String = "DataStoreInit"
        
        progressObserver?.startProgress(ofType: key, message: "Initializing DataStore")
        
        self.tagDictionary = tags.reduce([AnyHashable : Tag]()) { (acc, tag) in
            var dict = acc // This shit show is because the seed dictionary isnt mutable
            dict[tag.tagId] = tag
            return dict
        }
        
        progressObserver?.updateProgress(ofType: key, message: "DataStore loaded \(tagDictionary.count) tags...")
        
        self.wordPairDictionary = wordPairs.reduce([AnyHashable : WordPair]()) { (acc, wordPair) in
            var dict = acc
            dict[wordPair.pairId] = wordPair
            return dict
        }
        
        progressObserver?.updateProgress(ofType: key, message: "DataStore loaded \(wordPairDictionary.count) words...")
        
        self.tagAssociations = tagAssociations
        
        tagAssociations.forEach { (tagAss:TagAssociation) in
            guard let wp = self.wordPairDictionary[tagAss.wordPairId] else {
                fatalError()
            }
            
            guard let t = self.tagDictionary[tagAss.tagId] else {
                fatalError()
            }
            
            t.addWordPair(wp)
            wp.addTag(t)
        }
        progressObserver?.updateProgress(ofType: key, message: "DataStore tagged \(tagAssociations.count) words...")
        
        progressObserver?.endProgress(ofType: key, message: "DataStore initialization complete.")
    }
    
    func findWordPair(withId wordPairId : AnyHashable) -> WordPair? {
        return wordPairDictionary[wordPairId]
    }
    
    func add(tag: Tag, wordPair: WordPair) -> TagAssociation {
        guard let tag = tagDictionary[tag.tagId], let wordPair = wordPairDictionary[wordPair.pairId] else {
            fatalError()
        }
        
        tag.addWordPair(wordPair)
        wordPair.addTag(tag)
        let tagAss = TagAssociation(wordPairId: wordPair.pairId, tagId: tag.tagId)
        tagAssociations.append(tagAss)
        return tagAss
    }
    
    func remove(tag: Tag, from wordPair: WordPair) -> TagAssociation? {
        guard let tag = tagDictionary[tag.tagId], let wordPair = wordPairDictionary[wordPair.pairId] else {
            fatalError()
        }
        
        guard let index = (tagAssociations.index { (ass:TagAssociation) -> Bool in
            return ass.tagId == tag.tagId && ass.wordPairId == wordPair.pairId
        }) else {
//          return nil
            fatalError()
        }
        
        let tagAss = tagAssociations.remove(at: index)
        
        _ = tag.remove(wordPair: wordPair)
        _ = wordPair.remove(tag: tag)
        
        return tagAss
    }
    
    func add(tag: Tag) {
        tagDictionary[tag.tagId] = tag
    }
    
    func add(wordPair : WordPair) {
        wordPairDictionary[wordPair.pairId] = wordPair
    }
    
    func containsWordPair(withWord: String) -> Bool{
        let matching = wordPairDictionary.values.filter { (wordPair:WordPair) -> Bool in
            return wordPair.word == withWord
        }
        return matching.count > 0
    }
    
    func containsTag(withName: String) -> Bool {
        let matching = tagDictionary.values.filter { (tag:Tag) -> Bool in
            return tag.name == withName
        }
        
        return matching.count > 0
    }
    
    func remove(wordPair: WordPair) {
        wordPairDictionary.removeValue(forKey: wordPair.pairId)
        tagAssociations = tagAssociations.filter { (tagAss: TagAssociation) -> Bool in
            let keep = tagAss.wordPairId != wordPair.pairId
            if !keep {
                let tag = tagDictionary[tagAss.tagId]
                _ = tag?.remove(wordPair: wordPair)
            }
            return keep
        }
    }
    
    func remove(tag: Tag){
        tagDictionary.removeValue(forKey: tag.tagId)
        tagAssociations = tagAssociations.filter { (tagAss: TagAssociation) -> Bool in
            let keep = tagAss.tagId != tag.tagId
            if !keep {
                let wp = wordPairDictionary[tagAss.wordPairId]
                _ = wp?.remove(tag: tag)
            }
            return keep
        }
    }
    
    func applyUpdate(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag]) -> (WordPair, [TagAssociation], [TagAssociation]) {
        
        //Notice that i am creating the new WP with the old tags! This is because the tag changes happen afterward
        let newWordPair = WordPair(pairId: oldWordPair.pairId, word: word, definition: definition, dateCreated: oldWordPair.dateCreated, gender: gender, tags: oldWordPair.tags, example: example)
        
        let oldTags = Set<Tag>(oldWordPair.tags)
        let newTags = Set<Tag>(tags)
        
        let tagsToAdd = newTags.subtracting(oldTags)
        let tagsToRemove = oldTags.subtracting(newTags)
        
        wordPairDictionary[oldWordPair.pairId] = newWordPair
        
        var removedAssociations : [TagAssociation] = []
        var addedAssociations : [TagAssociation] = []
        //Remove
        for tag in tagsToRemove {
            if let ass = remove(tag: tag, from: newWordPair){
                removedAssociations.append(ass)
            }
        }
        
        //Add
        for tag in tagsToAdd {
            let ass = add(tag: tag, wordPair: newWordPair)
            addedAssociations.append(ass)
        }
        
        return (newWordPair, addedAssociations, removedAssociations)
    }
    
    func applyUpdate(oldTag: Tag, name: String) -> Tag{
        let newTag = Tag(tagId: oldTag.tagId, name: name)
        
        let wordPairs = oldTag.wordPairs
        
        for wp in wordPairs {
            // I'm just using the remove/add methods to update the internal double linking structure with the new object
            // I'm not returning the assocations to the caller because they should be exactly the same
            _ = remove(tag: oldTag, from: wp)
        }
        
        tagDictionary[oldTag.tagId] = newTag
        
        for wp in wordPairs {
            _ = add(tag: newTag, wordPair: wp)
        }
        
        return newTag
    }
    
    private func search(value : String, useWordField: Bool = true, withTags tags : [Tag]? = nil) -> [WordPair]{
        
        let pattern : String
//        if value.characters.count > 0 && value.characters.count < 2 {
        if value.characters.count == 1 {
            pattern = "^\(value)"
        } else {
            pattern = value
        }
        
        let pairFilter : (WordPair) -> Bool
        if useWordField {
            pairFilter = { (wordPair:WordPair) -> Bool in
                
                return wordPair.word.range(of: pattern, options: [.regularExpression, .caseInsensitive], range: nil, locale: nil) != nil
//                return wordPair.word.lowercased().hasPrefix(pattern)
            }
        } else {
            pairFilter = { (wordPair:WordPair) -> Bool in
//                    return wordPair.definition.lowercased().hasPrefix(pattern)
                return wordPair.definition.range(of: pattern, options: [.regularExpression, .caseInsensitive], range: nil, locale: nil) != nil
            }
        }
        
        if let tags = tags, tags.count > 0 {
            
            let tagIds = tags.map({ (tag:Tag) -> AnyHashable in
                return tag.tagId
            })
            
            let filteredAssociations = tagAssociations.filter({ (tagAss:TagAssociation) -> Bool in
                return tagIds.contains(tagAss.tagId)
            })
            
            var wordPairs = Set<WordPair>()
            for ass in filteredAssociations {
                wordPairs.insert(wordPairDictionary[ass.wordPairId]!)
            }
            
            if(pattern == "") {
                return Array(wordPairs)
            } else {
                return wordPairs.filter(pairFilter)
            }
        } else {
            if(pattern == "") {
                return Array(wordPairDictionary.values)
            } else {
                return wordPairDictionary.values.filter(pairFilter)
            }
        }

        
    }
    
    func search(forWordsLike : String, withTags tags : [Tag]? = nil) -> [WordPair]{
        return search(value: forWordsLike, useWordField: true, withTags: tags)
    }
   
    func search(wordPairMatching pattern: String, order wordPairOrder: WordPairOrder, withTags tagFilter : [Tag]? = nil) -> [WordPair]{
        
        let wordPairs : [WordPair]
        switch wordPairOrder {
        case .definitionAsc, .definitionDesc:
            wordPairs = search(forDefinitionsLike: pattern, withTags: tagFilter)
        case .wordAsc, .wordDesc:
            wordPairs = search(forWordsLike: pattern, withTags: tagFilter)
        }
        
        var sortFunc : (WordPair, WordPair) -> Bool
        
        switch wordPairOrder {
        case .definitionAsc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.definition.localizedCaseInsensitiveCompare(wp2.definition).rawValue < 0
            }
        case .definitionDesc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.definition.localizedCaseInsensitiveCompare(wp2.definition).rawValue > 0
            }
        case .wordAsc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.word.localizedCaseInsensitiveCompare(wp2.word).rawValue < 0
            }
        case .wordDesc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.word.localizedCaseInsensitiveCompare(wp2.word).rawValue > 0
            }
        }
        
        let sorted = wordPairs.sorted(by: sortFunc)
     
        return sorted
    }
    
    func search(forDefinitionsLike : String, withTags tags : [Tag]? = nil) -> [WordPair]{
        return search(value: forDefinitionsLike, useWordField: false, withTags: tags)
    }
    
    func search(allWithTags: [Tag]) -> [WordPair] {
        return search(value: "", useWordField: false, withTags: allWithTags)
    }
    
    func search(forTagWithName: String) -> [Tag] {
        let pattern = forTagWithName.lowercased()
        return tagDictionary.values.reduce([], { (result:[Tag], tag: Tag) -> [Tag] in
            var accumulator = result
            if tag.name.lowercased().hasPrefix(pattern) {
                accumulator.append(tag)
            }
            return accumulator
        }).sorted(by: { (t1:Tag, t2:Tag) -> Bool in
            t1.name.lowercased() < t2.name.lowercased()
        })
    }
    
    func allTags() -> [Tag]{
        return tagDictionary.values.sorted(by: { (t1: Tag, t2: Tag) -> Bool in
            t1.name.lowercased() < t2.name.lowercased()
        })
    }
}
