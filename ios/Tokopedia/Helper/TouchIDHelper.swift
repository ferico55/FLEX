//
//  TouchIDHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 2/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import KeychainAccess
import LocalAuthentication
import UIKit

public struct KeychainAccessService {
    public static let account = "Account"
    public static let touchAccount = "TouchAccount"
    public static let creditCard = "CreditCard"
}

public struct KeychainAccessKey {
    public static let numberAccounts = "NumberAccounts"
    public static let email = "Email"
    public static let password = "Password"
    public static let creditCard = "CreditCardDatas"
}

private var globalPriorityDefaultQueue: DispatchQueue {
    return DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
}

@objc
public protocol TouchIDHelperDelegate: class {
    @objc optional func touchIDHelperActivationSucceed(_ helper: TouchIDHelper)
    @objc optional func touchIDHelperActivationFailed(_ helper: TouchIDHelper)
    @objc optional func touchIDHelper(_ helper: TouchIDHelper, loadSucceedForEmail email: String, andPassword password: String)
    @objc optional func touchIDHelperLoadFailed(_ helper: TouchIDHelper)
}

@objc(TouchIDHelper)
public class TouchIDHelper: NSObject {
    
    public static let sharedInstance = TouchIDHelper()
    public weak var delegate: TouchIDHelperDelegate?
    
    private let maximumConnectedAccounts: Int = 5
    
    public func numberOfConnectedAccounts() -> Int {
        let keychainAccount = Keychain(service: KeychainAccessService.account)
        let items = keychainAccount.allItems()
        
        return items.count
    }
    
    public func saveTouchID(forEmail email: String, password: String) {
        
        // check if saved touch id is already on limit
        if self.numberOfConnectedAccounts() > self.maximumConnectedAccounts {
            return
        }
        
        globalPriorityDefaultQueue.async(execute: { () -> Void in
            do {
                let keychainAccount = Keychain(service: KeychainAccessService.account)
                keychainAccount[email] = email
                
                let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
                
                if #available(iOS 9.0, *) {
                    try keychainTouch.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .touchIDAny)
                        .authenticationPrompt("Otentikasikan dengan \(NSString.authenticationType()) sebagai password")
                        .set(password, key: email)
                } else {
                    // Fallback on earlier versions
                    try keychainTouch.accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                        .authenticationPrompt("Otentikasikan dengan \(NSString.authenticationType()) sebagai password")
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
    
    public func updateTouchID(forEmail email: String, password: String) {
        globalPriorityDefaultQueue.async(execute: { () -> Void in
            do {
                let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
                
                if #available(iOS 9.0, *) {
                    try keychainTouch
                        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .touchIDAny)
                        .authenticationPrompt("Otentikasikan dengan \(NSString.authenticationType()) untuk memperbarui password Anda.")
                        .set(password, key: email)
                } else {
                    // Fallback on earlier versions
                    try keychainTouch
                        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: .userPresence)
                        .authenticationPrompt("Otentikasikan dengan \(NSString.authenticationType()) untuk memperbarui password Anda.")
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
    
    public func loadTouchIDAccount() -> [String] {
        let keychainAccount = Keychain(service: KeychainAccessService.account)
        let items = keychainAccount.allKeys()
        let emails = items.flatMap { $0 }
        
        return emails
    }
    
    public func loadTouchID(withEmail email: String) {
        globalPriorityDefaultQueue.async(execute: { () -> Void in
            do {
                let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
                
                let password = try keychainTouch
                    .authenticationPrompt("Otentikasikan dengan \(NSString.authenticationType()) sebagai password")
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
    
    public func isTouchIDAvailable() -> Bool {
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
    
    public func isTouchIDExist(withEmail email: String) -> Bool {
        let emails: [String] = self.loadTouchIDAccount()
        
        if emails.contains(email) {
            return true
        }
        
        return false
    }
    
    public func remove(forEmail email: String) {
        let keychainTouch = Keychain(service: KeychainAccessService.touchAccount)
        let keychainAccount = Keychain(service: KeychainAccessService.account)
        
        do {
            try keychainTouch.remove(email)
            try keychainAccount.remove(email)
        } catch let error {
            print(error)
        }
    }
    
    public func removeAll() {
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
