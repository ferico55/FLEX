//
//  SignInProvidersViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 03/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class SignInProvidersViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    @IBOutlet private weak var providersListView: SignInProviderListView!
    weak var parentController: LoginTableViewController?
    let kClientId = "692092518182-bnp4vfc3cbhktuqskok21sgenq0pn34n.apps.googleusercontent.com"
    //    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doInitialSetup()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if LoginPreference().touchIdPopShown == false {
            LoginPreference().touchIdPopShown = true
            self.showTouchIdUsagePrompt()
        }
    }
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? LoginTableViewController {
            self.parentController = parent
            parent.providersListViewHeight = CGFloat(self.providersListView.buttons.count * 54) - 10.0
        }
    }
    deinit {
        debugPrint(self)
    }
    //    MARK: -
    func doInitialSetup() {
        self.providersListView.setSignInProviders(isRegister: false)
        self.addProvidersAction()
    }
    func addProvidersAction() {
        self.providersListView.onTouchIdSelected = { (provider: SignInProvider) in
            LoginAnalytics().trackLoginClickEvent(label: provider.name)
            self.touchIdLoginWith(provider: provider)
        }
        self.providersListView.onFacebookSelected = { (provider: SignInProvider) in
            LoginAnalytics().trackLoginClickEvent(label: provider.name)
            FBSDKLoginManager().logIn(
                withReadPermissions: ["public_profile", "email", "user_birthday"],
                from: self,
                handler: { [unowned self] (result: FBSDKLoginManagerLoginResult?, error: Error?) in
                    DispatchQueue.main.async {
                        self.facebookLoginCompleted(result: result, error: error)
                    }
            })
        }
        self.providersListView.onGoogleSelected = { (provider: SignInProvider) in
            if let signIn = GIDSignIn.sharedInstance() {
                signIn.shouldFetchBasicProfile = true
                signIn.clientID = self.kClientId
                signIn.scopes = ["profile", "email"]
                signIn.delegate = self
                signIn.uiDelegate = self
                signIn.allowsSignInWithWebView = false
            }
            LoginAnalytics().trackLoginClickEvent(label: provider.name)
            GIDSignIn.sharedInstance().signIn()
        }
        self.providersListView.onWebViewProviderSelected = { (provider: SignInProvider) in
            LoginAnalytics().trackLoginClickEvent(label: provider.name)
            self.webViewLoginWithProvider(provider: provider)
        }
    }
    func showTouchIdUsagePrompt() {
        let touchIdHelper = TouchIDHelper.sharedInstance
        guard touchIdHelper.isTouchIDAvailable() && touchIdHelper.numberOfConnectedAccounts() > 0 else {
            return
        }
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "TouchIdPromptViewController")
        if let viewController = viewController as? TouchIdPromptViewController {
            viewController.modalPresentationStyle = .popover
            viewController.popoverPresentationController?.delegate = viewController
            if let touchIdButton = self.providersListView.buttons.first {
                viewController.popoverPresentationController?.sourceView = touchIdButton
                viewController.popoverPresentationController?.sourceRect = touchIdButton.bounds
            }
            self.present(viewController, animated: true, completion: nil)
        }
    }
    //    MARK: - Do Login
    func webViewLoginWithProvider(provider: SignInProvider) {
        let controller = WebViewSignInViewController(provider: provider)
        controller.onReceiveToken = { (token: String) in
            let service = AuthenticationService.shared
            guard let parent = self.parentController?.parentController else {return}
            service.loginDelegate = parent
            service.onLoginComplete = { (_ login: Login?, _ error: Error?) -> Void in
                if let login = login {
                    login.medium = provider.name
                    LoginAnalytics().trackLoginSuccessEvent(label: provider.name)
                    parent.loginSuccess(login: login)
                }
            }
            service.login(withUserProfile: CreatePasswordUserProfile.fromYahoo(token: token))

        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func touchIdLoginWith(provider: SignInProvider) {
        let touchIdHelper = TouchIDHelper.sharedInstance
        let emailIds = touchIdHelper.loadTouchIDAccount()
        guard emailIds.count > 0 else {
            return
        }
        if emailIds.count == 1 {
            touchIdHelper.loadTouchID(withEmail: emailIds.first!)
            return
        }
        
        let alertController = UIAlertController(title: "Silahkan pilih akun anda", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
        
        emailIds.forEach({ emailId in
            alertController.addAction(UIAlertAction(title: emailId, style: .default) { _ in
                touchIdHelper.loadTouchID(withEmail: emailId)
            })
        })
        if let touchIdButton = self.providersListView.buttons.first {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = touchIdButton.frame
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func doLoginWithUser(profile: CreatePasswordUserProfile) {
        guard let parent = self.parentController?.parentController else {return}
        parent.makeActivityIndicator(toShow: true)
        let service = AuthenticationService.shared
        service.loginDelegate = parent
        service.onLoginComplete = { (_ login: Login?, _ error: Error?) -> Void in
            if let error = error {
                DispatchQueue.main.async {
                    parent.makeActivityIndicator(toShow: false)
                    let message = error.localizedDescription
                    StickyAlertView.showErrorMessage([message])
                }
            } else if let login = login {
                GIDSignIn.sharedInstance().signOut()
                GIDSignIn.sharedInstance().disconnect()

                login.medium = profile.providerName
                parent.loginSuccess(login: login)
            }
        }
        service.login(withUserProfile: profile)
    }
    //    MARK: - Facebook Login
    func facebookLoginCompleted(result: FBSDKLoginManagerLoginResult?, error: Error?) {
        guard let parent = self.parentController?.parentController else {return}
        guard error == nil else {
            parent.makeActivityIndicator(toShow: false)
            return
        }
        if let accessToken = FBSDKAccessToken.current() {
            let parameters = ["fields": "id, name, email, birthday, gender"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { [unowned self] (_: FBSDKGraphRequestConnection?, result: Any?, error2: Error?) in
                if let error3 = error2 {
                    DispatchQueue.main.async {
                        parent.makeActivityIndicator(toShow: false)
                        StickyAlertView.showErrorMessage([error3.localizedDescription])
                    }
                } else {
                    guard var result = result as? [String: String] else {
                        return
                    }
                    result["accessToken"] = accessToken.tokenString
                    self.didReceiveFacebookUserData(userData: result)
                }
            }
        } else {
            parent.makeActivityIndicator(toShow: false)
        }
    }
    func didReceiveFacebookUserData(userData: [String: String]?) {
        guard let parent = self.parentController?.parentController else {return}
        guard userData != nil else {
            debugPrint("Error: Failed to laod facebook user data")
            parent.makeActivityIndicator(toShow: false)
            return
        }
        let profile = CreatePasswordUserProfile.fromFacebook(userData: userData!)
        self.doLoginWithUser(profile: profile)
    }
    //    MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        guard let parent = self.parentController?.parentController else {return}
        if error != nil {
            parent.makeActivityIndicator(toShow: false)
            return
        }
        let profile = CreatePasswordUserProfile.fromGoogle(user: user)
        self.doLoginWithUser(profile: profile)
    }
}
