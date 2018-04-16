//
//  AuthenticationService.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 9/16/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift

extension AuthenticationService {
    
    internal func signInFromViewController(_ viewController: UIViewController, onSignInSuccess: @escaping (_ loginResult: LoginResult?) -> Void) {
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        let navigationController = storyboard.instantiateInitialViewController() as! UINavigationController
        let loginViewController = navigationController.viewControllers.first as! LoginViewController
        loginViewController.onLoginFinished = { (result: LoginResult?) in
            guard let result = result else {
                StickyAlertView.showErrorMessage(["Terjadi kendala pada server. Mohon coba beberapa saat lagi."])
                return
            }
            navigationController.dismiss(animated: true, completion: nil)
            onSignInSuccess(result)
        }
        viewController.present(navigationController, animated: true, completion: nil)
    }
    
    internal func ensureLoggedInFromViewController(_ viewController: UIViewController, onSuccess: (() -> Void)?) {
        if UserAuthentificationManager().isLogin {
            if let theOnSuccess = onSuccess {
                theOnSuccess()
            }
        } else {
            self.signInFromViewController(viewController) { _ in
                if let theOnSuccess = onSuccess {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: {
                        theOnSuccess()
                    })
                }
            }
        }
    }
    
    internal func ensureLoggedIn(from viewController: UIViewController) -> Observable<Void> {
        return Observable.create { observer in
            self.ensureLoggedInFromViewController(viewController) {
                observer.on(.next())
                observer.on(.completed)
            }
            
            return Disposables.create()
        }
    }
}
