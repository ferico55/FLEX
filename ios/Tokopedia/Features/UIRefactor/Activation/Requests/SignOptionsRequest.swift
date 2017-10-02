//
//  SignOptionsRequest.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 21/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
typealias SignOptionsRequestCompletion = (_ providers: [SignInProvider]?, _ error: Error?) -> Void
class SignOptionsRequest {
    var completionHandler: SignOptionsRequestCompletion?
    let networkManager = TokopediaNetworkManager()
    func getThirdPartySignOptions() {
        guard let completionHandler = self.completionHandler else {
            return
        }
        self.networkManager.isUsingHmac = true
        self.networkManager.request(withBaseUrl: NSString.accountsUrl(),
                                    path: "/api/discover",
                                    method: RKRequestMethod.GET,
                                    parameter: [:],
                                    mapping: DiscoverResponse.mapping(),
                                    onSuccess: { (result: RKMappingResult, _: RKObjectRequestOperation) in
                                        let resultDict = result.dictionary() as? [String: Any]
                                        let response = resultDict?[""] as? DiscoverResponse
                                        if response != nil {
                                            completionHandler(response?.data.providers, nil)
                                        } else {
                                            let error = NSError(domain: "SignInOptions", code: -112233, userInfo: nil)
                                            completionHandler(nil, error)
                                        }
                                    }, onFailure: { (error: Error) in
                                        completionHandler(nil, error)
        })
    }
}
