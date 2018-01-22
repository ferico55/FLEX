//
//  Bundle+Extensions.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 22/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
