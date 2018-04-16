//
//  UserLoginRequest.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 20/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
public typealias LoginCompletion = (_ login: Login?, _ error: Error?) -> Void
public class UserLoginRequest {
    public var completionHandler: LoginCompletion?
    public var authToken: OAuthToken!
    public var accountInfo: AccountInfo!
    private let networkManager = TokopediaNetworkManager()
    public func authenticate() {
        guard let token = self.authToken, let accountInfo = self.accountInfo, let _ = self.completionHandler else { return }
        let storage = TKPDSecureStorage.standardKeyChains()
        let securityQuestionUUID = (storage?.keychainDictionary())?["securityQuestionUUID"]
        let header = ["Authorization": token.tokenType + " " + token.accessToken]
        var parameter: [String: String] = [:]
        parameter["uuid"] = securityQuestionUUID as? String ?? ""
        parameter["user_id"] = accountInfo.userId
        self.authenticateWith(header: header, parameter: parameter)
    }
    public func authenticateWith(header: [String: String], parameter: [String: String]) {
        guard let completionHandler = self.completionHandler else { return }
        self.networkManager.isUsingHmac = true
        self.networkManager.request(withBaseUrl: NSString.v4Url(),
                                    path: "/v4/session/make_login.pl",
                                    method: RKRequestMethod.POST,
                                    header: header,
                                    parameter: parameter,
                                    mapping: Login.mapping(),
                                    onSuccess: { (result: RKMappingResult, _: RKObjectRequestOperation) in
                                        let resultDict = result.dictionary() as? [String: Any]
                                        if let login = resultDict?[""] as? Login {
                                            if (login.result.email ?? "").isEmpty {
                                                login.result.email = self.accountInfo?.email
                                            }
                                            if (login.result.full_name ?? "").isEmpty {
                                                login.result.full_name = self.accountInfo?.name
                                            }
                                            completionHandler(login, nil)
                                        } else {
                                            let error = NSError(domain: "Login", code: -112233, userInfo: nil)
                                            completionHandler(nil, error)
                                        }
                                    }, onFailure: { (error: Error) in
                                        completionHandler(nil, error)
        })
    }
}
