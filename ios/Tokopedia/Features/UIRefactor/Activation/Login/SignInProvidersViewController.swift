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
    weak var parentController: LoginTableViewController!
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
            self.parentController.providersListViewHeight = CGFloat(self.providersListView.buttons.count * 54) - 10.0
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
            self.navigationController?.setModalNavigation()
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
            self.navigationController?.setModalNavigation()
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
            service.loginDelegate = self.parentController.parentController
            service.onLoginComplete = { (_ login: Login?, _ error: Error?) -> Void in
                if let error = error {
                    SecureStorageManager().resetKeychain()
                    let message = error.localizedDescription
                    StickyAlertView.showErrorMessage([message])
                } else if let login = login {
                    login.medium = provider.name
                    LoginAnalytics().trackLoginSuccessEvent(label: provider.name)
                    self.parentController.parentController.loginSuccess(login: login)
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
        UIAlertController.showActionSheet(in: self,
                                          withTitle: "Silahkan pilih akun anda",
                                          message: nil,
                                          cancelButtonTitle: "Batal",
                                          destructiveButtonTitle: nil,
                                          otherButtonTitles: emailIds,
                                          popoverPresentationControllerBlock: { [unowned self] (popover: UIPopoverPresentationController) in
                                              if let touchIdButton = self.providersListView.buttons.first {
                                                  popover.sourceView = touchIdButton
                                                  popover.sourceRect = touchIdButton.bounds
                                              }
                                          }, tap: { (controller: UIAlertController, _: UIAlertAction, buttonIndex: Int) in
                                              if buttonIndex >= controller.firstOtherButtonIndex {
                                                  let index = buttonIndex - controller.firstOtherButtonIndex
                                                  touchIdHelper.loadTouchID(withEmail: emailIds[index])
                                              }
        })
    }
    func doLoginWithUser(profile: CreatePasswordUserProfile) {
        self.parentController.parentController.makeActivityIndicator(toShow: false)
        let service = AuthenticationService.shared
        service.loginDelegate = self.parentController.parentController
        service.onLoginComplete = { (_ login: Login?, _ error: Error?) -> Void in
            if let error = error {
                DispatchQueue.main.async { self.parentController.parentController.makeActivityIndicator(toShow: false)
                    let message = error.localizedDescription
                    StickyAlertView.showErrorMessage([message])
                }
            } else if let login = login {
                GIDSignIn.sharedInstance().signOut()
                GIDSignIn.sharedInstance().disconnect()

                login.medium = profile.providerName
                self.parentController.parentController.loginSuccess(login: login)
            }
        }
        service.login(withUserProfile: profile)
    }
    //    MARK: - Facebook Login
    func facebookLoginCompleted(result: FBSDKLoginManagerLoginResult?, error: Error?) {
        guard error == nil else {
            StickyAlertView.showErrorMessage([error!.localizedDescription])
            SecureStorageManager().resetKeychain()
            self.parentController.parentController.makeActivityIndicator(toShow: false)
            return
        }
        if FBSDKAccessToken.current() != nil {
            let parameters = ["fields": "id, name, email, birthday, gender"]
            FBSDKGraphRequest(graphPath: "me", parameters: parameters).start { [unowned self] (_: FBSDKGraphRequestConnection?, result: Any?, error2: Error?) in
                if let error3 = error2 {
                    DispatchQueue.main.async {
                        self.parentController.parentController.makeActivityIndicator(toShow: false)
                        StickyAlertView.showErrorMessage([error3.localizedDescription])
                    }
                } else {
                    self.didReceiveFacebookUserData(userData: result as? [String: String])
                }
            }
        } else {
            self.parentController.parentController.makeActivityIndicator(toShow: false)
        }
    }
    func didReceiveFacebookUserData(userData: [String: String]?) {
        guard userData != nil else {
            debugPrint("Error: Failed to laod facebook user data")
            self.parentController.parentController.makeActivityIndicator(toShow: false)
            return
        }
        let profile = CreatePasswordUserProfile.fromFacebook(userData: userData!)
        self.doLoginWithUser(profile: profile)
    }
    //    MARK: - GIDSignInDelegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            SecureStorageManager().resetKeychain()
            StickyAlertView.showErrorMessage([error.localizedDescription])
            self.parentController.parentController.makeActivityIndicator(toShow: false)
            debugPrint(error.localizedDescription)
            return
        }
        let profile = CreatePasswordUserProfile.fromGoogle(user: user)
        self.doLoginWithUser(profile: profile)
    }
}
