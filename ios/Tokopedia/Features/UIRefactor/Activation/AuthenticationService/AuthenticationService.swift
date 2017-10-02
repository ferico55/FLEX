//
//  AuthenticationService.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 18/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
@objc class AuthenticationService: NSObject {
    static let shared = AuthenticationService() // Singleton Object
    var login: Login?
    var authToken: OAuthToken?
    var accountInfo: AccountInfo?
    var socialProfile: CreatePasswordUserProfile?
    var onLoginComplete: LoginCompletion = { _, _ in }
    weak var loginDelegate: AuthenticationServiceProtocol?
    
    var didEnterCreatePassword = false
    //    Lifecycle
    private override init() {}
    //    MARK: - Public
    func login(withUserProfile profile: CreatePasswordUserProfile) {
        self.socialProfile = profile
        
        if profile.providerName == "Yahoo" {
            var parameter: [String: String] = [:]
            parameter["grant_type"] = "authorization_code"
            parameter["code"] = profile.accessToken
            parameter["redirect_uri"] = NSString.accountsUrl() + "/mappauth/code"
            self.doLogin(parameter: parameter)
        } else {
            var parameter: [String: String] = [:]
            parameter["grant_type"] = "extension"
            parameter["social_type"] = profile.provider
            parameter["access_token"] = profile.accessToken
            self.doLogin(parameter: parameter)
        }
    }
    func login(withEmail email: String, password: String) {
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "password"
        parameter["username"] = email
        parameter["password"] = password
        self.doLogin(parameter: parameter)
    }
    func login(withWebViewToken token: String) {
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "authorization_code"
        parameter["code"] = token
        parameter["redirect_uri"] = NSString.accountsUrl() + "/mappauth/code"
        self.doLogin(parameter: parameter)
    }
    func login(withActivationCode code: String, attempt: String) {
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "password"
        parameter["password"] = code
        parameter["attempt"] = attempt
        parameter["username"] = " "
        parameter["password_type"] = "activation_code"
        self.doLogin(parameter: parameter)
    }
    func reloginAccount() {
        let userInfo = UserAuthentificationManager().getUserLoginData()
        let tokenType: String = userInfo?["oAuthToken.tokenType"] as? String ?? ""
        let accessToken: String = userInfo?["oAuthToken.accessToken"] as? String ?? ""
        let header = ["Authorization": tokenType + " " + accessToken]
        let uuid: String = userInfo?["securityQuestionUUID"] as? String ?? ""
        let parameter = ["uuid": uuid]
        let request = UserLoginRequest()
        request.accountInfo = self.accountInfo
        request.authToken = self.authToken
        request.completionHandler = { (login: Login?, error: Error?) in
            if let error = error {
                self.onLoginComplete(nil, error)
            } else if let login = login {
                self.login = login
                self.analyzeLogin()
            } else {
                let error = NSError(domain: "Login", code: -112233, userInfo: [:])
                self.onLoginComplete(nil, error)
            }
        }
        request.authenticateWith(header: header, parameter: parameter)
    }
    func getThirdPartySignInOptions(onCompletion: @escaping SignOptionsRequestCompletion) {
        let request = SignOptionsRequest()
        request.completionHandler = onCompletion
        request.getThirdPartySignOptions()
    }
    func getNewToken(onCompletion: @escaping AuthTokenCompletion) {
        let userAuthManager = UserAuthentificationManager()
        let userInfo = userAuthManager.getUserLoginData()
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "refresh_token"
        parameter["refresh_token"] = (userInfo?["oAuthToken.refreshToken"] as? String) ?? ""
        self.getAuthToken(parameter: parameter) { (token: OAuthToken?, error: Error?) in
            if let error = error {
                onCompletion(nil, error)
            } else if let token = token {
                if token.error == "invalid_grant" {
                    let error = NSError(domain: "RefreshToken", code: -112233, userInfo: [:])
                    onCompletion(nil, error)
                } else {
                    SecureStorageManager().storeToken(token)
                    onCompletion(token, nil)
                }
            }
        }
    }
    func authenticateToMarketplace() {
        self.authenticateToMarketplace(onCompletion: { (login: Login?, error: Error?) in
            if let error = error {
                self.onLoginComplete(nil, error)
            } else if let login = login {
                self.login = login
                self.analyzeLogin()
            } else {
                let error = NSError(domain: "Login", code: -112233, userInfo: [:])
                self.onLoginComplete(nil, error)
            }
        })
    }
    //    MARK: - Private
    func doLogin(parameter: [String: String]) {
        self.getUserInfo(parameter: parameter, onCompletion: { (info: AccountInfo?, token: OAuthToken?, error: Error?) in
            if let err = error {
                self.onLoginComplete(nil, err)
            } else if let info = info, let token = token {
                if let profile = self.socialProfile, profile.providerName == "Yahoo" {
                    profile.name = info.name
                    profile.email = info.email
                    self.socialProfile = profile
                }
                
                self.accountInfo = info
                self.authToken = token
                self.analyzeAccountInfo()
            } else {
                let error = NSError(domain: "AccountInfo", code: -112233, userInfo: [:])
                self.onLoginComplete(nil, error)
            }
        })
    }
    func analyzeAccountInfo() {
        guard let accountInfo = self.accountInfo else { return }
        if accountInfo.createdPassword {
            self.authenticateToMarketplace()
        } else {
            if let delegate = self.loginDelegate {
                delegate.showCreatePasswordScreen(sender: self, onCompletion: {
                    (error: Error?) -> Void in
                    if error == nil {
                        self.didEnterCreatePassword = true
                        self.authenticateToMarketplace()
                    }
                })
            }
        }
    }
    func analyzeLogin() {
        guard let login = self.login, let _ = self.authToken, let _ = self.accountInfo else {
            let error = NSError(domain: "Login", code: -112233, userInfo: nil)
            self.onLoginComplete(nil, error)
            return
        }
        if (login.result.security != nil && login.result.security.allow_login != "1") || SecurityQuestionTweaks.alwaysShowSecurityQuestion() {
            if let delegate = self.loginDelegate {
                delegate.showVerifyLoginScreen(sender: self, onCompletion: {
                    (error: Error?) -> Void in
                    if error == nil {
                        self.authenticateToMarketplace()
                    }
                })
            }
        } else {
            let storage = TKPDSecureStorage.standardKeyChains()
            storage?.setKeychainWithValue(self.authToken?.accessToken, withKey: "oAuthToken.accessToken")
            storage?.setKeychainWithValue(self.authToken?.refreshToken, withKey: "oAuthToken.refreshToken")
            storage?.setKeychainWithValue(self.authToken?.tokenType, withKey: "oAuthToken.tokenType")
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
            if self.didEnterCreatePassword, let delegate = self.loginDelegate {
                delegate.successLoginAfterCreatePassword(sender: self, login: login)
            } else {
                self.onLoginComplete(login, nil)
            }
        }
    }
    func authenticateToMarketplace(onCompletion: @escaping LoginCompletion) {
        let request = UserLoginRequest()
        request.accountInfo = self.accountInfo
        request.authToken = self.authToken
        request.completionHandler = onCompletion
        request.authenticate()
    }
    func getUserInfo(parameter: [String: String], onCompletion: @escaping AccountInfoCompletion) {
        self.getAuthToken(parameter: parameter) { (token: OAuthToken?, error: Error?) in
            if let error = error {
                onCompletion(nil, nil, error)
            } else if let token = token {
                let request = UserInfoRequest()
                request.authToken = token
                request.completionHandler = onCompletion
                request.getUserInfo()
            }
        }
    }
    func getAuthToken(parameter: [String: String], onCompletion: @escaping AuthTokenCompletion) {
        let request = AuthTokenRequest()
        request.completionHandler = onCompletion
        request.tokenFrom = .socialProfile
        request.parameter = parameter
        request.getAuthToken()
    }
}
