//
//  UserInfoRequest.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 20/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
typealias AccountInfoCompletion = (_ accountInfo: AccountInfo?, _ token: OAuthToken?, _ error: Error?) -> Void
class UserInfoRequest {
    var completionHandler: AccountInfoCompletion?
    var authToken: OAuthToken!
    let networkManager = TokopediaNetworkManager()
    func getUserInfo() {
        guard let token = self.authToken, let completionHandler = self.completionHandler else {
            return
        }
        let header = ["Authorization": token.tokenType + " " + token.accessToken]
        self.networkManager.isUsingHmac = true
        self.networkManager.request(withBaseUrl: NSString.accountsUrl(),
                                    path: "/info",
                                    method: RKRequestMethod.GET,
                                    header: header,
                                    parameter: [:],
                                    mapping: AccountInfo.mapping(),
                                    onSuccess: { (result: RKMappingResult, _: RKObjectRequestOperation) in
                                        let resultDict = result.dictionary() as? [String: Any]
                                        let accountInfo = resultDict?[""] as? AccountInfo
                                        if accountInfo?.error == nil {
                                            completionHandler(accountInfo, token, nil)
                                        } else {
                                            let error = NSError(domain: "UserInfo", code: -112233, userInfo: [NSLocalizedDescriptionKey: accountInfo?.errorDescription ?? ""])
                                            completionHandler(nil, nil, error)
                                        }
                                    }, onFailure: { (error: Error) in
                                        completionHandler(nil, nil, error)
        })
    }
}
