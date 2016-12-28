//
//  BrowseViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/27/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController, WordStateFilterDelegate {

    @IBOutlet weak var wordStateFilterButton: UIButton!
    @IBOutlet weak var tagFilterButton: UIButton!
    
    var currentWordStateFilter: WordStateFilter = .all {
        didSet{
//            if wordStateFilterButton != nil { //Some unit tests havent wired up.
                wordStateFilterButton.setTitle(currentWordStateFilter.rawValue, for: .normal)
//            }
        }
    }
    
    var authenticateionDelegate : AuthenticationDelegate!
    var tagTuples : [(Tag, Bool)]!
    var webService : WebService!
    
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
        webService = getAppDelegate().webService
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentWordStateFilter = .all
        
        
        if let enfocaId = authenticateionDelegate.currentUser()?.enfocaId {
            self.webService.fetchUserTags(enfocaId: enfocaId) {
                list in
                print(list)
                self.populateTags(tags: list)
            }
        }
        
        
        // Do any additional setup after loading the view.
    }

    private func populateTags(tags : [Tag]){
//        tagTuples = tags.map({$0, false})
//        
//        {
//            (value: Double) -> Double in
//            return value * value
//        }
        
        tagTuples = tags.map({
            (value: Tag) -> (Tag, Bool) in
            return (value, false)
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func wordStateFilterAction(_ sender: UIButton) {
        performSegue(withIdentifier: "WordStateFilterSegue", sender: sender)
    }
    
    @IBAction func tagFilterAction(_ sender: UIButton) {
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let button = sender as? UIButton else{
            fatalError()
        }
        
        if button == wordStateFilterButton {
            let wordFilterVC = segue.destination as! WordStateFilterViewController
            wordFilterVC.wordStateFilterDelegate = self
            
            wordFilterVC.modalPresentationStyle = UIModalPresentationStyle.popover
            let popover: UIPopoverPresentationController = wordFilterVC.popoverPresentationController!
            popover.delegate = self
            popover.sourceRect = button.bounds //No clue why source view didnt do this.
            
//            wordFilterVC.preferredContentSize = CGSize(width: 200, height: 300)
            
        }
        
        
    }
    

}

extension BrowseViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //Pretty sure this is only called on iphone.  This is to force iPhone to show this as a popover style modal instead of full screen.
        return UIModalPresentationStyle.none
    }
}
