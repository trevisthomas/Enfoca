//
//  AppDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var webService : WebService!
    var applicationDefaults : ApplicationDefaults!
    
    var userAuthenticated : ((User) -> ())?
    fileprivate var user: User?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        applicationDefaults = LocalApplicationDefaults()
        applicationDefaults.load()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        applicationDefaults.save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        applicationDefaults.save()
    }
    
}

extension AppDelegate : AuthenticationDelegate {
    func performLogin() {
        //Hm.
    }
    func performSilentLogin() {
//        GIDSignIn.sharedInstance().signInSilently()
    }
    func performLogoff() {
//        GIDSignIn.sharedInstance().signOut()
    }
    
    func currentUser() -> User?{
        return self.user
    }
}


func getAppDelegate() -> AppDelegate{
    return UIApplication.shared.delegate as! AppDelegate
}
