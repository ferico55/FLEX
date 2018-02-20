//
//  TokoCashGetCodeResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 08/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

public struct TokoCashGetCodeResponse {
    public let responseCode: String
    public let code: String
    
    public init(responseCode: String, code:String){
        self.responseCode = responseCode
        self.code = code
    }
    
    public init(json: JSON){
        let responseCode = json["code"].stringValue
        let code = json["data"]["code"].stringValue
        self.init(responseCode: responseCode, code: code)
    }
}
