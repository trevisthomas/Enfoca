//
//  AppDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    private let googleClientId = "528831726200-caemar3na7rvr7jp9cqjreq6t6pa5s33.apps.googleusercontent.com"
    
    var webService : WebService!
    var applicationDefaults : ApplicationDefaults!
    
    var userAuthenticated : ((User) -> ())?
    fileprivate var user: User?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GIDSignIn.sharedInstance().clientID = googleClientId
        GIDSignIn.sharedInstance().delegate = self
        
        webService = DemoWebService()
        applicationDefaults = LocalApplicationDefaults()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    //Added for google login:  https://developers.google.com/identity/sign-in/ios/sign-in?ver=swift
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
//            let idToken = user.authentication.idToken // Safe to send to the server
//            let fullName = user.profile.name
//            let givenName = user.profile.givenName
//            let familyName = user.profile.familyName
//            let email = user.profile.email
            
            //            user.profile.
            //            print("User: \(userId)")
//            if let callback = userCallback {
//                callback(user)
//            }
            
            print(user.profile.description)
            
            
            //TODO: This should make a call to your server to get the enfocaId before moving forward.
            let user = User(enfocaId: -1, name: user.profile.name, email: user.profile.email)
            
            if let userAuthenticated = userAuthenticated {
                userAuthenticated(user)
                self.user = user
            }
            
        } else {
            print("Error during google sign in : \(error.localizedDescription)")
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        //        // ...
        
        print("Signed out")
        
    }


}

extension AppDelegate : AuthenticationDelegate {
    func performLogin() {
        //Hm.
    }
    func performSilentLogin() {
        GIDSignIn.sharedInstance().signInSilently()
    }
    func performLogoff() {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func currentUser() -> User?{
        return self.user
    }
}

//extension AppDelegate : ApplicationDefaults {
//    var tagFilters : [(Tag, Bool)]
//    func tagFilters() -> [tagFilter] {
//        return tagFilters
//    }
//
//    internal func reverseWordPair() -> Bool {
//        return false
//    }
//
//    func wordStateFilter() -> WordStateFilter {
//        return .all
//    }
//}

func getAppDelegate() -> AppDelegate{
    return UIApplication.shared.delegate as! AppDelegate
}
