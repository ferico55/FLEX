//
//  UpdateProfile.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/21/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct UpdateProfileResponse {
    public let messageError: [String]?
    public let isSuccess: Bool?

    public init(isSuccess: Bool, messageError: [String]) {
        self.isSuccess = isSuccess
        self.messageError = messageError
    }
    
    public init(json: JSON) {
        var isSuccess = json["data"]["is_success"].boolValue
        var msgError = [String]()
        if let messageError = json["message_error"].array {
            for msg in messageError {
                msgError.append(msg.stringValue)
            }
            
            isSuccess = msgError.count < 1
        }
        self.init(isSuccess: isSuccess, messageError: msgError)
    }
}

public struct EmailCheckResponse {
    public let messageError: [String]?
    public var isSuccess: Bool?
    public let isExist: Bool?
    
    public init(isExist: Bool, messageError: [String]) {
        self.messageError = messageError
        self.isSuccess = messageError.count < 1
        self.isExist = isExist
    }
    
    public init(json: JSON) {
        let isExist = json["data"]["isExist"].boolValue
        var msgError = [String]()
        if let messageError = json["message_error"].array {
            for msg in messageError {
                msgError.append(msg.stringValue)
            }
            
        }
        
        self.init(isExist: isExist, messageError: msgError)
    }
}

public struct EmailVerificationCodeResponse {
    public let messageError: [String]?
    public var isSuccess: Bool?
    
    public init(isSuccess: Bool, messageError: [String]) {
        self.messageError = messageError
        self.isSuccess = isSuccess
    }
    
    public init(json: JSON) {
        var msgError = [String]()
        if let messageError = json["message_error"].array {
            for msg in messageError {
                msgError.append(msg.stringValue)
            }
            
        }
        let isSuccess = json["data"]["is_success"].boolValue
        self.init(isSuccess: isSuccess, messageError: msgError)
    }
}
