//
//  BrowserViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class BrowseViewModel : NSObject, UITableViewDelegate, UITableViewDataSource{
    var wordPairs : [WordPair] = []
    var reverseWordPair : Bool!
    var animating: Bool = false
    var delegate: BrowseViewModelDelegate!
    
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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wp = wordPairs[indexPath.row]
        delegate.edit(wordPair: wp)
    }
    
    func performWordPairFetch(tagFilter: [Tag], pattern : String, wordPairOrder order : WordPairOrder, callback completionHandler : ((Int) -> ())? = nil ) {
        
        delegate.webService.fetchWordPairs(tagFilter: tagFilter, wordPairOrder: order, pattern: pattern, callback: {
            newWordPairs, error in
            guard let newWordPairs = newWordPairs else {
                self.delegate.onError(error: error)
                return
            }
            self.wordPairs = newWordPairs
            if let completionHandler = completionHandler {
                completionHandler(self.wordPairs.count)
            }
        })
        
    }
}

extension BrowseViewModel : PairEditorDelegate {
    func added(wordPair: WordPair) {
        wordPairs.insert(wordPair, at: 0)
        delegate.reloadTable()
    }
    
    func updated(wordPair: WordPair) {
        
        if let index = wordPairs.index(of: wordPair) {
            let ip = IndexPath(row: index, section: 0)
            wordPairs[index] = wordPair
            delegate.reloadRows(withIndexPaths: [ip])
        }
        
    }
    
}
