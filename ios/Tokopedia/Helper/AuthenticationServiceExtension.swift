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
    
    func signInFromViewController(_ viewController: UIViewController, onSignInSuccess: @escaping (_ loginResult: LoginResult?) -> Void){
        
        let loginViewController: LoginViewController = LoginViewController()
        loginViewController.isPresentedViewController = true
        loginViewController.onLoginFinished = { loginResult in
            guard let loginResult = loginResult else {
                StickyAlertView.showErrorMessage(["Terjadi kendala pada server. Mohon coba beberapa saat lagi."])
                return
            }
            
            if let loginNavCon = loginViewController.navigationController {
                loginNavCon.dismiss(animated: true, completion: {
                    self.loginSuccessBlock(loginResult)
                    self.loginSuccessBlock = nil
                })
            }else{
                loginViewController.dismiss(animated: true, completion: {
                    self.loginSuccessBlock(loginResult)
                    self.loginSuccessBlock = nil
                })
            }
        }
        
        let navigationController: UINavigationController = UINavigationController(rootViewController: loginViewController)
        navigationController.navigationBar.isTranslucent = false;
        
        viewController.present(navigationController, animated: true, completion: nil)
        loginSuccessBlock = { loginResult in
            onSignInSuccess(loginResult)
        }
    }
    
    func ensureLoggedInFromViewController(_ viewController: UIViewController, onSuccess: (() -> Void)?) {
        if UserAuthentificationManager().isLogin {
            if let theOnSuccess = onSuccess {
                theOnSuccess()
            }
        } else {
            self.signInFromViewController(viewController) { result in
                if let theOnSuccess = onSuccess {
                    theOnSuccess()
                }
            }
        }
    }
    
    func ensureLoggedIn(from viewController: UIViewController) -> Observable<Void> {
        return Observable.create { observer in
            self.ensureLoggedInFromViewController(viewController) {
                observer.on(.next())
                observer.on(.completed)
            }
            
            return Disposables.create()
        }
    }
}
