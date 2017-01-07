//
//  BrowseViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/27/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController, WordStateFilterDelegate, TagFilterDelegate {
    func updated(_ callback: (() -> ())? = nil) {
        viewModel.fetchWordPairs(wordStateFilter: currentWordStateFilter, tagFilter: getSelectedFilterTags(),wordPairOrder : determineWordOrder(), callback: {
            //My assumption here is that if you give me a callback, that you will reload the table manually
            if let callback = callback {
                callback()
            } else {
                self.tableView.reloadData()
            }
        })
    }

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var wordStateFilterButton: UIButton!
    @IBOutlet weak var tagFilterButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reverseWordPairSegmentedControl: UISegmentedControl!
    @IBOutlet weak var wordPairSearchBar: UISearchBar!
    
   
    var appDefaultsDelegate : ApplicationDefaults!
    var authenticateionDelegate : AuthenticationDelegate!
    var tagTuples : [(Tag, Bool)] = []
    var webService : WebService!
    var viewModel : BrowseViewModel!
   
    var currentWordStateFilter: WordStateFilter = .all {
        didSet{
            wordStateFilterButton.setTitle(currentWordStateFilter.rawValue, for: .normal)
        }
    }
    
    var reverseWordPair : Bool {
        get{
            return viewModel.reverseWordPair
        }
        set {
            viewModel.reverseWordPair = newValue
        }
    }
    
    fileprivate func determineWordOrder() -> WordPairOrder{
        let wordPairOrder : WordPairOrder = (viewModel.reverseWordPair == true) ? .definitionAsc : .wordAsc
        return wordPairOrder
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        performInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        performInit()
    }
    
    private func performInit(){
        authenticateionDelegate = getAppDelegate()
        appDefaultsDelegate = getAppDelegate()
        webService = getAppDelegate().webService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentWordStateFilter = appDefaultsDelegate.initialWordStateFilter() //Setting this before the webservice so that update doesnt get called twice.
        viewModel = tableView.delegate as! BrowseViewModel
        viewModel.webService = webService
        
        
        
        if let enfocaId = authenticateionDelegate.currentUser()?.enfocaId {
            self.webService.fetchUserTags(enfocaId: enfocaId) {
                list in
                self.tagTuples = list.map({
                    (value: Tag) -> (Tag, Bool) in
                    return (value, false)
                })
            }
        }
        
        reverseWordPair = appDefaultsDelegate.reverseWordPair()
        viewModel.reverseWordPair = reverseWordPair
        reverseWordPairSegmentedControl.selectedSegmentIndex = reverseWordPair ? 1 : 0
        updated()
        
        wordPairSearchBar.backgroundImage = UIImage() //Ah ha!  This gits rid of that horible border!
        
//        //Looks for single or multiple taps.
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        
//        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        //tap.cancelsTouchesInView = false
//        
//        view.addGestureRecognizer(tap)
    }
    
    fileprivate func getSelectedFilterTags() -> [Tag] {
        //lol
        let tags = tagTuples.filter({(tag, selected) in
            return selected}).map({
                (tag, _) -> Tag in
                return tag
            })
        return tags
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func wordStateFilterAction(_ sender: UIButton) {
        performSegue(withIdentifier: "WordStateFilterSegue", sender: sender)
    }
    
    @IBAction func tagFilterAction(_ sender: UIButton) {
        performSegue(withIdentifier: "TagFilterSegue", sender: sender)
    }
    @IBAction func reverseWordPairSegmentAction(_ sender: UISegmentedControl) {
        switch (sender.selectedSegmentIndex){
            case 0:
                    reverseWordPair = false
            case 1:
                    reverseWordPair = true
            default:
                fatalError()
        }
        
        updated({
            self.applyWordPairOrder()
            self.tableView.reloadData()
        })
    }
    
    
    @IBAction func dismissKeyboard(){
        self.wordPairSearchBar.endEditing(true)
    }
    
    //NOT UNIT TESTED!
    @IBAction func performBackButtonAction(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIButton else{
            fatalError()
        }
        
        let vc = segue.destination
        
        if button == wordStateFilterButton {
            let wordFilterVC = vc as! WordStateFilterViewController
            wordFilterVC.wordStateFilterDelegate = self
        } else if button == tagFilterButton {
            let tagFilterNav = vc as! UINavigationController
            let tagFilterVC = tagFilterNav.viewControllers.first as! TagFilterViewController
            tagFilterVC.tagFilterDelegate = self
        }
        
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceRect = button.bounds //No clue why source view didnt do this.

        
    }
    
    private func applyWordPairOrder() {
        
        for cell in tableView.visibleCells {
            
            guard let myCell = cell as? WordPairCell else {
                fatalError()
            }
            
            myCell.reverseWordPair = reverseWordPair
        }
    }
    
}

extension BrowseViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //Pretty sure this is only called on iphone.  This is to force iPhone to show this as a popover style modal instead of full screen.
        return UIModalPresentationStyle.none
    }
}

extension BrowseViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        autoComplete(pattern: searchText)
    }
    
    private func autoComplete(pattern : String) {
        viewModel.fetchWordPairs(wordStateFilter: currentWordStateFilter, tagFilter: getSelectedFilterTags(),wordPairOrder : determineWordOrder(), pattern: pattern, callback: {
            self.tableView.reloadData()
        })
    }
}
