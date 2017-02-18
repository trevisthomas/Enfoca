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
    @IBOutlet weak var tagSummaryLabel: UILabel!
    @IBOutlet weak var editDoneButton: UIButton!
    @IBOutlet weak var applyButton: UIButton!
    
    var tagFilterDelegate : TagFilterDelegate!
    var viewModel : TagFilterViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        tagSearchBar.backgroundImage = UIImage() //Ah ha!  This gits rid of that horible border!
        
        viewModel = tableView.dataSource as! TagFilterViewModel
        viewModel.tagFilterViewModelDelegate = self
        
        //Trevis, the below is a blocking call.  Refactor for completion callback.
        viewModel.configureFromDelegate(delegate: tagFilterDelegate){
            self.updateSelectedSummary()
            self.tableView.reloadData() // Not unit tested :-(
        }
        
    }

    private func applyFilter(){
        //Clear out the delegates selecions
        tagFilterDelegate.selectedTags = []
        
        viewModel.applySelectedTagsToDelegate()
        
        tagFilterDelegate.tagFilterUpdated(nil)
    }
    
    @IBAction func applyFilterAction(_ sender: UIButton) {
        applyFilter()
        
        //TODO, learn how to test
        self.dismiss(animated: true, completion: nil) //I dont know how to unit test this dismiss
    }
    
    fileprivate func updateSelectedSummary(){
        let selected = viewModel.getSelectedTags()
        
        guard selected.count > 0 else {
            tagSummaryLabel.text = "Selected: (none)"
            return
        }
        tagSummaryLabel.text = "Selected: \(selected.tagsToText())"
    }

    var selectedPaths : [IndexPath] = []
    @IBAction func editDoneButtonAction(_ sender: Any) {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editDoneButton.setTitle("Edit", for: .normal)
            for path in selectedPaths {
                tableView.selectRow(at: path, animated: false, scrollPosition: .none)
            }
        } else {
            editDoneButton.setTitle("Done", for: .normal)
            if let paths = tableView.indexPathsForSelectedRows {
                selectedPaths = paths
            }
            tableView.setEditing(true, animated: true)
        }
    }
    
}

extension TagFilterViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchTagsFor(prefix: searchText)
        tableView.reloadData()
    }
}

extension TagFilterViewController : TagFilterViewModelDelegate{
    func selectedTagsChanged() {
        updateSelectedSummary()
    }
    
    func reloadTable() {
        tagSearchBar.text = nil
        tableView.reloadData()
    }
    
    func alert(title: String, message: String) {
        presentAlert(title: title, message : message)
    }
}
