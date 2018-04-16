//
//  AuthenticationService.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 18/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import RxSwift

@objc public class AuthenticationService: NSObject, VerificationModeListDelegate, CentralizedOTPDelegate {
    public static let shared = AuthenticationService() // Singleton Object
    public var login: Login?
    public var authToken: OAuthToken?
    public var accountInfo: AccountInfo?
    public var socialProfile: CreatePasswordUserProfile?
    public var onLoginComplete: LoginCompletion = { _, _ in }
    public weak var loginDelegate: AuthenticationServiceProtocol?
    
    private var didEnterCreatePassword = false
    //    Lifecycle
    private override init() {}
    //    MARK: - Public
    public func login(withUserProfile profile: CreatePasswordUserProfile) {
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
    public func login(withEmail email: String, password: String) {
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "password"
        parameter["username"] = email
        parameter["password"] = password
        self.doLogin(parameter: parameter)
    }
    public func login(withWebViewToken token: String) {
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "authorization_code"
        parameter["code"] = token
        parameter["redirect_uri"] = NSString.accountsUrl() + "/mappauth/code"
        self.doLogin(parameter: parameter)
    }
    public func login(withActivationCode code: String, attempt: String) {
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "password"
        parameter["password"] = code
        parameter["attempt"] = attempt
        parameter["username"] = " "
        parameter["password_type"] = "activation_code"
        self.doLogin(parameter: parameter)
    }
    public func login(withTokocashCode code: String) {
        var parameter: [String: String] = [:]
        parameter["grant_type"] = "extension"
        parameter["social_type"] = "5"
        parameter["access_token"] = code
        self.doLogin(parameter: parameter)
    }
    
    public func reloginAccount() -> Observable<Void> {
        return AccountProvider()
            .request(.updateGCM)
            .mapToVoid()
    }
    
    public func getThirdPartySignInOptions(_ type: SignInOptionsType = .login, onCompletion: @escaping SignOptionsRequestCompletion) {
        let request = SignOptionsRequest()
        request.type = type
        request.completionHandler = onCompletion
        request.getThirdPartySignOptions()
    }
    public func getNewToken(onCompletion: @escaping AuthTokenCompletion) {
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
    private func authenticateToMarketplace(_ isLoginPhoneNumber: Bool = false) {
        self.authenticateToMarketplace(onCompletion: { (login: Login?, error: Error?) in
            if let error = error {
                self.onLoginComplete(nil, error)
            } else if let login = login {
                self.login = login
                self.analyzeLogin(isLoginPhoneNumber)
            } else {
                let error = NSError(domain: "Login", code: -112233, userInfo: [:])
                self.onLoginComplete(nil, error)
            }
        })
    }
    //    MARK: - Private
    private func doLogin(parameter: [String: String]) {
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
                // MARK: Login With Phone number
                if let socialType = parameter["social_type"], socialType == "5" {
                    // MARK: Set to true, because login phone number doesn't need interrupt page / security question
                    self.authenticateToMarketplace(true)
                } else {
                    self.analyzeAccountInfo()
                }
            } else {
                let error = NSError(domain: "AccountInfo", code: -112233, userInfo: [:])
                self.onLoginComplete(nil, error)
            }
        })
    }
    public func analyzeAccountInfo() {
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
    private func analyzeLogin(_ isLoginPhoneNumber: Bool = false) {
        guard let login = self.login, let authToken = self.authToken, let accountInfo = self.accountInfo else {
            let error = NSError(domain: "Login", code: -112233, userInfo: nil)
            self.onLoginComplete(nil, error)
            return
        }
        if (login.result.security != nil && login.result.security.allow_login != "1" && !isLoginPhoneNumber) || SecurityQuestionTweaks.alwaysShowSecurityQuestion() && !isLoginPhoneNumber {
            // store token for request otp list
            SecureStorageManager().storeToken(authToken)
            let viewController = VerificationModeListViewController(otpType: .securityChallenge)
            viewController.delegate = self
            viewController.accountInfo = accountInfo
            viewController.isPresent = true
            let navigationController = UINavigationController(rootViewController: viewController)
            UIApplication.topViewController()?.navigationController?.present(navigationController, animated: true, completion: nil)
        } else {
            let storage = TKPDSecureStorage.standardKeyChains()
            let tokenDictionary: [String: Any?] = [
                "oAuthToken.accessToken": self.authToken?.accessToken,
                "oAuthToken.refreshToken": self.authToken?.refreshToken,
                "oAuthToken.tokenType": self.authToken?.tokenType
            ]
            let safeDictionary = tokenDictionary.avoidImplicitNil()
            storage?.setKeychainWith(safeDictionary)
            
            let storageManager = SecureStorageManager()
            if !storageManager.storeLoginInformation(login.result) {
                let error = NSError(domain: "Login", code: -112233, userInfo: nil)
                self.onLoginComplete(nil, error)
                return
            }
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
    private func authenticateToMarketplace(onCompletion: @escaping LoginCompletion) {
        let request = UserLoginRequest()
        request.accountInfo = self.accountInfo
        request.authToken = self.authToken
        request.completionHandler = onCompletion
        request.authenticate()
    }
    private func getUserInfo(parameter: [String: String], onCompletion: @escaping AccountInfoCompletion) {
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
    private func getAuthToken(parameter: [String: String], onCompletion: @escaping AuthTokenCompletion) {
        let request = AuthTokenRequest()
        request.completionHandler = onCompletion
        request.tokenFrom = .socialProfile
        request.parameter = parameter
        request.getAuthToken()
    }
    
    // MARK: VerificationList Delegate
    public func didTapOtpMode(modeDetail: ModeListDetail, accountInfo: AccountInfo?) {
        let viewController = CentralizedOTPViewController(otpType: .securityChallenge)
        viewController.modeDetail = modeDetail
        viewController.delegate = self
        if let accountInfo = accountInfo {
            viewController.accountInfo = accountInfo
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        UIApplication.topViewController()?.navigationController?.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: CentralizedOTP Delegate
    public func didSuccessVerificationOTP(otpType: CentralizedOTPType, otpResult: COTPResponse) {
        if let uuid = otpResult.uuid, otpType == .securityChallenge {
            let storage = TKPDSecureStorage.standardKeyChains()
            storage?.setKeychainWithValue(uuid, withKey: "securityQuestionUUID")
            self.authenticateToMarketplace()
        }
    }
}
