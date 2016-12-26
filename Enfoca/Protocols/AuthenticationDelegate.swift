//
//  AuthenticationDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol AuthenticationDelegate {
    func performLogin()
    func performSilentLogin()
    func performLogoff()
}
