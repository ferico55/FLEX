//
//  RemoteConfig.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 12/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import FirebaseRemoteConfig

extension RemoteConfig {
    var shouldShowForbiddenScreen: Bool {
        return !self["iosapp_disable_forbidden_screen"].boolValue
    }
}
