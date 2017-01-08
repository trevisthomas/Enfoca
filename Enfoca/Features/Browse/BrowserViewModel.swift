//
//  BrowserViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class BrowseViewModel : NSObject, UITableViewDelegate, UITableViewDataSource{
    var webService : WebService!
    var wordPairs : [WordPair] = []
    var reverseWordPair : Bool!
    var animating: Bool = false
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordPairCell") as! WordPairCell
        cell.wordPair = wordPairs[indexPath.row]
        cell.reverseWordPair = reverseWordPair
        
        cell.updateContentPositions(animate: animating)
        
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordPairs.count
    }

    func fetchWordPairs(wordStateFilter: WordStateFilter, tagFilter: [Tag], wordPairOrder order : WordPairOrder, pattern : String? = nil, callback completionHandler : (() -> ())? = nil ) {
        webService.fetchWordPairs(wordStateFilter: wordStateFilter, tagFilter: tagFilter, wordPairOrder: order, pattern: pattern, callback: {
            newWordPairs in
            self.wordPairs = newWordPairs
            if let completionHandler = completionHandler {
                completionHandler()
            }
        })
    }
}
