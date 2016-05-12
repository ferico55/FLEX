//
//  PushNotificationSettingViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 5/12/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(PushNotificationSettingViewController)
class PushNotificationSettingViewController: UIViewController {
    @IBOutlet var switcher: UISwitch!
    
    @IBAction func switchValueChanged(settingSwitch: UISwitch) {
        if (settingSwitch.on) {
            JLNotificationPermission.sharedInstance().extraAlertEnabled = false
            JLNotificationPermission.sharedInstance().authorize({[unowned self] deviceId, error in
                let deniedCode = JLAuthorizationErrorCode.PermissionSystemDenied.rawValue
                if let errorCode = error?.code where errorCode == deniedCode {
                    guard #available(iOS 8, *) else { return }
                    let url = NSURL(string: UIApplicationOpenSettingsURLString)!
                    UIApplication.sharedApplication().openURL(url)
                }
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter()
            .addObserver(
                self,
                selector: #selector(applicationDidBecomeActive),
                name: UIApplicationDidBecomeActiveNotification,
                object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        toggleSwitch()
    }
    
    func toggleSwitch() {
        guard #available(iOS 8, *) else { return }
        
        let isPermissionAuthorized = JLNotificationPermission.sharedInstance().authorizationStatus() == .PermissionAuthorized
        
        
        let hasTurnedOnNotifications = UIApplication.sharedApplication()
            .currentUserNotificationSettings()!.types != .None
        
        let shouldEnableSwitch = isPermissionAuthorized && hasTurnedOnNotifications
        
        switcher.on = shouldEnableSwitch
    }
    
    
    func applicationDidBecomeActive(notification: NSNotification) {
        toggleSwitch()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
