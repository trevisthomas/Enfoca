//
//  TagFilterViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class TagFilterViewModel : NSObject, UITableViewDataSource, UITableViewDelegate {
    var localTempTagFilters : [TagFilter] = []
    var localTagDictionary : [Tag: Bool] = [:]
    private(set) var tagFilterDelegate : TagFilterDelegate!
    
    func configureFromDelegate(delegate : TagFilterDelegate){
        self.tagFilterDelegate = delegate
        localTempTagFilters = tagFilterDelegate.tagTuples
        for tagTuple in localTempTagFilters {
            localTagDictionary[tagTuple.0] = tagTuple.1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localTempTagFilters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagFilterCell")! as UITableViewCell

        let (tag, _) = localTempTagFilters[indexPath.row]
        cell.textLabel?.text = tag.name
        cell.detailTextLabel?.text = formatDetailText(tag.count)
        return cell
    }
    
    func formatDetailText(_ count : Int ) -> String {
        return "\(count) words tagged."
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("How am i not here?")
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        let tag = localTempTagFilters[indexPath.row].0
        localTagDictionary[tag] = true
        print(" :-( \(localTagDictionary[tag])")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag = localTempTagFilters[indexPath.row].0
        localTagDictionary[tag] = false
    }
    
    func applySelectedTagsToDelegate(){
        for i in 0 ..< tagFilterDelegate.tagTuples.count {
            let selected = localTagDictionary[tagFilterDelegate.tagTuples[i].0]!
            tagFilterDelegate.tagTuples[i].1 = selected
        }
    }
    
//    fileprivate func updateSelectedTagInDelegate(tag : Tag, selected : Bool){
//        for i in 0 ..< tagFilterDelegate.tagTuples.count {
//            //Dont allow duplicate tag names!
//            if (tagFilterDelegate.tagTuples[i].0.name == tag.name){
//                tagFilterDelegate.tagTuples[i].1 = selected
//            }
//        }
//    }
    
    func searchTagsFor(prefix: String){
        localTempTagFilters = []
        for tuple in tagFilterDelegate.tagTuples {
            if tuple.0.name.lowercased().hasPrefix(prefix.lowercased()) {
                localTempTagFilters.append(tuple)
            }
        }
    }
}
