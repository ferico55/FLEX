//
//  UserDefaultsCategory.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 8/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

private let IS_INSTANT_PAYMENT_ENABLED = "isInstantPaymentEnabled"

@objc
extension UserDefaults {

    var isInstantPaymentEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: IS_INSTANT_PAYMENT_ENABLED)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: IS_INSTANT_PAYMENT_ENABLED)
        }
    }
}
