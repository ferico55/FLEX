//
//  SystemBank.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/9/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class SystemBank: NSObject {
    
    var bankId     = ""
    var bankName   = ""
    
    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(forClass: self)
        mapping.addAttributeMappingsFromDictionary([
            "bank_id":"bankId",
            "bank_name":"bankName"
            ])
        
        return mapping
    }

}
