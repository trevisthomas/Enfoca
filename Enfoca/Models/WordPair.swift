//
//  WordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

struct WordPair {
    
    private(set) var creatorId: Int
    private(set) var pairId: String
    private(set) var word: String
    private(set) var definition: String
    private(set) var dateCreated: Date
    
    init (creatorId: Int, pairId: String, word: String, definition: String, dateCreated: Date ) {
        self.creatorId = creatorId
        self.pairId = pairId
        self.word = word
        self.definition = definition
        self.dateCreated = dateCreated
    }

}
