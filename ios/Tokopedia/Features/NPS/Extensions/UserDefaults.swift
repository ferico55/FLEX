//
//  UserDefaults.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 22/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

private let LAST_VERSION_NPS_RATED = "lastVersionNPSRated"

@objc
extension UserDefaults {
    
    var lastVersionNPSRated: String? {
        get {
            return UserDefaults.standard.string(forKey: LAST_VERSION_NPS_RATED)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: LAST_VERSION_NPS_RATED)
        }
    }
}
