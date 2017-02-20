//
//  WalletAction.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class WalletAction: NSObject {
    var text: String = ""
    var redirect_url: String = ""
    var type: String = ""
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:[
            "text" : "text",
            "redirect_url" : "redirect_url",
            "type" : "type"
            ])
        
        return mapping
    }
}
