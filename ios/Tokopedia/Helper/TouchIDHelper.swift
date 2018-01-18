//
//  TouchIDHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 2/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import KeychainAccess
import LocalAuthentication

struct KeychainAccessService {
    static let account = "Account"
    static let touchAccount = "TouchAccount"
    static let creditCard = "CreditCard"
}

struct KeychainAccessKey {
    static let numberAccounts = "NumberAccounts"
    static let email = "Email"
    static let password = "Password"
    static let creditCard = "CreditCardDatas"
}

var GlobalPriorityDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
}

@objc
protocol TouchIDHelperDelegate: class {
    
    @objc optional func touchIDHelperActivationSucceed(_ helper: TouchIDHelper)
    @objc optional func touchIDHelperActivationFailed(_ helper: TouchIDHelper)
    @objc optional func touchIDHelper(_ helper: TouchIDHelper, loadSucceedForEmail email: String, andPassword password: String)
    @objc optional func touchIDHelperLoadFailed(_ helper: TouchIDHelper)
}

@objc(TouchIDHelper)
class TouchIDHelper: NSObject {
    
    static let sharedInstance = TouchIDHelper()
    weak var delegate: TouchIDHelperDelegate?
    
    let maximumConnectedAccounts: Int = 5
    
    func numberOfConnectedAccounts() -> Int {
        let keychainAccount = Keychain(service: KeychainAccessService.account)
        let items = keychainAccount.allItems()
        
        return items.count
    }
    
    func saveTouchID(forEmail email: String, password: String) {
        
        // check if saved touch id is already on limit
        if self.numberOfConnectedAccounts() > self.maximumConnectedAccounts {
            return
        }
        
        GlobalPriorityDefaultQueue.async(execute: { () -> Void in
            do {
                let keychainAccount = Keychain(service: KeychainAccessService.account)
                keychainAccount[email] = email
                
                let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
                
                if #available(iOS 9.0, *) {
                    try keychainTouch.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .touchIDAny)
                        .authenticationPrompt("Otentikasikan dengan touch ID sebagai password")
                        .set(password, key: email)
                } else {
                    // Fallback on earlier versions
                    try keychainTouch.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                        .authenticationPrompt("Otentikasikan dengan touch ID sebagai password")
                        .set(password, key: email)
                }
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate?.touchIDHelperActivationSucceed?(self)
                })
                
            } catch let error {
                // Error handling if needed...
                print(error.localizedDescription)
                
                let keychainAccount = Keychain(service: KeychainAccessService.account)
                keychainAccount[email] = nil
                
                DispatchQueue.main.async(execute: { () -> Void in
                    self.delegate?.touchIDHelperActivationFailed?(self)
                })
            }
        })
    }
    
    func updateTouchID(forEmail email: String, password: String) {
        GlobalPriorityDefaultQueue.async(execute: { () -> Void in
            do {
                let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
                
                if #available(iOS 9.0, *) {
                    try keychainTouch
                        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .touchIDAny)
                        .authenticationPrompt("Otentikasikan dengan Touch ID untuk memperbarui password anda.")
                        .set(password, key: email)
                } else {
                    // Fallback on earlier versions
                    try keychainTouch
                        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                        .authenticationPrompt("Otentikasikan dengan Touch ID untuk memperbarui password anda.")
                        .set(password, key: email)
                }
                
            } catch let error {
                // Error handling if needed...
                print(error.localizedDescription)
                
                let keychainAccount = Keychain(service: KeychainAccessService.account)
                keychainAccount[email] = nil
            }
        })
    }
    
    func loadTouchIDAccount() -> [String] {
        let keychainAccount = Keychain(service: KeychainAccessService.account)
        let items = keychainAccount.allKeys()
        let emails = items.flatMap { $0 }
        
        return emails
    }
    
    func loadTouchID(withEmail email: String) {
        GlobalPriorityDefaultQueue.async(execute: { () -> Void in
            do {
                let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
                
                let password = try keychainTouch
                    .authenticationPrompt("Otentikasikan dengan Touch ID sebagai password")
                    .get(email)
                
                DispatchQueue.main.async(execute: { () -> Void in
                    if let password = password {
                        self.delegate?.touchIDHelper?(self, loadSucceedForEmail: email, andPassword: password)
                    }
                })
                
            } catch let error as NSError {
                switch Status(status: OSStatus(error.code)) {
                case .userCanceled:
                    break
                default:
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.delegate?.touchIDHelperLoadFailed?(self)
                    })
                }
            }
        })
    }
    
    func isTouchIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            return true
        }
        
        if let error = error as? LAError,
            error.code == LAError.touchIDLockout {
            return true
        }
        
        self.removeAll()
        return false
    }
    
    func isTouchIDExist(withEmail email: String) -> Bool {
        let emails: [String] = self.loadTouchIDAccount()
        
        if emails.contains(email) {
            return true
        }
        
        return false
    }
    
    func remove(forEmail email: String) {
        let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
        let keychainAccount = Keychain(service: KeychainAccessService.account)
        
        do {
            try keychainTouch.remove(email)
            try keychainAccount.remove(email)
        } catch let error {
            print(error)
        }
    }
    
    func removeAll() {
        let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
        let keychainAccount = Keychain(service: KeychainAccessService.account)
        
        do {
            try keychainTouch.removeAll()
            try keychainAccount.removeAll()
        } catch let error {
            print(error)
        }
    }
    
}
