//
//  AuthenticationService.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 9/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

extension AuthenticationService: LoginViewDelegate {

    public func redirectViewController(_ viewController: Any!) {
        
    }
    
    public func didLoginSuccess(_ loginResult: LoginResult) {
        loginSuccessBlock(loginResult)
        loginSuccessBlock = nil
    }
    
    func signInFromViewController(_ viewController: UIViewController, onSignInSuccess: @escaping (_ loginResult: LoginResult?) -> Void){
        
        let loginViewController: LoginViewController = LoginViewController()
        loginViewController.isPresentedViewController = true
        loginViewController.delegate = self
        loginViewController.redirectViewController = viewController
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.navigationBar.isTranslucent = false;
        
        viewController.present(navigationController, animated: true, completion: nil)
        loginSuccessBlock = { loginResult in
            onSignInSuccess(loginResult)
        }
    }
    
    func ensureLoggedInFromViewController(_ viewController: UIViewController, onSuccess: @escaping () -> ()) {
        if UserAuthentificationManager().isLogin {
            onSuccess()
        } else {
            self.signInFromViewController(viewController) { result in
                onSuccess()
            }
        }
    }
    
    
}
