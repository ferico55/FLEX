//
//  LogEntriesHelper.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/23/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import LogEntries

class LogEntriesHelper: NSObject {
    private class func logOnLogEntries(data: Any) {
        guard let data = data as? NSObject, let logger = LELog.sharedInstance() else {
            return
        }
        
        logger.log(data)
    }
    
    class func logForceLogout(lastURL: String) {
        let data = [
            "event": "FORCE_LOGOUT",
            "userID": UserAuthentificationManager().getUserId(),
            "email": UserAuthentificationManager().getUserEmail(),
            "device": UIDevice.current.modelName,
            "ios_version": UIDevice.current.systemVersion,
            "device_token": UserAuthentificationManager().getMyDeviceToken(),
            "url": lastURL,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
        ]
        
        self.logOnLogEntries(data: data)
    }
}
