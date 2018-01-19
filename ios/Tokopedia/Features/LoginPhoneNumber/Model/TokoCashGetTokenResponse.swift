//
//  TokoCashGetTokenResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 11/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TokoCashGetTokenResponse {
    let accessToken: String?
    let expiredTime: Int?
    
    init(accessToken: String?, expiredTime: Int?){
        self.accessToken = accessToken
        self.expiredTime = expiredTime
    }
    
    init(json: JSON){
        let accessToken = json["access_token"].string
        let expiredTime = json["expires_in"].int
        self.init(accessToken: accessToken, expiredTime:expiredTime)
    }
}
