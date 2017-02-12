//
//  BrowserViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class BrowseViewModel : NSObject, UITableViewDelegate, UITableViewDataSource{

    var reverseWordPair : Bool!
    var animating: Bool = false
    var delegate: BrowseViewModelDelegate!
    var isFetchInProgress = false
    
    var currentWordPairOrder : WordPairOrder?
    var currentTagFilter: [Tag]?
    var currentPattern : String?
    
    
    var wordPairDictionary = [IndexPath : WordPairWrapper]()
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WordPairCell") as! WordPairCell
        
        guard let wordPair = wordPairDictionary[indexPath]?.wordPair else {
            cell.clear()
            cell.activityIndicator.startAnimating()
            
            fetchDataForIndexPath(path: indexPath)
            
            return cell
        }

        cell.activityIndicator.stopAnimating()
        cell.wordPair = wordPair
        cell.reverseWordPair = reverseWordPair
        
        cell.updateContentPositions(animate: animating)
        
        return cell
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordPairDictionary.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let wp = wordPairDictionary[indexPath]?.wordPair else {
            return //Do nothing if the row is loading
        }
        delegate.edit(wordPair: wp)
    }
    
    func fetchDataForIndexPath(path indexPath : IndexPath) {
        
        if isFetchInProgress {
            return
        }
        
        isFetchInProgress = true 
        delegate.webService.fetchWordPairs(tagFilter: currentTagFilter!, wordPairOrder: currentWordPairOrder!, pattern: currentPattern, callback: {
            newWordPairs in
            self.isFetchInProgress = false
            self.loadWordPairsIntoDictionary(newWordPairs)
        })

    }
    
    private func loadWordPairsIntoDictionary(_ wordPairs : [WordPair]){
        //TODO, find the right page!
        var index = 0
        
        //Find the first null wordpair in the dictionary.  Use that as the start index to load this data
        for i in 0..<wordPairDictionary.count {
            let indexPath = IndexPath(row: i, section: 0)
            let value = wordPairDictionary[indexPath]!
            if value.wordPair == nil {
                break
            }
            index += 1
        }
        
        var paths = [IndexPath]()
        for wordPair in wordPairs {
            let indexPath = IndexPath(row: index, section: 0)
            paths.append(indexPath)
            wordPairDictionary[indexPath]!.wordPair = wordPair //It *must* exist
            index += 1
        }
        
        delegate.reloadRows(withIndexPaths: paths)
        
    }

    func performWordPairFetch(tagFilter: [Tag], pattern : String? = nil, wordPairOrder order : WordPairOrder, callback completionHandler : @escaping ((Int) -> ())){
        
        currentPattern = pattern
        currentTagFilter = tagFilter
        currentWordPairOrder = order
        
        delegate.webService.wordPairCount(tagFilter: tagFilter, pattern: pattern) { (count: Int) in
            for i in 0..<count {
                let ip = IndexPath(item: i, section: 0)
                self.wordPairDictionary[ip] = WordPairWrapper()
            }
            
            completionHandler(count)
        }
    }
}

extension BrowseViewModel : PairEditorDelegate {
    func added(wordPair: WordPair) {
        var newDict = [IndexPath : WordPairWrapper]()
        newDict[IndexPath(row: 0, section: 0)] = WordPairWrapper(wordPair)
        
        //Re-adding the old word pairs with their new ip's
        var index = 1
        for (_, value) in wordPairDictionary {
            let ip = IndexPath(row: index, section: 0)
            newDict[ip] = value
            index += 1
        }
        
        wordPairDictionary = newDict
        
        delegate.reloadTable()
    }
    
    func updated(wordPair: WordPair) {
        for (ip, value) in wordPairDictionary {
            if value.wordPair == wordPair {
                wordPairDictionary[ip]?.wordPair = wordPair
                delegate.reloadRows(withIndexPaths: [ip])
                break
            }
        }
    }
    
}
