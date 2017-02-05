//
//  ApplicationDefaults.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol ApplicationDefaults {
    var reverseWordPair : Bool {get set}
    var selectedTags : [Tag] {get set}
    func save()
}

class LocalApplicationDefaults : ApplicationDefaults {
    var selectedTags : [Tag] = []
    var reverseWordPair : Bool = false
    
    func save(){
        //Nothing yet.
    }
}
