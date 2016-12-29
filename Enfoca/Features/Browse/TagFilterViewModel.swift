//
//  TagFilterViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class TagFilterViewModel : NSObject, UITableViewDataSource, UITableViewDelegate {
    var tagFilterDelegate : TagFilterDelegate!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tagFilterDelegate.tagTuples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagFilterCell")! as UITableViewCell

        let (tag, _) = tagFilterDelegate.tagTuples[indexPath.row]
        cell.textLabel?.text = tag.name
        cell.detailTextLabel?.text = formatDetailText(tag.count)
        return cell
    }
    
    func formatDetailText(_ count : Int ) -> String {
        return "\(count) words tagged."
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
//        tagFilterDelegate.tagTuples![indexPath.row].1 = !tagFilterDelegate.tagTuples![indexPath.row].1
    }
}
