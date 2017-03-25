//
//  LoginViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var messageStackView: UIStackView!
    fileprivate var progressLabels : [String: UILabel] = [:]
//    var authenticateionDelegate : AuthenticationDelegate!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        performInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        performInit()
    }
    
    func performInit(){
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.userAuthenticated = self.userAuthenticated
//        authenticateionDelegate = appDelegate
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
//        authenticateionDelegate.performSilentLogin()
        
        let service = LocalCloudKitWebService()
//        let service = CloudKitWebService()
//        let service = DemoWebService()
        service.initialize(dataStore: getAppDelegate().applicationDefaults.dataStore, progressObserver: self) { (success :Bool, error : EnfocaError?) in
            getAppDelegate().webService = service
            self.performSegue(withIdentifier: "WelcomeVC", sender: self)
            
//            //DELETE ALL
//            Perform.deleteAllRecords(dataStore: getAppDelegate().applicationDefaults.dataStore, enfocaId: service.enfocaId, db: service.db)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    func userAuthenticated(user : User) {
//        performSegue(withIdentifier: "WelcomeVC", sender: user)
//    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let user = sender as? User else {
//            return
//        }
        
        //Hm, Shouldnt the DestVC be inside of a nav?
//        let destVC = segue.destination as? WelcomeViewController
        
//        destVC?.user = user
    }
    

}

extension LoginViewController : ProgressObserver {
    func startProgress(ofType key : String, message: String){
        print("Starting: \(key) : \(message)")
        
        DispatchQueue.main.async {
            let label = UILabel()
            
            label.text = message
            self.progressLabels[key] = label
            self.messageStackView.addArrangedSubview(label)
            self.messageStackView.translatesAutoresizingMaskIntoConstraints = false;
        }
    }
    func updateProgress(ofType key : String, message: String){
        DispatchQueue.main.async {
            guard let label = self.progressLabels[key] else { return }
            label.text = message
        }
    }
    func endProgress(ofType key : String, message: String) {
        print("Ending: \(key) : \(message)")
        DispatchQueue.main.async {
            guard let label = self.progressLabels[key] else { return }
            label.text = nil
            self.messageStackView.removeArrangedSubview(label)
            self.progressLabels[key] = nil
            
        }
    }

}
