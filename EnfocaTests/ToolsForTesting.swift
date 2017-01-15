//
//  ToolsForTesting.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation
import UIKit
@testable import Enfoca

func segues(ofViewController viewController: UIViewController) -> [String] {
    let identifiers = (viewController.value(forKey: "storyboardSegueTemplates") as? [AnyObject])?.flatMap({ $0.value(forKey: "identifier") as? String }) ?? []
    return identifiers
}

func makeTags(ownerId : Int = 1) -> [Tag] {
    var tags: [Tag] = []
    tags.append(Tag(ownerId: ownerId, tagId: "123", name: "Noun"))
    tags.append(Tag(ownerId: ownerId, tagId: "124", name: "Verb"))
    tags.append(Tag(ownerId: ownerId, tagId: "125", name: "Phrase"))
    tags.append(Tag(ownerId: ownerId, tagId: "126", name: "Adverb"))
    tags.append(Tag(ownerId: ownerId, tagId: "127", name: "From Class #3"))
    tags.append(Tag(ownerId: ownerId, tagId: "128", name: "Adjective"))
    return tags
}

func makeTagTuples(tags : [Tag] = makeTags())->[(Tag, Bool)] {
    let tagTuples : [(Tag, Bool)]
    tagTuples = tags.map({
        (value : Tag) -> (Tag, Bool) in
        return (value, false)
    })
    return tagTuples
}


func makeWordPairs() -> [WordPair]{
    let d = Date()
    var list : [WordPair] = []
    list.append(WordPair(creatorId: -1, pairId: "guid", word: "English", definition: "Espanol", dateCreated: d))
    list.append(WordPair(creatorId: -1, pairId: "guid", word: "Black", definition: "Negro", dateCreated: d))
    list.append(WordPair(creatorId: -1, pairId: "guid", word: "Tall", definition: "Alta", dateCreated: d))
    list.append(WordPair(creatorId: -1, pairId: "guid", word: "To Run", definition: "Correr", dateCreated: d))
    
    return list
}
