//
//  RegisterBaseViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import FBSDKLoginKit

@objc(RegisterBaseViewController)
class RegisterBaseViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate, AuthenticationServiceProtocol {
    
    var onLoginSuccess: ((LoginResult) -> Void)?
    var isLoginPresented = false
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var signInProviderContainer: UIView!
    @IBOutlet private var registerWithEmailButton: UIButton!
    @IBOutlet private var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Daftar"
        
        let googleSignIn = GIDSignIn.sharedInstance()
        googleSignIn?.shouldFetchBasicProfile = true
        googleSignIn?.clientID = "692092518182-bnp4vfc3cbhktuqskok21sgenq0pn34n.apps.googleusercontent.com"
        googleSignIn?.scopes = ["profile", "email"]
        googleSignIn?.delegate = self
        googleSignIn?.uiDelegate = self
        googleSignIn?.allowsSignInWithWebView = false
        
        self.setSignInProviders(provider: SignInProvider.defaultProviders())
        
        AuthenticationService.shared.getThirdPartySignInOptions { [weak self] providers, _ in
            guard let providers = providers else {
                return
            }
            
            self?.setSignInProviders(provider: providers)
        }
        
        self.updateFormViewAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Register Home Page")
        self.navigationController?.setWhite()
    }
    
    private func updateFormViewAppearance() {
        self.view.addSubview(self.contentView)
        let width = UIScreen.main.bounds.size.width
        var contentViewWidth = width
        var contentViewMarginLeft = 0
        var contentViewMarginTop = 30
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            contentViewWidth = 560
            contentViewMarginLeft = 134
            contentViewMarginTop = 25
        }
        
        self.contentView.snp.makeConstraints { constraint in
            constraint.width.equalTo(contentViewWidth)
            constraint.top.equalTo(self.view.snp.top).offset(contentViewMarginTop)
            constraint.right.equalTo(self.view.snp.right).offset(-contentViewMarginLeft)
            constraint.left.equalTo(self.view.snp.left).offset(contentViewMarginLeft)
        }
    }
    
    private func setSignInProviders(provider: [SignInProvider]) {
        weak var weakSelf = self
        guard let signInContainer = self.signInProviderContainer else {
            return
        }
        
        signInContainer.removeAllSubviews()
        
        let providerListView = SignInProviderListView(providers: provider, isRegister: true)
        providerListView.attachToView(self.signInProviderContainer)
        
        providerListView.onWebViewProviderSelected = { provider in
            AnalyticsManager.trackEventName("clickRegister", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_CLICK, label: "\(provider.name) - Step 1")
            weakSelf?.webViewSignIn(provider: provider)
        }
        
        providerListView.onFacebookSelected = { provider in
            AnalyticsManager.trackEventName("clickRegister", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_CLICK, label: "\(provider.name) - Step 1")
            let facebookLoginManager = FBSDKLoginManager()
            facebookLoginManager.logIn(
                withReadPermissions: ["public_profile", "email", "user_birthday"],
                from: weakSelf,
                handler: { result, error in
                    weakSelf?.loginButton(nil, didCompleteWith: result, error: error)
                }
            )
        }
        
        providerListView.onGoogleSelected = { provider in
            AnalyticsManager.trackEventName("clickRegister", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_CLICK, label: "\(provider.name) - Step 1")
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    private func webViewSignIn(provider: SignInProvider) {
        let controller = WebViewSignInViewController(provider: provider)
        controller.onReceiveToken = { [weak self] token in
            AuthenticationService.shared.loginDelegate = self
            AuthenticationService.shared.login(withUserProfile: CreatePasswordUserProfile.fromYahoo(token: token))
            AuthenticationService.shared.onLoginComplete = { login, error in
                guard let login = login else {
                    StickyAlertView.showErrorMessage([error?.localizedDescription ?? ""])
                    return
                }
                
                self?.loginSuccess(login: login)
            }
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func loginSuccess(login: Login) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        
        let storageManager = SecureStorageManager()
        storageManager.storeLoginInformation(login.result)
        
        let userManager = UserAuthentificationManager()
        UserRequest.getUserInformation(
            withUserID: userManager.getUserId(),
            onSuccess: { _ in
                AnalyticsManager.moEngageTrackUserAttributes()
            },
            onFailure: {
                
            }
        )
        
        AnalyticsManager.trackLogin(login)
        
        NotificationCenter.default.post(name: NSNotification.Name(TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(UPDATE_TABBAR), object: nil, userInfo: nil)
        
        if login.justRegistered {
            NotificationCenter.default.post(name: NSNotification.Name("didSuccessActivateAccount"), object: nil, userInfo: nil)
        } else {
            NotificationCenter.default.post(name: NSNotification.Name(kTKPD_REDIRECT_TO_HOME), object: nil, userInfo: nil)
        }
        
        guard let tabManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager else {
            return
        }
        
        tabManager.sendLoginEvent()
    }
    
    // MARK: Action Button
    @IBAction func onTapLoginWithEmail(_ sender: Any) {
        AnalyticsManager.trackEventName("clickRegister", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_CLICK, label: "Email - Step 1")
        let controller = RegisterEmailViewController()
        controller.isLoginPresented = self.isLoginPresented
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func onTapLogin(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Facebook SDK Login Delegate
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let accessToken = FBSDKAccessToken.current() {
            let parameters = NSMutableDictionary(dictionary: ["fields": "id, name, email, birthday, gender"])
            guard let param = parameters as? [AnyHashable: Any] else {
                return
            }
            FBSDKGraphRequest(graphPath: "me", parameters: param).start { _, result, _ in
                guard var result = result as? [String: String] else {
                    return
                }
                result["accessToken"] = accessToken.tokenString
                self.didReceiveFacebookUserData(data: result)
            }
        }
    }
    
    private func didReceiveFacebookUserData(data: Any) {
        guard let userData = data as? [String: String] else {
            return
        }
        
        AuthenticationService.shared.loginDelegate = self
        
        AuthenticationService.shared.login(withUserProfile: CreatePasswordUserProfile.fromFacebook(userData: userData))
        
        AuthenticationService.shared.onLoginComplete = { login, error in
            guard let login = login else {
                StickyAlertView.showErrorMessage([error?.localizedDescription ?? ""])
                return
            }
            
            self.loginSuccess(login: login)
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    // MARK: Google Sign In Delegate
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard let user = user else {
            return
        }
        
        self.googleSignIn(user: user)
    }
    
    private func googleSignIn(user: GIDGoogleUser) {
        AuthenticationService.shared.loginDelegate = self
        
        AuthenticationService.shared.login(withUserProfile: CreatePasswordUserProfile.fromGoogle(user: user))
        
        AuthenticationService.shared.onLoginComplete = { login, error in
            guard let login = login else {
                GIDSignIn.sharedInstance().signOut()
                GIDSignIn.sharedInstance().disconnect()
                StickyAlertView.showErrorMessage([error?.localizedDescription ?? ""])
                return
            }
            
            self.loginSuccess(login: login)
        }
    }
    
    // MARK: Authentication Service Protocol
    func showVerifyLoginScreen(sender: AuthenticationService, onCompletion: @escaping (Error?) -> Void) {
        let secureStorage = TKPDSecureStorage.standardKeyChains()
        
        guard let storage = secureStorage,
            let login = sender.login,
            let info = sender.accountInfo,
            let token = sender.authToken,
            let security = login.result.security else {
            return
        }
        
        let securityQuestionObject = SecurityQuestionObjects()
        securityQuestionObject.userID = login.result.user_id
        securityQuestionObject.name = login.result.full_name
        securityQuestionObject.phoneNumber = info.phoneNumber
        securityQuestionObject.maskedPhoneNumber = info.phoneMasked
        securityQuestionObject.deviceID = UserAuthentificationManager().getMyDeviceToken()
        securityQuestionObject.token = token
        
        let vc = SecurityQuestionViewController(securityQuestionObject: securityQuestionObject)
        
        if SecurityQuestionTweaks.alwaysShowSecurityQuestion() {
            vc.questionType1 = "0"
            vc.questionType2 = "2"
        } else {
            vc.questionType1 = security.user_check_security_1
            vc.questionType2 = security.user_check_security_2
        }
        
        vc.successAnswerCallback = { answer in
            storage.setKeychainWithValue(answer.data.uuid, withKey: "securityQuestionUUID")
            sender.analyzeAccountInfo()
        }
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setWhite()
        
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    func showCreatePasswordScreen(sender: AuthenticationService, onCompletion: @escaping (Error?) -> Void) {
        guard let profile = sender.socialProfile, let token = sender.authToken, let info = sender.accountInfo else {
            return
        }
        
        let vc = RegisterSocialMediaViewController(
            userProfile: profile,
            token: token,
            accountInfo: info,
            successCallback: { _ in
                onCompletion(nil)
            }
        )
        
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isTranslucent = false
        
        self.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    func successLoginAfterCreatePassword(sender: AuthenticationService, login: Login) {
        login.justRegistered = true
        self.loginSuccess(login: login)
    }
}
