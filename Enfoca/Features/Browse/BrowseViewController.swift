//
//  BrowseViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/27/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class BrowseViewController: UIViewController, WordStateFilterDelegate, TagFilterDelegate {
    internal func updated() {
        assertionFailure()
    }


    @IBOutlet weak var wordStateFilterButton: UIButton!
    @IBOutlet weak var tagFilterButton: UIButton!
    
    var currentWordStateFilter: WordStateFilter = .all {
        didSet{
            wordStateFilterButton.setTitle(currentWordStateFilter.rawValue, for: .normal)
        }
    }
    
    var authenticateionDelegate : AuthenticationDelegate!
    var tagTuples : [(Tag, Bool)] = []
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
                self.tagTuples = list.map({
                    (value: Tag) -> (Tag, Bool) in
                    return (value, false)
                })
            }
        }
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
    
}

extension BrowseViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        //Pretty sure this is only called on iphone.  This is to force iPhone to show this as a popover style modal instead of full screen.
        return UIModalPresentationStyle.none
    }
}
