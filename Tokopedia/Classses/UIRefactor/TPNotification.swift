//
//  TPNotification.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/22/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import UserNotifications

class TPNotification: NSObject {
    
    static func showNotification(text:String,
                                          buttonTitle:String,
                                      userInfo:[String:Any],
                                      categoryIdentifier:String,
                                      requestIdentifier:String) {
        
        let notifType = UIApplication.shared.currentUserNotificationSettings?.types
        
        guard UIApplication.shared.isRegisteredForRemoteNotifications, notifType?.rawValue != 0 else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.showStickyNotif(text:text, buttonTitle:buttonTitle, userInfo: userInfo)
            }
            return
        }
        
        guard #available(iOS 10.0, *) else {
            self.showLocalNotificationWithText(text, userInfo: userInfo, categoryIdentifier: categoryIdentifier, requestIdentifier: requestIdentifier)
            return
        }
        
        self.showUserNotificationWithText(text, userInfo: userInfo, categoryIdentifier: categoryIdentifier, requestIdentifier: requestIdentifier)
    }
    
    private static func showStickyNotif(text:String, buttonTitle:String,
                                               userInfo:[String:Any]){
        
        UIViewController.showNotificationWithMessage(
            text,
            type:NotificationType.error.rawValue,
            duration: 10,
            buttonTitle: buttonTitle,
            dismissable: true) {
                
                TPRoutes.routeURL(URL(string:userInfo["url_deeplink"] as! String)!)
                
        }
    }
    
    @available(iOS 10.0, *)
    private static func showUserNotificationWithText(_ text:String,
                                      userInfo:[String:Any],
                                      categoryIdentifier:String,
                                      requestIdentifier:String) {
        
        let content = UNMutableNotificationContent()
        content.body = text
        content.userInfo = userInfo
        content.categoryIdentifier = categoryIdentifier
        
        // Deliver the notification in one seconds.
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1,
                                                        repeats: false)
        
        // Schedule the notification.
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
        
    }
    
    private static func showLocalNotificationWithText(_ text:String,
                                       userInfo:[String:Any],
                                       categoryIdentifier:String,
                                       requestIdentifier:String){
    
        let notification = UILocalNotification()
        notification.alertBody = text
        notification.category = categoryIdentifier
        notification.userInfo = userInfo
        notification.timeZone = NSTimeZone.default
        
        // Deliver the notification.
        UIApplication.shared.presentLocalNotificationNow(notification)
        
    }
}
