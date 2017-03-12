//
//  Tag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

public class Tag : Equatable, Hashable {
    /// The hash value.
    ///
    /// Hash values are not guaranteed to be equal across different executions of
    /// your program. Do not save hash values to use during a future execution.
    public var hashValue: Int

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Tag, rhs: Tag) -> Bool {
        //Was this a good idea? I am relying on this implementation in the TagFilter for adding new tags.
        //Ok, i'm trying to fix this now.
        return lhs.tagId == rhs.tagId
//        return lhs.name == rhs.name
    }

    private(set) var tagId : AnyHashable
    private(set) var name : String
    private(set) var wordPairs : [WordPair] = []
    var count : Int {
        return wordPairs.count
    }
    
    init (name: String){
        self.tagId = "notset"
        self.name = name
        self.hashValue = name.hashValue
    }
    
    init (tagId : AnyHashable, name: String){
        self.tagId = tagId
        self.name = name
        self.hashValue = name.hashValue
    }
    
    func addWordPair(_ wordPair: WordPair){
        wordPairs.append(wordPair)
    }
    
    func remove(wordPair : WordPair) -> WordPair? {
        guard let index = wordPairs.index(of: wordPair) else {
            return nil
        }
        return wordPairs.remove(at: index)
    }
}
