//
//  Tag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

public struct Tag : Equatable, Hashable {
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
//        return lhs.tagId == rhs.tagId
        return lhs.name == rhs.name
    }

    private(set) var tagId : String?
    private(set) var name : String
    private(set) var ownerId : Int?
    private(set) var count : Int
    
    init (name: String){
        self.tagId = nil
        self.name = name
        self.ownerId = nil
        self.count = 0
        self.hashValue = name.hashValue
    }
    
    init (ownerId : Int, tagId : String, name: String, count: Int = 0){
        self.tagId = tagId
        self.name = name
        self.ownerId = ownerId
        self.count = count
        self.hashValue = name.hashValue
    }
}
