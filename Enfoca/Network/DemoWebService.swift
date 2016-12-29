//
//  DemoWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class DemoWebService : WebService {
    func fetchUserTags(enfocaId : Int, callback : @escaping([Tag])->()){
        callback(makeTags(ownerId: enfocaId))
    }
    
    private func makeTags(ownerId : Int = 1) -> [Tag] {
        var tags: [Tag] = []
        tags.append(Tag(ownerId: ownerId, tagId: "123", name: "Noun"))
        tags.append(Tag(ownerId: ownerId, tagId: "124", name: "Verb"))
        tags.append(Tag(ownerId: ownerId, tagId: "125", name: "Phrase"))
        tags.append(Tag(ownerId: ownerId, tagId: "126", name: "Adverb"))
        tags.append(Tag(ownerId: ownerId, tagId: "127", name: "From Class #3"))
        return tags
    }
}
