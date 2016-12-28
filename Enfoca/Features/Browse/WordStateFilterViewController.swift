//
//  WordStateFilterViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/27/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class WordStateFilterViewController: UIViewController, WordStateFilterDelegate {
    
    var wordStateFilterDelegate : WordStateFilterDelegate!
    var currentWordStateFilter: WordStateFilter {
        set {
            self.dismiss(animated: true, completion: { _ in
                self.wordStateFilterDelegate.currentWordStateFilter = newValue
            })
        }
        get {
            return wordStateFilterDelegate.currentWordStateFilter
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let vm = tableView.delegate as? WordStateFilterViewModel {
            vm.delegate = self
        }
        
        if let _ = wordStateFilterDelegate {
            let indexPath = IndexPath(row: WordStateFilter.asArray().index(of: currentWordStateFilter)!, section: 0)
            
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
        }
        
        //let r = tableView.rect(forSection: 0)
        self.preferredContentSize = CGSize(width: 250, height: 200)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
