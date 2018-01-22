//
//  NativeNPSManager.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 08/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import React

@objc(NativeNPSManager)
class NativeNPSManager: NSObject {
    
    @objc func showNPS() -> Void {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kTKPD_SHOW_RATING_ALERT), object: nil)
    }
}

