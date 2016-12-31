//
//  WebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol WebService {
    func fetchUserTags(enfocaId : Int, callback : @escaping([Tag])->())
//    func fetchWordPairs(userId : String, callback : @escaping([WordPair])->())
}
