//
//  UIApplicationCategory.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

extension UIApplication {
    class func getAppVersionStringWithoutDot() -> String {
        var appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        appVersion = appVersion.replacingOccurrences(of: ".", with: "")
        return appVersion
    }
    
    class func getAppVersionString() -> String {
        let appVersion: String = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        return appVersion
    }
}
