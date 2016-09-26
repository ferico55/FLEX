//
//  CartShipmentData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/15/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class CartShipmentData: NSObject {
    
    var form : CartShipmentForm = CartShipmentForm()
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "form", toKeyPath: "form", withMapping: CartShipmentForm.mapping()))
        
        return mapping
    }

}
