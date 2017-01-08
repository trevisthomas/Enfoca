//
//  ApplicationDefaults.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol ApplicationDefaults {
    var wordStateFilter : WordStateFilter {get set}
    var reverseWordPair : Bool {get set}
    var tagFilters : [tagFilter] {get set}
    func save()
}

class LocalApplicationDefaults : ApplicationDefaults {
    var tagFilters : [(Tag, Bool)] = []
    var reverseWordPair : Bool = false
    var wordStateFilter : WordStateFilter = .all
    
    func save(){
        //Nothing yet.
    }
}
