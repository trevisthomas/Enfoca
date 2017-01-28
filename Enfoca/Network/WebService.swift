//
//  WebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol WebService {
//    typealias <#type name#> = <#type expression#>
    
    //TODO, remove the enfocaId from this.  The service should know who you are.
    func fetchUserTags(callback : @escaping([Tag])->())
    func fetchWordPairs(wordStateFilter: WordStateFilter, tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair])->())
    func activateWordPair(wordPair: WordPair, callback: ((Bool)->())? )
    func deactivateWordPair(wordPair: WordPair, callback: ((Bool)->())? )
    
    func createWordPair(word: String, definition: String, tags : [Tag], callback : @escaping(WordPair)->());
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, tags : [Tag], callback :
        @escaping(WordPair)->());
}
