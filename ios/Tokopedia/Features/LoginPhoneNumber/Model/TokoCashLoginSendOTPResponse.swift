//
//  TokoCashLoginSendOTPResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 30/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TokoCashLoginSendOTPResponse {
    public let code: String
    public let otpAttempLeft: Int
    public let sent: Bool
    public let phoneNumber: String
    
    public init(code: String, otpAttempLeft: Int, sent: Bool, phoneNumber: String){
        self.code = code
        self.otpAttempLeft = otpAttempLeft
        self.sent = sent
        self.phoneNumber = phoneNumber
    }
    
    public init(json: JSON, phoneNumber: String){
        let code = json["code"].stringValue
        let otpAttempLeft = json["data"]["otp_attempt_left"].intValue
        let sent = json["data"]["sent"].boolValue
        self.init(code: code, otpAttempLeft: otpAttempLeft, sent: sent, phoneNumber: phoneNumber)
    }
}
