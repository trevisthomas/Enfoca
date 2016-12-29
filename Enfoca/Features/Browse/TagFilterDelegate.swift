//
//  TagFilterDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol TagFilterDelegate {
    var tagTuples : [(Tag, Bool)] {get set}
    func updated()
}
