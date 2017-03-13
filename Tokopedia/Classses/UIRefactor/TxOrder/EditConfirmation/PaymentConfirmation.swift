//
//  PaymentConfirmation.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PaymentConfirmation: NSObject {
    
    var form : PaymentConfirmationForm = PaymentConfirmationForm()
    
    class func mapping() -> RKObjectMapping{
        let mapping = RKObjectMapping(for: self)
        mapping?.addRelationshipMapping(withSourceKeyPath: "form", mapping: PaymentConfirmationForm.mapping())
        
        return mapping!
    }

}
