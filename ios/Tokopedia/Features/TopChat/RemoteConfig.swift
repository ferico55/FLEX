//
//  RemoteConfig.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 21/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import FirebaseRemoteConfig

extension RemoteConfig {
    var topchatEnabled: Bool {
        return self["enable_topchat"].boolValue
    }
}
