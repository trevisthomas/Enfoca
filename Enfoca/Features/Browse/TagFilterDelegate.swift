//
//  TagFilterDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol TagFilterDelegate {
    func tagFilterUpdated(_ callback: (() -> ())?)
    var selectedTags : [Tag] {get set}
}
