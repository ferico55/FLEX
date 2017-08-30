//
//  ScreenshotHelper.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ScreenshotHelper: NSObject {
    
    private var screenshotAlert: ScreenshotAlertView?
    private let tabBarController: UITabBarController!
    private var topViewController: UIViewController!
    
    private var timeTaken: Date = Date()
    
    init(tabBarController: UITabBarController, topViewController: UIViewController) {
        self.tabBarController = tabBarController
        self.topViewController = topViewController
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func takeScreenshot() {
        let window = UIApplication.shared.keyWindow
        UIGraphicsBeginImageContextWithOptions((window?.bounds.size)!, true, 0)
        window?.drawHierarchy(in: (window?.bounds)!, afterScreenUpdates: true)
        window?.endEditing(true)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let img = image else { return }
        
        self.timeTaken = Date()
        
        let alert = self.screenshotAlertView()
        
        alert.onTapShare = { [weak self] sender in
            guard let `self` = self else { return }
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: GA_EVENT_ACTION_CLICK, label: "Share")
            self.share(image: img, fromViewController: self.topViewController, withSender: sender)
        }
        
        alert.onTapClose = { _ in
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: GA_EVENT_ACTION_CLICK, label: "Close")
        }
        
        alert.setImage(img)
        alert.show()
    }
    
    private func screenshotAlertView() -> ScreenshotAlertView {
        if self.screenshotAlert == nil {
            self.screenshotAlert = ScreenshotAlertView.newview() as? ScreenshotAlertView
        }
        
        return self.screenshotAlert!
    }
    
    private func share(image: UIImage, fromViewController viewController: UIViewController, withSender sender: Any) {
        let controller = UIActivityViewController.share(with: image, anchor: sender as! UIView)
        
        if viewController.navigationController != nil {
            viewController.navigationController?.present(controller!, animated: true, completion: nil)
        } else {
            self.tabBarController.present(controller!, animated: true, completion: nil)
        }
    }
}
