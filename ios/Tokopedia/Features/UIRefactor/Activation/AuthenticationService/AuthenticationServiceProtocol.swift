//
//  AuthenticationServiceProtocol.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 21/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
@objc public protocol AuthenticationServiceProtocol: NSObjectProtocol {
    func showVerifyLoginScreen(sender: AuthenticationService, onCompletion: @escaping (_ error: Error?) -> Void)
    func showCreatePasswordScreen(sender: AuthenticationService, onCompletion: @escaping (_ error: Error?) -> Void)
    func successLoginAfterCreatePassword(sender: AuthenticationService, login: Login)
}
