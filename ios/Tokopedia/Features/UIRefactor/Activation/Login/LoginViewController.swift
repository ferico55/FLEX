//
//  LoginViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 03/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import SwiftOverlays
import Branch

class LoginViewController: GAITrackedViewController, TouchIDHelperDelegate, AuthenticationServiceProtocol {
    var onLoginFinished: ((_ loginResult: LoginResult?) -> Void)?
    var loadingUIHandler: ((_ isLoading: Bool) -> Void)?
    var isUsingTouchID = false
    var emailId: String?
    var password: String?
    var loginResult: Login?
    @IBOutlet private weak var registerButton: UIBarButtonItem!
    //    MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        TouchIDHelper.sharedInstance.delegate = self

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupUI()
    }
    // MARK: - Public
    func doLoginWithEmail(email: String, password: String) {
        self.makeActivityIndicator(toShow: true)
        let service = AuthenticationService.shared
        service.loginDelegate = self
        service.onLoginComplete = { (_ login: Login?, _ error: Error?) -> Void in
            if let error = error {
                self.makeActivityIndicator(toShow: false)
                var message = error.localizedDescription
                if message.lengthOfBytes(using: .utf8) == 0 {
                    message = "Terjadi kendala pada server. Mohon coba beberapa saat lagi."
                }
                StickyAlertView.showErrorMessage([message])
                self.notifyUserLoginFailure()
                debugPrint("Error: Login failed")
            } else if let login = login {
                self.emailId = email
                self.password = password
                login.medium = "Email"
                self.loginResult = login
                if TouchIDHelper.sharedInstance.isTouchIDAvailable() {
                    self.handleLoginWithTouchId()
                } else {
                    self.loginSuccess(login: login)
                }
            }
        }
        service.login(withEmail: email, password: password)
    }
    func loginSuccess(login: Login) {
        LoginAnalytics().trackMoEngageEvent(with: login)
        SecureStorageManager().storeLoginInformation(login.result)
        AnalyticsManager.trackLogin(login)
        UserRequest.getUserInformation(withUserID: UserAuthentificationManager().getUserId(),
                                       onSuccess: { (_: ProfileInfo) in
                                           AnalyticsManager.moEngageTrackUserAttributes()
                                           DispatchQueue.main.async {
                                               self.makeActivityIndicator(toShow: false)
                                               if self.onLoginFinished != nil {
                                                   self.onLoginFinished!(login.result)
                                               }
                                               QuickActionHelper.sharedInstance.registerShortcutItems()
                                               self.notifyUserDidLogin()
                                           }
                                       },
                                       onFailure: {
                                           DispatchQueue.main.async {
                                               self.makeActivityIndicator(toShow: false)
                                               self.notifyUserLoginFailure()
                                               if self.onLoginFinished != nil {
                                                   self.onLoginFinished!(nil)
                                               }
                                           }
        })
    }
    func navigateToRegister() {
        let viewController = RegisterBaseViewController()
        viewController.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    func makeActivityIndicator(toShow: Bool) {
        DispatchQueue.main.async {
            if self.loadingUIHandler != nil {
                self.loadingUIHandler!(toShow)
            }
        }
    }
    //    MARK: - Actions
    @IBAction func dismissKeyboard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    @IBAction func registerButtonTapped(sender: UIBarButtonItem) {
        LoginAnalytics().trackLoginEvent(name: "registerLogin", action: "Register", label: "Register")
        self.navigateToRegister()
    }
    //    MARK: - Private
    func setupUI() {
        if self.isModal() {
            self.setLeftBarButton(withTitle: "Batal", action: #selector(LoginViewController.cancelButtonTapped(sender:)))
        }
    }
    func cancelButtonTapped(sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    fileprivate func handleLoginWithTouchId() {
        guard let loginResult = self.loginResult, let email = self.emailId, let password = self.password else {
            debugPrint("Error: Login result found nil")
            return
        }
        let touchIdHelper = TouchIDHelper.sharedInstance
        if self.isUsingTouchID {
            LoginAnalytics().trackLoginSuccessEvent(label: "Touch ID")
            self.loginSuccess(login: loginResult)
            self.isUsingTouchID = false
        } else if touchIdHelper.isTouchIDExist(withEmail: email) {
            touchIdHelper.updateTouchID(forEmail: email, password: password)
            LoginAnalytics().trackLoginSuccessEvent(label: "Email")
            self.loginSuccess(login: loginResult)
        } else {
            self.requestToActivateTouchIDForLogin()
        }
    }
    fileprivate func requestToActivateTouchIDForLogin() {
        UIAlertController.showAlert(in: self,
                                    withTitle: "Integrasi dengan Touch ID",
                                    message: "Integrasikan akun \(self.emailId!) dengan Touch ID?",
                                    cancelButtonTitle: "Lewatkan",
                                    destructiveButtonTitle: nil,
                                    otherButtonTitles: ["Ya"]) { [unowned self] (controller: UIAlertController, _: UIAlertAction, buttonIndex: Int) in
            if buttonIndex == controller.cancelButtonIndex {
                LoginAnalytics().trackTouchIdClickEvent(name: "setTouchID", label: "Touch ID - No")
                self.loginSuccess(login: self.loginResult!)
            } else {
                LoginAnalytics().trackTouchIdClickEvent(name: "setTouchID", label: "Touch ID - Yes")
                TouchIDHelper.sharedInstance.saveTouchID(forEmail: self.emailId!, password: self.password!)
            }
        }
    }
    //    MARK: - Notifications
    fileprivate func notifyUserDidLogin() {
        Branch.getInstance().setIdentity(UserAuthentificationManager().getUserId())
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: UPDATE_TABBAR), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kTKPD_REDIRECT_TO_HOME), object: nil)
        let tabManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self)
        if let manager = tabManager as? ReactEventManager {
            manager.sendLoginEvent()
        }
    }
    fileprivate func notifyUserLoginFailure() {
        self.isUsingTouchID = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: TKPDUserLoginFailureNotification), object: nil)
    }
    //    MARK: - AuthenticationService Protocol
    func showVerifyLoginScreen(sender: AuthenticationService, onCompletion: @escaping (Error?) -> Void) {
        guard let login = sender.login, let phoneNumber = sender.accountInfo?.phoneNumber, let authToken = sender.authToken, let phoneMasked = sender.accountInfo?.phoneMasked else { return }
        let questions = SecurityQuestionObjects()
        questions.userID = login.result.user_id
        questions.name = login.result.full_name
        questions.phoneNumber = phoneNumber
        questions.maskedPhoneNumber = phoneMasked
        questions.deviceID = UserAuthentificationManager().getMyDeviceToken()
        questions.token = authToken
        let viewController = SecurityQuestionViewController(securityQuestionObject: questions)
        if SecurityQuestionTweaks.alwaysShowSecurityQuestion() {
            viewController.questionType1 = "0"
            viewController.questionType2 = "2"
        } else {
            viewController.questionType1 = login.result.security.user_check_security_1
            viewController.questionType2 = login.result.security.user_check_security_2
        }
        viewController.successAnswerCallback = { (answer: SecurityAnswer) -> Void in
            let storage = TKPDSecureStorage.standardKeyChains()
            storage?.setKeychainWithValue(answer.data.uuid, withKey: "securityQuestionUUID")
            onCompletion(nil)
        }
        let navigation = UINavigationController(rootViewController: viewController)
        self.present(navigation, animated: true, completion: nil)
        self.makeActivityIndicator(toShow: false)
    }
    func showCreatePasswordScreen(sender: AuthenticationService, onCompletion: @escaping (Error?) -> Void) {
        guard let socialProfile = sender.socialProfile,
            let token = sender.authToken,
            let accountInfo = sender.accountInfo else {
            return
        }

        let vc = RegisterSocialMediaViewController(userProfile: socialProfile,
                                                   token: token,
                                                   accountInfo: accountInfo,
                                                   successCallback: { _ in
                                                       onCompletion(nil)
        })

        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.navigationBar.isTranslucent = false

        self.present(navigationController, animated: true, completion: nil)
        self.makeActivityIndicator(toShow: false)
    }

    func successLoginAfterCreatePassword(sender: AuthenticationService, login: Login) {
        login.justRegistered = true
        self.loginSuccess(login: login)
    }

    //    MARK: - TouchIDHelperDelegate
    func touchIDHelperActivationSucceed(_ helper: TouchIDHelper) {
        guard let loginResult = self.loginResult else {
            return
        }

        self.loginSuccess(login: loginResult)
    }
    func touchIDHelperActivationFailed(_ helper: TouchIDHelper) {
        LoginAnalytics().trackTouchIdClickEvent(name: "setTouchID", label: "Touch ID - Cancel")
        UIAlertController.showAlert(in: self,
                                    withTitle: "Integrasikan dengan Touch ID",
                                    message: "Terjadi kendala dengan Touch ID Anda.\nSilahkan coba kembali",
                                    cancelButtonTitle: "OK",
                                    destructiveButtonTitle: nil,
                                    otherButtonTitles: nil) { [unowned self] (_: UIAlertController, _: UIAlertAction, _: Int) in
            self.loginSuccess(login: self.loginResult!)
        }
    }
    func touchIDHelper(_ helper: TouchIDHelper, loadSucceedForEmail email: String, andPassword password: String) {
        self.isUsingTouchID = true
        self.emailId = email
        self.password = password
        self.doLoginWithEmail(email: email, password: password)
    }
    func touchIDHelperLoadFailed(_ helper: TouchIDHelper) {
        UIAlertController.showAlert(in: self,
                                    withTitle: "Integrasikan dengan Touch ID",
                                    message: "Terjadi kendala dengan Touch ID Anda.\nSilahkan coba kembali",
                                    cancelButtonTitle: "OK",
                                    destructiveButtonTitle: nil,
                                    otherButtonTitles: nil,
                                    tap: nil)
    }
}
