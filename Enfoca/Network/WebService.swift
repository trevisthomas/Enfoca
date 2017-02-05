//
//  WebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol WebService {
    func fetchUserTags(callback : @escaping([Tag])->())
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair])->())

    func wordPairCount(tagFilter: [Tag], pattern : String?, callback : @escaping(Int)->())
    
    func activateWordPair(wordPair: WordPair, callback: ((Bool)->())? )
    func deactivateWordPair(wordPair: WordPair, callback: ((Bool)->())? )
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->());
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->());
    
    var showNetworkActivityIndicator : Bool {get set}
    
    
}
