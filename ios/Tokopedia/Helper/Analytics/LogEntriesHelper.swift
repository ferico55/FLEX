//
//  LogEntriesHelper.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 11/23/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import LogEntries

internal class LogEntriesHelper: NSObject {
    private class func logOnLogEntries(data: Any) {
        guard let data = data as? NSObject, let logger = LELog.sharedInstance() else {
            return
        }
        
        logger.log(data)
    }
    
    internal class func logShowMaintenance(event: String, lastURL: String?, statusCode: Int) {
        var url = lastURL ?? ""
        let data = [
            "event": event,
            "url": url,
            "response_code": String(statusCode)
        ]
        self.logOnLogEntries(data: data)
    }
    
    internal class func logForceLogout(lastURL: String) {
        guard let loginData = UserAuthentificationManager().getUserLoginData() else {
            return
        }
        
        let userID = UserAuthentificationManager().getUserId() ?? "0"
        let email = UserAuthentificationManager().getUserEmail() ?? "0"
        let deviceToken = UserAuthentificationManager().getMyDeviceToken()
        let refreshToken = loginData["oAuthToken.refreshToken"] as? String ?? ""
        
        if userID == "0" || email == "0" || deviceToken == "0" {
            return
        }
        
        var buildMode = ""
        #if DEBUG
            buildMode = "DEBUG"
        #else
            buildMode = "RELEASE"
        #endif
        
        let data = [
            "event": "FORCE_LOGOUT",
            "buildMode": buildMode,
            "userID": userID,
            "email": email,
            "device": UIDevice.current.modelName,
            "ios_version": UIDevice.current.systemVersion,
            "device_token": deviceToken,
            "url": lastURL,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "",
            "refresh_token": refreshToken,
        ]
        
        self.logOnLogEntries(data: data)
    }
}
