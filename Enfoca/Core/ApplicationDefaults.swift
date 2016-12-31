//
//  ApplicationDefaults.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol ApplicationDefaults {
    func initialWordStateFilter() -> WordStateFilter
    func reverseWordPair() -> Bool
    
}
