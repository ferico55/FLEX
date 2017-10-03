//
//  ReferralRemoteConfig.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 20/09/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig
class ReferralRemoteConfig: NSObject {
    static let shared = ReferralRemoteConfig()
    private var remoteConfig: RemoteConfig?
    private var expirationDuration: TimeInterval = 10800; //3 hours
    var isBranchLinkActive: Bool = {
        if UserDefaults.standard.value(forKeyPath: "isBranchLinkActive") == nil {
            return true
        }
        return UserDefaults.standard.bool(forKey: "isBranchLinkActive")
    }()
    override init() {
        super.init()
        self.remoteConfig = RemoteConfig.remoteConfig()
        self.checkIfBranchLinkActive(onCompletion: { (isActive: Bool) in
            UserDefaults.standard.set(isActive, forKey: "isBranchLinkActive")
            UserDefaults.standard.synchronize()
        })
    }
    func shouldShowAppShare(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "iosapp_show_app_share_button")
                onCompletion(value.boolValue)
            }
        })
    }
    func checkIfBranchLinkActive(onCompletion: @escaping (Bool)->Void) {
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
    func getAppShareDescription(onCompletion: @escaping (String)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion("")
            return
        }
        remoteConfig.fetch(completionHandler: { (status: RemoteConfigFetchStatus, error: Error?) in
            if status == .success {
                let value = remoteConfig.configValue(forKey: "app_share_description")
                    onCompletion(value.stringValue ?? "")
            }
        })
    }
}
