//
//  DeviceIdentifier.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import KeychainAccess

class DeviceIdentifier: NSObject {
    private static let keychainService = "TokopediaKeychainService"
    private static let keychainKey = "UniqueId"
    
    static let deviceId: String = {
        let keychain = Keychain(service: keychainService)
        
        if let token = keychain[keychainKey] {
            return token
        }
        else {
            let uuidString = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            keychain[keychainKey] = uuidString
            return uuidString
        }
    }()
}
