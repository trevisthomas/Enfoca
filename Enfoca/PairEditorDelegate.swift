//
//  PairEditorDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/28/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

protocol PairEditorDelegate {
    func updated(wordPair : WordPair)
    func added(wordPair: WordPair)
}
