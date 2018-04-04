//
//  ReferralRemoteConfig.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 20/09/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import FirebaseRemoteConfig
import UIKit
internal class ReferralRemoteConfig: NSObject {
    internal static let shared = ReferralRemoteConfig()
    private var remoteConfig: RemoteConfig?
    private var expirationDuration: TimeInterval = 10800; //3 hours
    internal var isBranchLinkActive: Bool = {
        if UserDefaults.standard.value(forKeyPath: "isBranchLinkActive") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "isBranchLinkActive")
    }()
    override internal init() {
        super.init()
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.checkIfBranchLinkActive(onCompletion: { (isActive: Bool) in
            UserDefaults.standard.set(isActive, forKey: "isBranchLinkActive")
            UserDefaults.standard.synchronize()
        })
    }
    internal func shouldShowAppShare(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "iosapp_show_app_share_button")
                DispatchQueue.main.async {
                    onCompletion(value.boolValue)
                }
            }
        }
    }
    internal func checkIfBranchLinkActive(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "iosapp_activate_branch_links")
                onCompletion(value.boolValue)
            }
        }
    }
    internal func getAppShareDescription(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_share_description")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        }
    }
    internal func getShareCodeScreenContent(onCompletion: @escaping (String)->Void) {
        let defaultValue = "Ayo share kode ini ke temanmu dan nikmati bonus TokoCash setelah transaksi pertama mereka berhasil."
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(defaultValue)
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_refferal_content")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? defaultValue)
                }
            } else {
                onCompletion(defaultValue)
            }
        }
    }
    internal func getogTitle(onCompletion: @escaping (String)->Void) {
        let defaultValue = "Beli & Bayar Ini Itu Mudah, Bonus Cashback s.d 30rb"
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(defaultValue)
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "referral_og_title")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? defaultValue)
                }
            } else {
                onCompletion(defaultValue)
            }
        }
    }
    internal func getogDescription(onCompletion: @escaping (String)->Void) {
        let defaultValue = "Cobain mudahnya penuhi semua kebutuhan harianmu lewat Aplikasi Tokopedia, yuk! Download sekarang & nikmati cashback s.d 30rb untuk transaksi pertamamu. Kode: "
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(defaultValue)
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "referral_og_description")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? defaultValue)
                }
            } else {
                onCompletion(defaultValue)
            }
        }
    }
    internal func getAppReferralTitle(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_referral_title")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        }
    }
    internal func getHowReferralWorksLink(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_referral_howitworks")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        }
    }
    internal func getWelcomeScreenContent(onCompletion: @escaping (String)->Void) {
        let defaultValue = "Hai%s, kamu mendapatkan kode referral dari %s. Gunakan kode ini saat transaksi pertamamu di Tokopedia & nikmati bonus cashback ke TokoCash."
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(defaultValue)
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_share_welcome_message")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? defaultValue)
                }
            }
        }
    }
    internal func showReferralCode(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        remoteConfig.fetch(withExpirationDuration: self.expirationDuration) { (status, error) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_show_referral_button")
                DispatchQueue.main.async {
                    onCompletion(value.boolValue)
                }
            }
        }
    }
}
