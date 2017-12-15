//
//  UserRequest.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import Unbox
import RxSwift
import NSObject_Rx
import Apollo

class UserRequest: NSObject {

    class func getUserInformation(withUserID userID: String, onSuccess: @escaping ((ProfileInfo) -> Void), onFailure: @escaping (() -> Void)) {
        getMoengageUserInformation(withUserID: userID, onSuccess: {
            getPeopleInfo(withUserID: userID, onSuccess: { profile in
                onSuccess(profile)
            }, onFailure: {
                onFailure()
            })
        }, onFailure: {
            getPeopleInfo(withUserID: userID, onSuccess: { profile in
                onSuccess(profile)
            }, onFailure: {
                onFailure()
            })
        })
    }

    class func getPeopleInfo(withUserID userID: String, onSuccess: @escaping ((ProfileInfo) -> Void), onFailure: @escaping (() -> Void)) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/people/get_people_info.pl",
            method: .GET,
            parameter: ["profile_user_id": userID],
            mapping: ProfileInfo.mapping(),
            onSuccess: { mappingResult, _ in
                let profileInfo = mappingResult.dictionary()[""] as! ProfileInfo

                let myUserID = UserAuthentificationManager().getUserId()
                if myUserID == profileInfo.result.user_info.user_id {
                    self.storeUserInformation(profileInfo)
                }

                onSuccess(profileInfo)
            },
            onFailure: { _ in
                onFailure()
            }
        )
    }

    class func getUserCompletion(onSuccess: @escaping (ProfileCompletionInfo) -> Void, onFailure: @escaping () -> Void) {
        let provider = AccountProvider()
        _ = provider.request(.getInfo)
            .map(to: ProfileCompletionInfo.self)
            .subscribe({ event in
                switch event {
                case let .next(info):
                    onSuccess(info)
                case .error :
                    onFailure()
                default:
                    break
                }
            })
    }

    class func editProfile(birthday: Date?, gender: Int, onSuccess: @escaping (APIAction) -> Void, onFailure: @escaping () -> Void) {
        let provider = AccountProvider()
        _ = provider.request(.editProfile(withBirthday: birthday, gender: gender))
            .map(to: APIAction.self)
            .subscribe({ event in
                switch event {
                case let .next(info):
                    onSuccess(info)
                    AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Success", label: "DOB")
                    AnalyticsManager.trackEventName("profileCompletion", category: "Fill Personal Information", action: "Fill Information Success", label: "Gender")
                case .error:
                    onFailure()
                default:
                    break
                }
            })
    }

    private class func storeUserInformation(_ profileInfo: ProfileInfo) {
        let storageManager = SecureStorageManager()
        storageManager.storeUserInformation(profileInfo.result)
        storageManager.storeShopInformation(profileInfo.result)
    }

    class func registerWithEmail(formData: RegisterFormData, onSuccess: @escaping (RegisterUnbox) -> Void, onFailure: @escaping (() -> Void)) {
        _ = AccountProvider()
            .request(.register(email: formData.email, fullName: formData.fullName, phoneNumber: formData.phoneNumber, password: formData.password))
            .do(onError: { error in
                var errorMessages: [String]
                switch (error as NSError).code {
                case NSURLErrorBadServerResponse, NSURLErrorCancelled:
                    errorMessages = ["Terjadi kendala pada server. Mohon coba beberapa saat lagi."]
                case NSURLErrorNotConnectedToInternet:
                    errorMessages = ["Tidak ada koneksi internet"]
                default:
                    errorMessages = [error.localizedDescription]
                }
                StickyAlertView.showErrorMessage(errorMessages)
            })
            .map(to: RegisterUnbox.self)
            .subscribe({ event in
                switch event {
                case let .next(result):
                    onSuccess(result)
                case .error:
                    onFailure()
                default:
                    break
                }
            })
    }

    class func resendActivationEmail(email: String, onSuccess: @escaping (ResendActivationEmail) -> Void, onFailure: @escaping () -> Void) {
        _ = AccountProvider()
            .request(.resendActivationEmail(email: email))
            .do(onError: { error in
                var errorMessages: [String]
                switch (error as NSError).code {
                case NSURLErrorBadServerResponse, NSURLErrorCancelled:
                    errorMessages = ["Terjadi kendala pada server. Mohon coba beberapa saat lagi."]
                case NSURLErrorNotConnectedToInternet:
                    errorMessages = ["Tidak ada koneksi internet"]
                default:
                    errorMessages = [error.localizedDescription]
                }
                StickyAlertView.showErrorMessage(errorMessages)
            })
            .map(to: ResendActivationEmail.self)
            .subscribe({ event in
                switch event {
                case let .next(result):
                    onSuccess(result)
                case .error:
                    onFailure()
                default:
                    break
                }
            })
    }

    class func createPassword(name: String, gender: String, phoneNumber: String, password: String, token: OAuthToken, accountInfo: AccountInfo, onSuccess: @escaping (CreatePassword) -> Void, onFailure: @escaping () -> Void) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        let header = ["Authorization": "\(token.tokenType!) \(token.accessToken!)"]

        let parameter: [String: String] = ["full_name": name,
                                           "gender": gender,
                                           "new_pass": password,
                                           "confirm_pass": password,
                                           "msisdn": phoneNumber,
                                           "bday_dd": "1",
                                           "bday_mm": "1",
                                           "bday_yy": "1",
                                           "register_tos": "1",
                                           "user_id": accountInfo.userId]

        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/api/create-password",
            method: .POST,
            header: header,
            parameter: parameter,
            mapping: CreatePassword.mapping(),
            onSuccess: { mappingResult, _ in
                guard let createPassword = mappingResult.dictionary()[""] as? CreatePassword else {
                    return
                }

                onSuccess(createPassword)
            },
            onFailure: { _ in
                onFailure()
            }
        )
    }

    class func activateAccount(email: String, uniqueCode: String, onSuccess: @escaping (Login) -> Void, onFailure: @escaping () -> Void) {
        var token: OAuthToken = OAuthToken()

        _ = self.requestToken(email: email, uniqueCode: uniqueCode)
            .flatMap({ (resultToken) -> Observable<AccountInfo> in
                token = resultToken
                return self.getUserInfo(token: token)
            })
            .flatMap({ (accountInfo) -> Observable<Login> in
                self.doLogin(token: token, userID: accountInfo.userId)
            })
            .subscribe(
                onNext: { success in
                    onSuccess(success)
                },
                onError: { _ in
                    onFailure()
                }
            )
    }

    class func requestToken(email: String, uniqueCode: String) -> Observable<OAuthToken> {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        let header = ["Authorization": "Basic dzFIWXBpZFNocmU6dllYdmQwcXRxVUFSSnNmajRWSWdTeFNrckF5NHBjeXE="]

        let parameter = ["grant_type": "password",
                         "username": email,
                         "password": uniqueCode,
                         "password_type": "activation_unique_code"]

        return Observable.create({ (observer) -> Disposable in
            networkManager.request(
                withBaseUrl: NSString.accountsUrl(),
                path: "/token",
                method: .POST,
                header: header,
                parameter: parameter,
                mapping: OAuthToken.mapping(),
                onSuccess: { mappingResult, _ in
                    guard let result = mappingResult.dictionary()[""] as? OAuthToken else {
                        observer.onError(RequestError.networkError)
                        return
                    }

                    if result.error != nil {
                        observer.onError(RequestError.networkError)
                        StickyAlertView.showErrorMessage([result.errorDescription ?? "Terjadi kendala pada server. Mohon coba beberapa saat lagi."])
                    } else {
                        observer.onNext(result)
                    }
                },
                onFailure: { _ in
                    observer.onError(RequestError.networkError)
                }
            )

            return Disposables.create()
        })
    }

    class func getUserInfo(token: OAuthToken) -> Observable<AccountInfo> {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        let header = ["Authorization": "\(token.tokenType!) \(token.accessToken!)"]

        let parameter: [String: String] = [:]

        return Observable.create({ (observer) -> Disposable in
            networkManager.request(
                withBaseUrl: NSString.accountsUrl(),
                path: "/info",
                method: .GET,
                header: header,
                parameter: parameter,
                mapping: AccountInfo.mapping(),
                onSuccess: { mappingResult, _ in
                    guard let result = mappingResult.dictionary()[""] as? AccountInfo else {
                        observer.onError(RequestError.networkError)
                        return
                    }

                    if result.error != nil {
                        observer.onError(RequestError.networkError)
                        StickyAlertView.showErrorMessage([result.errorDescription ?? "Terjadi kendala pada server. Mohon coba beberapa saat lagi."])
                    } else {
                        observer.onNext(result)
                    }
                },
                onFailure: { _ in
                    observer.onError(RequestError.networkError)
                }
            )

            return Disposables.create()
        })
    }

    class func doLogin(token: OAuthToken, userID: String) -> Observable<Login> {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        let header = ["Authorization": "\(token.tokenType!) \(token.accessToken!)"]

        let parameter: [String: String] = ["uuid": "",
                                           "user_id": userID]

        return Observable.create({ (observer) -> Disposable in
            networkManager.request(
                withBaseUrl: NSString.v4Url(),
                path: "/v4/session/make_login.pl",
                method: .POST,
                header: header,
                parameter: parameter,
                mapping: Login.mapping(),
                onSuccess: { mappingResult, _ in
                    guard let login = mappingResult.dictionary()[""] as? Login, let security = login.result.security else {
                        return
                    }

                    if security.allow_login == "1" {
                        SecureStorageManager().storeToken(token)

                        if login.result.is_login {
                            observer.onNext(login)
                            observer.onCompleted()
                        } else {
                            observer.onError(RequestError.networkError)
                        }
                    }
                },
                onFailure: { _ in
                    observer.onError(RequestError.networkError)
                }
            )

            return Disposables.create()
        })
    }

    class func getMoengageUserInformation(withUserID: String, onSuccess: @escaping (() -> Void), onFailure: @escaping (() -> Void)) {
        let userID = Int(withUserID) ?? 0
        let moengageClient: ApolloClient = {
            let configuration = URLSessionConfiguration.default
            let userManager = UserAuthentificationManager()

            let appVersion = UIApplication.getAppVersionString()

            let loginData = userManager.getUserLoginData()
            let tokenType = loginData?["oAuthToken.tokenType"] as? String ?? ""
            let accessToken = loginData?["oAuthToken.accessToken"] as? String ?? ""
            let accountsAuth = "\(tokenType) \(accessToken)" as String

            let headers: [AnyHashable: Any] = ["Tkpd-UserId": userManager.getUserId(),
                           "Tkpd-SessionId": userManager.getMyDeviceToken(),
                           "X-Device": "ios-\(appVersion)",
                           "Device-Type": ((UI_USER_INTERFACE_IDIOM() == .phone) ? "iphone" : "ipad"),
                           "Accounts-Authorization": accountsAuth]

            configuration.httpAdditionalHeaders = headers

            let url = URL(string: NSString.graphQLURL())!

            return ApolloClient(networkTransport: HTTPNetworkTransport(url: url, configuration: configuration))
        }()

        _ = moengageClient.watch(query: MoEngageQuery(userID: userID)) { result, error in
            guard error == nil, result?.errors == nil, let data = result?.data else {
                onFailure()
                return
            }
            self.storeUserInformationMoengage(data)
            onSuccess()
        }

    }

    private class func storeUserInformationMoengage(_ result: MoEngageQuery.Data) {
        let storageManager = SecureStorageManager()
        storageManager.storeAnalyticsInformation(data: result)
    }
}
