//
//  TagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

struct TagAssociation{
    private(set) var ownerId : Int
    private(set) var tag : Tag
    
    init (ownerId: Int, tag : Tag) {
        self.ownerId = ownerId
        self.tag = tag
    }
}
