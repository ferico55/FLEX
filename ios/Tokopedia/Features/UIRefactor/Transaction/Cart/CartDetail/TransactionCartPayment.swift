//
//  TransactionCartPayment.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 8/30/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc class TransactionCartPayment: NSObject {
    var url = ""
    var callbackUrl = ""
    var queryString = ""
    var parameter:[String:String]? = nil
}
