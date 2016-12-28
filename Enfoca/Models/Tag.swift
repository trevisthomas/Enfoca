//
//  Tag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

public struct Tag : Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: Tag, rhs: Tag) -> Bool {
        return lhs.tagId == rhs.tagId
    }

    private(set) var tagId : String
    private(set) var name : String
    private(set) var ownerId : Int
    private(set) var count : Int
    
    
    init (ownerId : Int, tagId : String, name: String, count: Int = 0){
        self.tagId = tagId
        self.name = name
        self.ownerId = ownerId
        self.count = count
    }
}
