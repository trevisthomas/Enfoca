//
//  Sequence+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == (Tag, Bool) {
    func compare(_ rhs : [(Tag, Bool)]) -> Bool{
        let array = self as! [(Tag, Bool)]
        
        if array.count != rhs.count {
            return false
        }
        
        for i in (0..<rhs.count) {
            
            let (tag, selected) = array[i]
            if tag.tagId == rhs[i].0.tagId && selected == rhs[i].1 {
                continue
            }
            return false
        }
        return true
    }
}