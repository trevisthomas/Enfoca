//
//  WelcomeViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    
    @IBOutlet weak var quizButton: UIButton!
    @IBOutlet weak var browseButton: UIButton!
    @IBOutlet weak var logOffButton: UIButton!
    
    var authenticationDelegate : AuthenticationDelegate!
    
    var user : User! {
        didSet{
            populateComponents()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        performInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        performInit()
    }
    
    func performInit(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        authenticationDelegate = appDelegate
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        populateComponents()
    }
    
    func populateComponents(){
        guard let _ = user else { return }
        guard let _ = welcomeLabel else { return }
        welcomeLabel.text = "Hi, \(user.name). Welcome to..."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoffAction(_ sender: Any) {
        authenticationDelegate.performLogoff()
        
        popSelfFromNavStackNotUnitTestable()
    }
    
    func popSelfFromNavStackNotUnitTestable(){
        _ = navigationController?.popViewController(animated: true)
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
