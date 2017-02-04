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
        reloadWordPairs(callback)
        appDefaults.save()
    }
    
    private func reloadWordPairs(_ callback: (() -> ())? = nil){
        viewModel.fetchWordPairs(wordStateFilter: currentWordStateFilter, tagFilter: selectedTags, wordPairOrder : determineWordOrder(), callback: {
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
    @IBOutlet weak var addNewWordPairButton: UIButton!
    
   
    var appDefaults : ApplicationDefaults!
    var authenticateionDelegate : AuthenticationDelegate!
    var webService : WebService!
    var viewModel : BrowseViewModel!
    var tags: [Tag] = []
    var selectedTags: [Tag] = [] {
        didSet{
            appDefaults.selectedTags = selectedTags
        }
    }
   
    var currentWordStateFilter: WordStateFilter = .all {
        didSet{
            wordStateFilterButton.setTitle(currentWordStateFilter.rawValue, for: .normal)
            appDefaults.wordStateFilter = currentWordStateFilter
        }
    }
    
    var reverseWordPair : Bool {
        get{
            return viewModel.reverseWordPair
        }
        set {
            viewModel.reverseWordPair = newValue
            appDefaults.reverseWordPair = newValue
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
        appDefaults = getAppDelegate().applicationDefaults
        webService = getAppDelegate().webService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentWordStateFilter = appDefaults.wordStateFilter //Setting this before the webservice so that update doesnt get called twice.
        viewModel = tableView.delegate as! BrowseViewModel
        viewModel.delegate = self
        
        
        //Load the persons tags from the webservice and then apply any local default selections to them
        self.webService.fetchUserTags() {
            list in
            
            self.tags = list
            self.selectedTags = self.appDefaults.selectedTags
            
        }
        
        
        reverseWordPair = appDefaults.reverseWordPair
        viewModel.reverseWordPair = reverseWordPair
        reverseWordPairSegmentedControl.selectedSegmentIndex = reverseWordPair ? 1 : 0
        reloadWordPairs()
        
        wordPairSearchBar.backgroundImage = UIImage() //Ah ha!  This gits rid of that horible border!
        
        registerForKeyboardNotifications(NotificationCenter.default)

    }
    
    
    func registerForKeyboardNotifications(_ notificationCenter : NotificationCenter){
        notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
//    fileprivate func getSelectedFilterTags() -> [Tag] {
//        //lol
//        let tags = tagTuples.filter({(tag, selected) in
//            return selected}).map({
//                (tag, _) -> Tag in
//                return tag
//            })
//        return tags
//    }

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
            self.viewModel.animating = true
            self.tableView.reloadData() // you tried some ways of setting .animating back to false but they didn't always leave things in the right state
        })
    }
    @IBAction func addNewWordPairAction(_ sender: UIButton) {
        performSegue(withIdentifier: "PairEditorSegue", sender: nil)
    }
    
    func keyboardWillShow(_ notification : NSNotification) {
        guard let tap = view.gestureRecognizers?.first as? UITapGestureRecognizer else {
            fatalError() //required
        }
        tap.cancelsTouchesInView = true
    }
    
    func keyboardDidHide(_ notification : NSNotification) {
        guard let tap = view.gestureRecognizers?.first as? UITapGestureRecognizer else {
            fatalError() //required
        }
        tap.cancelsTouchesInView = false
    }
    
    @IBAction func dismissKeyboard(){
        self.wordPairSearchBar.endEditing(true)
    }
    
    @IBAction func performBackButtonAction(){
        _ = navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PairEditorSegue" {
            guard let pairEditorVC = segue.destination as? PairEditorViewController else { fatalError() }
            if let wordPair = sender as? WordPair {
                pairEditorVC.wordPair = wordPair
            }
            
            pairEditorVC.delegate = self
            return
        }
        
        
        guard let button = sender as? UIButton else{
            fatalError()
        }
        
        let vc = segue.destination
        
        if button == wordStateFilterButton {
            let wordFilterVC = vc as! WordStateFilterViewController
            wordFilterVC.wordStateFilterDelegate = self
        } else if button == tagFilterButton {
            let tagFilterVC = vc as! TagFilterViewController
            tagFilterVC.tagFilterDelegate = self
        }
        
        vc.modalPresentationStyle = UIModalPresentationStyle.popover
        let popover: UIPopoverPresentationController = vc.popoverPresentationController!
        popover.delegate = self
        popover.sourceRect = button.bounds //No clue why source view didnt do this.

    }
    
    
    
    //deprecated - Since i do a reload, this isnt needed.
//    private func applyWordPairOrder() {
//        for cell in tableView.visibleCells {
//            
//            guard let myCell = cell as? WordPairCell else {
//                fatalError()
//            }
//            
//            myCell.reverseWordPair = reverseWordPair
//        }
//    }
    
}

extension BrowseViewController : BrowseViewModelDelegate {
    func edit(wordPair: WordPair){
        performSegue(withIdentifier: "PairEditorSegue", sender: wordPair)
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
        viewModel.fetchWordPairs(wordStateFilter: currentWordStateFilter, tagFilter: selectedTags, wordPairOrder : determineWordOrder(), pattern: pattern, callback: {
            self.tableView.reloadData()
        })
    }
}

extension BrowseViewController : PairEditorDelegate {
    func added(wordPair: WordPair) {
        fatalError()
    }
    
    func updated(wordPair: WordPair) {
        fatalError()
    }
}
