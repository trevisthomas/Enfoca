//
//  BrowseViewModelDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

protocol BrowseViewModelDelegate {
    func edit(wordPair : WordPair)
    var webService : WebService! {get}
}
