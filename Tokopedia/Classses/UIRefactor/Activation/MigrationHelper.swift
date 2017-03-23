//
//  MigrationHelper.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 3/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc (MigrationHelper)
class MigrationHelper: NSObject {
    
    static let sharedInstance = MigrationHelper()
    
    func prepareMigration() {
        
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            var previousVersion = "1.0"
            if let appVersion = UserDefaults.standard.value(forKey: "AppVersion") as? String {
                previousVersion = appVersion
            }
            
            if previousVersion.compare("1.98", options: String.CompareOptions.numeric) == .orderedAscending {
                migrateFromVersionBelow1_98()
            }
            
            UserDefaults.standard.setValue(currentVersion, forKey: "AppVersion")
        }
    }
    
    func migrateFromVersionBelow1_98() {
        QuickActionHelper.sharedInstance.registerShortcutItems()
    }
    
}
