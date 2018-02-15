//
//  AuthTokenRequest.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 20/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
public typealias AuthTokenCompletion = (_ token: OAuthToken?, _ error: Error?) -> Void
public class AuthTokenRequest {
    public var parameter: [String: String] = [:]
    public var tokenFrom: AuthTokenSource!
    public var completionHandler: AuthTokenCompletion?
    private let networkManager = TokopediaNetworkManager()
    public func getAuthToken() {
        guard let _ = self.tokenFrom, let completionHandler = self.completionHandler else {
            return
        }
        let header = ["Authorization": "Basic dzFIWXBpZFNocmU6dllYdmQwcXRxVUFSSnNmajRWSWdTeFNrckF5NHBjeXE="]
        self.configureForTokenFrom()
        self.networkManager.isUsingHmac = true
        self.networkManager.request(withBaseUrl: NSString.accountsUrl(),
                                    path: "/token",
                                    method: RKRequestMethod.POST,
                                    header: header,
                                    parameter: self.parameter,
                                    mapping: OAuthToken.mapping(),
                                    onSuccess: { (result: RKMappingResult, _: RKObjectRequestOperation) in
                                        let resultDict = result.dictionary() as? [String: Any]
                                        let oAuthToken = resultDict?[""] as? OAuthToken
                                        if oAuthToken?.error == nil {
                                            completionHandler(oAuthToken, nil)
                                        } else {
                                            let error = NSError(domain: "AuthToken", code: -112233, userInfo: [NSLocalizedDescriptionKey: oAuthToken?.errorDescription ?? ""])
                                            completionHandler(nil, error)
                                        }
                                    }, onFailure: { (error: Error) in
                                        completionHandler(nil, error)
        })
    }
    public func configureForTokenFrom() {
        switch self.tokenFrom! {
        case .socialProfile:
            self.networkManager.isParameterNotEncrypted = true
            return
        case .activationCode:
            self.networkManager.isUsingHmac = true
            return
        case .existingToken:
            self.networkManager.isUsingHmac = true
            return
        case .loginCredentials:
            self.networkManager.isParameterNotEncrypted = true
            return
        case .webviewToken:
            self.networkManager.isParameterNotEncrypted = true
            return
        }
    }
}
