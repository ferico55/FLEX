//
//  TokoCashLoginVerifyOTPResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 30/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TokoCashLoginVerifyOTPResponse {
    public let code: String
    public let key: String
    public let tokoCashAccountExist: Bool
    public let userDetails: [TokoCashVerifyUserDetail]
    public let verified: Bool
    
    public init(code: String, key: String, tokoCashAccountExist: Bool, userDetails: [TokoCashVerifyUserDetail], verified: Bool) {
        self.code = code
        self.key = key
        self.tokoCashAccountExist = tokoCashAccountExist
        self.userDetails = userDetails
        self.verified = verified
    }
    
    public init(json: JSON) {
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

public struct TokoCashVerifyUserDetail {
    public let name: String
    public let email: String
    public let image: String?
    public let tkpdUserId: Int
    
    public init(name: String, email: String, image: String?, tkpdUserId: Int) {
        self.name = name
        self.email = email
        self.image = image
        self.tkpdUserId = tkpdUserId
    }
    
    public init(json: JSON) {
        let name = json["name"].stringValue
        let email = json["email"].stringValue
        let image = json["image"].string
        let tkpdUserId = json["tkpd_user_id"].intValue
        
        self.init(name: name, email: email, image: image, tkpdUserId: tkpdUserId)
    }
}
