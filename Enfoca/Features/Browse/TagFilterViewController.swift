//
//  TagFilterViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class TagFilterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tagSearchBar: UISearchBar!
    
    var tagFilterDelegate : TagFilterDelegate!
    var viewModel : TagFilterViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = tableView.dataSource as! TagFilterViewModel
        viewModel.configureFromDelegate(delegate: tagFilterDelegate)
        
        let tuples = tagFilterDelegate.tagTuples
        for index in (0..<tuples.count) {
            if tuples[index].1 {
                let path = IndexPath(row: index, section: 0)
                tableView.selectRow(at: path, animated: true, scrollPosition: .none)
            }
        }
        
        tagSearchBar.backgroundImage = UIImage() //Ah ha!  This gits rid of that horible border!
        
    }

    private func applyFilter(){
        //Clear out the delegates selecions
        let tuples = tagFilterDelegate.tagTuples
        for index in (0..<tuples.count) {
            tagFilterDelegate.tagTuples[index].1 = false
        }
        
        
//        guard let selected = self.tableView.indexPathsForSelectedRows else {
//            return
//        }
//        
//        let selectedRows = selected.map({
//            (value : IndexPath) -> Int in
//            return value.row
//        })
//        
//        //Apply selection
//        for value in selectedRows {
//             tagFilterDelegate.tagTuples[value].1 = true
//        }
        
        viewModel.applySelectedTagsToDelegate()
        
        tagFilterDelegate.updated(nil)
    }
    
    @IBAction func applyFilterAction(_ sender: Any) {
        applyFilter()
        
        //TODO, learn how to test
        self.dismiss(animated: true, completion: nil) //I dont know how to unit test this dismiss
    }

}

extension TagFilterViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTagsFor(prefix: searchText)
        tableView.reloadData()
    }
}
