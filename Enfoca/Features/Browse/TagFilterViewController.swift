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
        
        tagSearchBar.backgroundImage = UIImage() //Ah ha!  This gits rid of that horible border!
        
    }

    private func applyFilter(){
        //Clear out the delegates selecions
        let tuples = tagFilterDelegate.tagTuples
        for index in (0..<tuples.count) {
            tagFilterDelegate.tagTuples[index].1 = false
        }
        
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
