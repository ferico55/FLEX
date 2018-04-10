//
//  ACRemoteConfig.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 21/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import FirebaseRemoteConfig
import UIKit
internal class ACRemoteConfig: NSObject {
    private var remoteConfig: RemoteConfig?
    internal override init() {
        super.init()
        self.remoteConfig = RemoteConfig.remoteConfig()
    }
    internal func isAudio(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        let value = remoteConfig.configValue(forKey: "audio_campaign_is_audio")
        onCompletion(value.boolValue)
    }
    internal func isShakeEnabled(onCompletion: @escaping (Bool)->Void) {
        guard let remoteConfig = self.remoteConfig else {
            onCompletion(false)
            return
        }
        let value = remoteConfig.configValue(forKey: "app_shake_feature_enabled")
        onCompletion(value.boolValue && self.isTimeBoundShake())
    }
    internal func timeBoundShake() {
        UserDefaults.standard.set(Date(timeIntervalSinceNow:2) , forKey: "ShakeForAudioDisabled")
        UserDefaults.standard.synchronize()
    }
    private func isTimeBoundShake()->Bool {
        if let date = UserDefaults.standard.object(forKey: "ShakeForAudioDisabled") as? Date {
            return !(date.timeIntervalSinceNow > 0)
        } else {
            return true
        }
    }
}
