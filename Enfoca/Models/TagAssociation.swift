//
//  TagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

struct TagAssociation{
    private(set) var wordPairId : AnyHashable
    private(set) var tagId : AnyHashable
    
    init (wordPairId: AnyHashable, tagId : AnyHashable) {
        self.wordPairId = wordPairId
        self.tagId = tagId
    }
}
