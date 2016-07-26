//
//  UIApplicationCategory.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

@objc
class UIApplicationCategory: NSObject {
    class func getAppVersionStringWithoutDot() -> String {
        var appVersion: String = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        appVersion = appVersion.stringByReplacingOccurrencesOfString(".", withString: "")
        return appVersion
    }
    
    class func getAppVersionString() -> String {
        let appVersion: String = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
        return appVersion
    }
}
