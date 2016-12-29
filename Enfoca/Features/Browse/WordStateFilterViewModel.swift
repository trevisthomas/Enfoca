//
//  WordStateFilterViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class WordStateFilterViewModel : NSObject, UITableViewDataSource, UITableViewDelegate {
    var delegate : WordStateFilterDelegate!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordStateFilterCell")! as UITableViewCell
        cell.textLabel?.text = WordStateFilter.asArray()[indexPath.row].rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate.currentWordStateFilter = WordStateFilter.asArray()[indexPath.row]
    }
}

