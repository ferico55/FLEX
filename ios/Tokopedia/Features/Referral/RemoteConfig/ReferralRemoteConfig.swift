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
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "iosapp_show_app_share_button")
                DispatchQueue.main.async {
                    onCompletion(value.boolValue)
                }
            }
        })
    }
    internal func checkIfBranchLinkActive(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "iosapp_activate_branch_links")
                onCompletion(value.boolValue)
            }
        })
    }
    internal func getAppShareDescription(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_share_description")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        })
    }
    internal func getShareCodeScreenContent(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_refferal_content")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        })
    }
    internal func getAppReferralTitle(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_referral_title")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        })
    }
    internal func getHowReferralWorksLink(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_referral_howitworks")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        })
    }
    internal func getWelcomeScreenContent(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_share_welcome_message")
                DispatchQueue.main.async {
                    onCompletion(value.stringValue ?? "")
                }
            }
        })
    }
    internal func showReferralCode(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_show_referral_button")
                DispatchQueue.main.async {
                    onCompletion(value.boolValue)
                }
            }
        })
    }
}
