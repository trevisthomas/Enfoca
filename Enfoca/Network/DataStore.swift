//
//  DataStore.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/24/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class DataStore {
    private(set) var tags : [AnyHashable : Tag] = [:]
    private(set) var wordPairs : [AnyHashable :  WordPair] = [:]
    private(set) var tagAssociations : [TagAssociation] = []
    
    var countAssociations : Int {
        return tagAssociations.count
    }
    
    var countTags : Int {
        return tags.count
    }
    
    var countWordPairs : Int {
        return wordPairs.count
    }
    
    func initialize(tags: [Tag], wordPairs: [WordPair], tagAssociations: [TagAssociation]){
        
        self.tags = tags.reduce([AnyHashable : Tag]()) { (acc, tag) in
            var dict = acc // This shit show is because the seed dictionary isnt mutable
            dict[tag.tagId] = tag
            return dict
        }
        
        self.wordPairs = wordPairs.reduce([AnyHashable : WordPair]()) { (acc, wordPair) in
            var dict = acc
            dict[wordPair.pairId] = wordPair
            return dict
        }
        
        self.tagAssociations = tagAssociations
        
        tagAssociations.forEach { (tagAss:TagAssociation) in
            guard let wp = self.wordPairs[tagAss.wordPairId] else {
                fatalError()
            }
            
            guard let t = self.tags[tagAss.tagId] else {
                fatalError()
            }
            
            t.addWordPair(wp)
            wp.addTag(t)
        }
    }
    
    func findWordPair(withId wordPairId : AnyHashable) -> WordPair? {
        return wordPairs[wordPairId]
    }
    
    func createTagAssociation(tag: Tag, wordPair: WordPair) -> TagAssociation {
        guard let tag = tags[tag.tagId], let wordPair = wordPairs[wordPair.pairId] else {
            fatalError()
        }
        
        tag.addWordPair(wordPair)
        wordPair.addTag(tag)
        let tagAss = TagAssociation(wordPairId: wordPair.pairId, tagId: tag.tagId)
        tagAssociations.append(tagAss)
        return tagAss
    }
    
    func remove(tag: Tag, from wordPair: WordPair) -> TagAssociation? {
        guard let tag = tags[tag.tagId], let wordPair = wordPairs[wordPair.pairId] else {
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
        
        
        tags.removeValue(forKey: tagAss.tagId)
        wordPairs.removeValue(forKey: tagAss.wordPairId)
        
        
        
        return tagAss
    }
    
}
