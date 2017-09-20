//
//  VersionChecker.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 9/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

private enum remoteKey: String {
    case latestVersion = "iosapp_latest_version_code"
    case needUpdate = "iosapp_is_need_update"
    case forceUpdate = "iosapp_is_force_update"
    case alertTitle = "iosapp_update_title"
    case alertMessage = "iosapp_update_message"
    case updateLink = "iosapp_update_link"
    case isQaTesting = "iosapp_qa_now_testing"
}

@objc (VersionChecker)
class VersionChecker : NSObject {
    private let remoteConfig: RemoteConfig
    private var expirationDuration: TimeInterval = 10800; //3 hours
    
    override init(){
        remoteConfig = RemoteConfig.remoteConfig()
        let versionCheckerConfig : VersionCheckerConfig = VersionCheckerConfig()
        
        if versionCheckerConfig.isUsingDevMode == true {
            expirationDuration = 0
            remoteConfig.configSettings = RemoteConfigSettings(developerModeEnabled: true)!
        }
        
        let appDefaults : [String : NSObject]  = [
            "iosapp_update_link":"https://itunes.apple.com/id/app/tokopedia-jual-beli-online/id1001394201?mt=8" as NSObject,
            "iosapp_update_title":"Tersedia Versi Terbaru" as NSObject,
            "iosapp_update_message":"Update tokopedia versi terbaru untuk medapatkan pengalaman berbelanja yang lebih baik" as NSObject,
            "iosapp_is_force_update":"false" as NSObject
        ]
        
        remoteConfig.setDefaults(appDefaults)
    }

    func checkForceUpdate(){
        remoteConfig.fetch(withExpirationDuration: expirationDuration){
        (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activateFetched()
            }
            else{
                print("not Fetched")
                print("Error \(error!.localizedDescription)")
            }
            
            let forceUpdate = self.remoteConfig[remoteKey.forceUpdate.rawValue].boolValue

            let alertTitle = self.remoteConfig[remoteKey.alertTitle.rawValue].stringValue ?? ""
            let alertMessage = self.remoteConfig[remoteKey.alertMessage.rawValue].stringValue ?? ""
            let updateLink = self.remoteConfig[remoteKey.updateLink.rawValue].stringValue ?? ""

            if forceUpdate {
                self.presentAlert(title: alertTitle, message: alertMessage, link: updateLink)
            }
        }
    }
    
    private func presentAlert(title: String, message: String, link: String){
        AnalyticsManager.trackEventName("impressionAppUpdate", category: GA_EVENT_CATEGORY_FORCE_UPDATE_ALERT, action: GA_EVENT_ACTION_VIEW, label: "Alert Force Update Appear")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let confirmAction = UIAlertAction(title: "Update", style: .default) { (_) in
            if let url = URL(string: link) {
                AnalyticsManager.trackEventName("clickAppUpdate", category: GA_EVENT_CATEGORY_FORCE_UPDATE_ALERT, action: GA_EVENT_ACTION_CLICK , label: "Button Update Clicked")
                UIApplication.shared.openURL(url)
                exit(0)
            }
        }

        let cancelAction = UIAlertAction(title: "Tutup", style: .cancel) { (_) in
            AnalyticsManager.trackEventName("clickCancelAppUpdate", category: GA_EVENT_CATEGORY_FORCE_UPDATE_ALERT, action: GA_EVENT_ACTION_CLICK , label: "Button Tutup Clicked")
            exit(0)
        }

        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)

        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
}
