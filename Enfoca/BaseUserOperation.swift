//
//  BaseUserOperation.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class BaseUserOperation : BaseOperation {
    let user : InternalUser
    let errorDelegate : ErrorDelegate
    
    init(user : InternalUser, errorDelegate : ErrorDelegate){
        self.user = user
        self.errorDelegate = errorDelegate
        super.init()
        qualityOfService = .userInitiated
    }
    
    func handleError(_ error : Error) {
        print(error)
//        fatalError() //Shrug?  
        errorDelegate.onError(message: error.localizedDescription)
    }
}
