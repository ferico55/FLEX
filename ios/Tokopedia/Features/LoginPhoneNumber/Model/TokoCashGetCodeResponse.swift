//
//  TokoCashGetCodeResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 08/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TokoCashGetCodeResponse {
    let responseCode: String
    let code: String
    
    init(responseCode: String, code:String){
        self.responseCode = responseCode
        self.code = code
    }
    
    init(json: JSON){
        let responseCode = json["code"].stringValue
        let code = json["data"]["code"].stringValue
        self.init(responseCode: responseCode, code: code)
    }
}
