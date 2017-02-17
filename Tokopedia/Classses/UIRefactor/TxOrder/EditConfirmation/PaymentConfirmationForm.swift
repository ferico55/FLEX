//
//  PaymentConfirmationForm.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PaymentConfirmationForm: NSObject {
    
    var user_acc_no     = ""
    var user_acc_name   = ""
    var system_bank_id  = ""
    var payment_id      = ""
    var comment         = ""
    var system_bank_list : [SystemBank] = []
    
    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from:[
            "user_acc_no",
            "user_acc_name",
            "system_bank_id"
            ])
        mapping?.addRelationshipMapping(withSourceKeyPath: "system_bank_list", mapping: SystemBank.mapping())
        
        return mapping!
    }

}
