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
    var callbackWhenChanged : (() -> ())?
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagFilterCell")! as! TagCell

        let (tag, _) = localTempTagFilters[indexPath.row]
        cell.tagTitleLabel?.text = tag.name
        cell.tagSubtitleLabel?.text = formatDetailText(tag.count)
        let selected : Bool = localTagDictionary[tag]!
        
        if selected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }

        return cell
    }
    
    func formatDetailText(_ count : Int ) -> String {
        return "\(count) words tagged."
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        let tag = localTempTagFilters[indexPath.row].0
        localTagDictionary[tag] = true
        callbackWhenChanged?()
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tag = localTempTagFilters[indexPath.row].0
        localTagDictionary[tag] = false
        callbackWhenChanged?()
    }
    
    func applySelectedTagsToDelegate(){
        for i in 0 ..< tagFilterDelegate.tagTuples.count {
            let selected = localTagDictionary[tagFilterDelegate.tagTuples[i].0]!
            tagFilterDelegate.tagTuples[i].1 = selected
        }
    }
    
    func searchTagsFor(prefix: String){
        localTempTagFilters = []
        for tuple in tagFilterDelegate.tagTuples {
            if tuple.0.name.lowercased().hasPrefix(prefix.lowercased()) {
                localTempTagFilters.append(tuple)
            }
        }
    }
    
    func getSelectedTags() -> [Tag] {
        var tags : [Tag] = []
        for (tag, selected) in localTagDictionary {
            if (selected) {
                tags.append(tag)
            }
        }
        return tags
    }
    
    func observeChanges(callback : @escaping () ->()) {
        callbackWhenChanged = callback
    }
    
    func deselectAll(){
        for (tag, _) in localTagDictionary {
            localTagDictionary[tag] = false
        }
        callbackWhenChanged?()
    }
    
}
