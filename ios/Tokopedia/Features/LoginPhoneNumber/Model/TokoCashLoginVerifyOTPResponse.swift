//
//  TokoCashLoginVerifyOTPResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 30/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TokoCashLoginVerifyOTPResponse {
    let code: String
    let key: String
    let tokoCashAccountExist: Bool
    let userDetails: [TokoCashVerifyUserDetail]
    let verified: Bool
    
    init(code: String, key: String, tokoCashAccountExist: Bool, userDetails: [TokoCashVerifyUserDetail], verified: Bool) {
        self.code = code
        self.key = key
        self.tokoCashAccountExist = tokoCashAccountExist
        self.userDetails = userDetails
        self.verified = verified
    }
    
    init(json: JSON) {
        let code = json["code"].stringValue
        let key = json["data"]["key"].stringValue
        let tokoCashAccountExist = json["data"]["tokocash_account_exist"].boolValue
        let verified = json["data"]["verified"].boolValue
        var userDetails = [TokoCashVerifyUserDetail]()
        
        for value in json["data"]["user_details"].arrayValue {
            let userDetail = TokoCashVerifyUserDetail(json: value)
            userDetails.append(userDetail)
        }
        
        self.init(code: code, key: key, tokoCashAccountExist: tokoCashAccountExist, userDetails: userDetails, verified: verified)
    }
}

struct TokoCashVerifyUserDetail {
    let name: String
    let email: String
    let image: String?
    let tkpdUserId: Int
    
    init(name: String, email: String, image: String?, tkpdUserId: Int) {
        self.name = name
        self.email = email
        self.image = image
        self.tkpdUserId = tkpdUserId
    }
    
    init(json: JSON) {
        let name = json["name"].stringValue
        let email = json["email"].stringValue
        let image = json["image"].string
        let tkpdUserId = json["tkpd_user_id"].intValue
        
        self.init(name: name, email: email, image: image, tkpdUserId: tkpdUserId)
    }
}
