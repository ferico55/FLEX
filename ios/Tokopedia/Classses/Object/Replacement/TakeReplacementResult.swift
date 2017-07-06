//
//  TakeReplacementResult.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class TakeReplacementResult: Unboxable {
    
    var orderId: String!
    var status: Int!
    var message: String?
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            orderId: try unboxer.unbox(key:"order_id"),
            status: try unboxer.unbox(key:"status"),
            message: try? unboxer.unbox(key:"message")
        )
    }
    
    init(orderId: String, status: Int, message: String? ) {
        self.orderId = orderId
        self.status = status
        self.message = message
    }
}
