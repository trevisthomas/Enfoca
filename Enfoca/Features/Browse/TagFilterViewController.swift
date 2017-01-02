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
    var tagFilterDelegate : TagFilterDelegate!
//    var tagTuples : [(Tag, Bool)]? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let viewModel = tableView.dataSource as! TagFilterViewModel
        viewModel.tagFilterDelegate = tagFilterDelegate
        
        let tuples = tagFilterDelegate.tagTuples
            for index in (0..<tuples.count) {
                if tuples[index].1 {
                    let path = IndexPath(row: index, section: 0)
                        tableView.selectRow(at: path, animated: true, scrollPosition: .none)
                }
            }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func applyFilter(){
        
        let tuples = tagFilterDelegate.tagTuples
        for index in (0..<tuples.count) {
            tagFilterDelegate.tagTuples[index].1 = false
        }
        
        guard let selected = self.tableView.indexPathsForSelectedRows else {
            return
        }
        
        let selectedRows = selected.map({
            (value : IndexPath) -> Int in
            return value.row
        })
        
        //Apply selection
        for value in selectedRows {
             tagFilterDelegate.tagTuples[value].1 = true
        }
        
        tagFilterDelegate.updated(nil)
    }
    
    @IBAction func applyFilterAction(_ sender: Any) {
        applyFilter()
        
        //TODO, learn how to test
        self.dismiss(animated: true, completion: nil) //I dont know how to unit test this dismiss
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
