//
//  LoginPreference.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 24/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
class LoginPreference {
    var touchIdPopShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "isTouchIdPopShown")
        }
        set(isShown) {
            UserDefaults.standard.set(isShown, forKey: "isTouchIdPopShown")
            UserDefaults.standard.synchronize()
        }
    }
}
