//
//  WordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class WordPair : Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: WordPair, rhs: WordPair) -> Bool {
        return lhs.pairId == rhs.pairId
    }

    
    private(set) var creatorId: Int
    private(set) var pairId: String
    private(set) var word: String
    private(set) var definition: String
    private(set) var dateCreated: Date
    
    private(set) var tags : [Tag] = []
    var active : Bool
    
//    private String word;
//    private String definition;
//    private Date createDate = new Date();
//    private Date lastUpdate = new Date();
//    private long testedCount;
//    private long correctCount;
//    private long incorrectCount;
//    private double difficulty;
//    private String id;
//    private String user;
//    private long displayOrder;
//    private List<Tag> tags = new ArrayList<>();
//    private boolean active = false;
//    private boolean deleteAllowed;
//    private long averageTime;
//    private String example;
//    
//    private double confidence;
//    private long totalTime;
//    private long timedViewCount;
    
    init (creatorId: Int, pairId: String, word: String, definition: String, dateCreated: Date, active : Bool = false, tags : [Tag] = []) {
        self.creatorId = creatorId
        self.pairId = pairId
        self.word = word
        self.definition = definition
        self.dateCreated = dateCreated
        self.active = active
        self.tags = tags
    }

}
