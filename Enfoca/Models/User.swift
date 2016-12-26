//
//  User.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

public struct User {
    private(set) var userId : String
    private(set) var userName : String
    
    init(userId : String, userName : String){
        self.userId = userId
        self.userName = userName
    }
    
    
}
