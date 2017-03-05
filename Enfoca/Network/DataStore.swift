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
    
    func initialize(tags: [Tag], wordPairs: [WordPair], tagAssociations: [TagAssociation]){
        
        self.tagDictionary = tags.reduce([AnyHashable : Tag]()) { (acc, tag) in
            var dict = acc // This shit show is because the seed dictionary isnt mutable
            dict[tag.tagId] = tag
            return dict
        }
        
        self.wordPairDictionary = wordPairs.reduce([AnyHashable : WordPair]()) { (acc, wordPair) in
            var dict = acc
            dict[wordPair.pairId] = wordPair
            return dict
        }
        
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
        
        let pattern = value.lowercased()
        
        let pairFilter : (WordPair) -> Bool
        if useWordField {
            pairFilter = { (wordPair:WordPair) -> Bool in
                return wordPair.word.lowercased().hasPrefix(pattern)
            }
        } else {
            pairFilter = { (wordPair:WordPair) -> Bool in
                    return wordPair.definition.lowercased().hasPrefix(pattern)
            }
        }
        
        if let tags = tags {
            
            let tagIds = tags.map({ (tag:Tag) -> AnyHashable in
                return tag.tagId
            })
            
            let filteredAssociations = tagAssociations.filter({ (tagAss:TagAssociation) -> Bool in
                return tagIds.contains(tagAss.tagId)
            })
            
            let filteredPairIds = filteredAssociations.map({ (tagAss:TagAssociation) -> AnyHashable in
                return tagAss.wordPairId
            })
            
            let wordPairs = wordPairDictionary.reduce([], { (result:[WordPair], entry: (key: AnyHashable, value: WordPair)) -> [WordPair] in
                
                var accumulator = result
                if(filteredPairIds.contains(entry.key)){
                    accumulator.append(entry.value)
                }
                
                return accumulator
                
            })
            
            if(pattern == "") {
                return wordPairs
            } else {
                return wordPairs.filter(pairFilter)
            }
        } else {
            return wordPairDictionary.values.filter(pairFilter)
        }

        
    }
    
    func search(forWordsLike : String, withTags tags : [Tag]? = nil) -> [WordPair]{
        return search(value: forWordsLike, useWordField: true, withTags: tags)
//        let pattern = forWordsLike.lowercased()
//        
//        
//        if let tags = tags {
//            
//            let tagIds = tags.map({ (tag:Tag) -> AnyHashable in
//                return tag.tagId
//            })
//            
//            let filteredAssociations = tagAssociations.filter({ (tagAss:TagAssociation) -> Bool in
//                return tagIds.contains(tagAss.tagId)
//            })
//            
//            let filteredPairIds = filteredAssociations.map({ (tagAss:TagAssociation) -> AnyHashable in
//                return tagAss.wordPairId
//            })
//            
//            let wordPairs = wordPairDictionary.reduce([], { (result:[WordPair], entry: (key: AnyHashable, value: WordPair)) -> [WordPair] in
//                
//                var accumulator = result
//                if(filteredPairIds.contains(entry.key)){
//                    accumulator.append(entry.value)
//                }
//                
//                return accumulator
//                
//            })
//            
//            if(pattern == "") {
//                return wordPairs
//            } else {
//                return wordPairs.filter({ (wordPair:WordPair) -> Bool in
//                    return wordPair.word.lowercased().hasPrefix(pattern)
//                })
//            }
//        } else {
//            return wordPairDictionary.values.filter({ (wordPair:WordPair) -> Bool in
//                return wordPair.word.lowercased().hasPrefix(pattern)
//            })
//        }
        
        
    }
   
    
    func search(forDefinitionsLike : String, withTags tags : [Tag]? = nil) -> [WordPair]{
        return search(value: forDefinitionsLike, useWordField: false, withTags: tags)
    }
    
    func search(allWithTags: [Tag]) -> [WordPair] {
        return search(value: "", useWordField: false, withTags: allWithTags)
    }
    
    func search(tagWithName: String) -> [Tag] {
        let pattern = tagWithName.lowercased()
        return tagDictionary.values.reduce([], { (result:[Tag], tag: Tag) -> [Tag] in
            var accumulator = result
            if tag.name.lowercased().hasPrefix(pattern) {
                accumulator.append(tag)
            }
            return accumulator
        })
    }
}
