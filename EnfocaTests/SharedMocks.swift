//
//  SharedMocks.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

@testable import Enfoca
class MockAuthenticationDelegate: AuthenticationDelegate {
    var performLoginCount = 0
    var performSilentLoginCount = 0
    var performLogoffCount = 0
    var user : User?
    
    init(user : User? = nil) {
        self.user = user
    }
    
    func performLogin() {
        performLoginCount += 1
    }
    func performSilentLogin() {
        performSilentLoginCount += 1
    }
    func performLogoff(){
        performLogoffCount += 1
    }
    
    func currentUser() -> User?{
        return user
    }
}

class MockWebService : WebService {
    var fetchCallCount : Int = 0
    var tags : [Tag] = []
    var fetchUserId : Int?
    
    func fetchUserTags(enfocaId : Int, callback : @escaping([Tag])->()){
        fetchCallCount += 1
        fetchUserId = enfocaId
        
        callback(tags)
    }
}
