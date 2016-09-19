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
    
    public func didLoginSuccess(login: Login) {
        loginSuccessBlock(login)
    }
    
    func signInFromViewController(viewController: UIViewController, onSignInSuccess: (login: Login!) -> Void){
        
        let loginViewController: LoginViewController = LoginViewController()
        loginViewController.isPresentedViewController = true
        loginViewController.delegate = self
        loginViewController.redirectViewController = viewController
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.navigationBar.translucent = false;
        
        viewController.presentViewController(navigationController, animated: true, completion: nil)
        loginSuccessBlock = { login in
            onSignInSuccess(login: login)
        }
    }
    
    
}
