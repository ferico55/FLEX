//
//  AuthenticationService.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 9/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

extension AuthenticationService: LoginViewDelegate {

    public func redirectViewController(viewController: AnyObject!) {
        
    }
    
    public func didLoginSuccess(loginResult: LoginResult) {
        loginSuccessBlock(loginResult)
        loginSuccessBlock = nil
    }
    
    func signInFromViewController(viewController: UIViewController, onSignInSuccess: (loginResult: LoginResult!) -> Void){
        
        let loginViewController: LoginViewController = LoginViewController()
        loginViewController.isPresentedViewController = true
        loginViewController.delegate = self
        loginViewController.redirectViewController = viewController
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.navigationBar.translucent = false;
        
        viewController.presentViewController(navigationController, animated: true, completion: nil)
        loginSuccessBlock = { loginResult in
            onSignInSuccess(loginResult: loginResult)
        }
    }
    
    func ensureLoggedInFromViewController(viewController: UIViewController, onSuccess: () -> ()) {
        if UserAuthentificationManager().isLogin {
            onSuccess()
        } else {
            self.signInFromViewController(viewController) { result in
                onSuccess()
            }
        }
    }
    
    
}
