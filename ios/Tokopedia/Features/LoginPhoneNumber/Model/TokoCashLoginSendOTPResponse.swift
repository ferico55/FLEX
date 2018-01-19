//
//  TokoCashLoginSendOTPResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 30/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TokoCashLoginSendOTPResponse {
    let code: String
    let otpAttempLeft: Int
    let sent: Bool
    let phoneNumber: String
    
    init(code: String, otpAttempLeft: Int, sent: Bool, phoneNumber: String){
        self.code = code
        self.otpAttempLeft = otpAttempLeft
        self.sent = sent
        self.phoneNumber = phoneNumber
    }
    
    init(json: JSON, phoneNumber: String){
        let code = json["code"].stringValue
        let otpAttempLeft = json["data"]["otp_attempt_left"].intValue
        let sent = json["data"]["sent"].boolValue
        self.init(code: code, otpAttempLeft: otpAttempLeft, sent: sent, phoneNumber: phoneNumber)
    }
}
