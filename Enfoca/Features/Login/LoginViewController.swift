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
        appDelegate.userAuthenticated = self.userAuthenticated
        authenticateionDelegate = appDelegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        authenticateionDelegate.performSilentLogin()
        
        //***** Trevis.  Making fake user.  TODO, get enfoca id from cloudkit
        
        OperationsDemo.authentcate { (enfocaId :Int?, error: String?) in
            guard let enfocaId = enfocaId else {
                if let error = error {
                    print(error) //TODO : alert
                }
                return 
            }
            print("EnfocaId: \(enfocaId)")
            let user = User(enfocaId: enfocaId, name: "Unknown", email: "unknown@unknown")
            self.userAuthenticated(user: user)
        }
        
//        let user = User(enfocaId: -1, name: "Unknown", email: "unknown@unknown")
//        userAuthenticated(user: user)
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
