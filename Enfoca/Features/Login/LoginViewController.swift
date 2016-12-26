//
//  LoginViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var authenticateionDelegate : AuthenticationDelegate!
    
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
//        appDelegate.userCallback = self.callback
        authenticateionDelegate = appDelegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        authenticateionDelegate.performSilentLogin()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func userAuthenticated(user : User) {
        performSegue(withIdentifier: "WelcomeVC", sender: user)
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let user = sender as? User else {
            return
        }
        
        //Hm, Shouldnt the DestVC be inside of a nav?
        let destVC = segue.destination as? WelcomeViewController
        
        destVC?.user = user
    }
    

}
