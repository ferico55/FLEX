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
        
        self.timeTaken = Date()
        
        let alert = self.screenshotAlertView()
        
        alert.onTapShare = { [weak self] (sender) in
            guard let `self` = self else { return }
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: GA_EVENT_ACTION_CLICK, label: "Share")
            self.shareImage(image!, fromViewController: self.topViewController, withSender: sender)
        }
        
        alert.onTapReport = { [weak self] _ in
            guard let `self` = self else { return }
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: GA_EVENT_ACTION_CLICK, label: "Report")
            self.sendEmailWithAttachment(image: image!, fromViewController: self.topViewController, timeTaken: self.timeTaken)
        }
        
        alert.onTapClose = { _ in
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: GA_EVENT_ACTION_CLICK, label: "Close")
        }
        
        alert.setImage(image!)
        alert.show()
    }
    
    private func screenshotAlertView() -> ScreenshotAlertView {
        if self.screenshotAlert == nil {
            self.screenshotAlert = ScreenshotAlertView.newview() as? ScreenshotAlertView
        }
        
        return self.screenshotAlert!
    }
    
    private func shareImage(_ image: UIImage, fromViewController viewController: UIViewController, withSender sender: Any) {
        let controller = UIActivityViewController.share(with: image, anchor: sender as! UIView)
        
        if viewController.navigationController != nil {
            viewController.navigationController?.present(controller!, animated: true, completion: nil)
        } else {
            self.tabBarController.present(controller!, animated: true, completion: nil)
        }
    }
    
    private func sendEmailWithAttachment(image: UIImage, fromViewController viewController: UIViewController, timeTaken: Date) {
        if MFMailComposeViewController.canSendMail() {
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: "Report", label: "Can Send Report")
            let userManager = UserAuthentificationManager()
            let email = (userManager.getUserEmail() == "0") ? "[PENGGUNA BELUM LOGIN]" : userManager.getUserEmail()
            
            let emailController = MFMailComposeViewController()
            emailController.mailComposeDelegate = self
            
            let jpegData = UIImageJPEGRepresentation(image, 1.0)
            
            var fileName: NSString = "App_Screenshot"
            fileName = fileName.appendingPathExtension("jpeg")! as NSString
            emailController.addAttachmentData(jpegData!, mimeType: "image/jpeg", fileName: fileName as String)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy, HH:mm:ss a"
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
            let currentTime = dateFormatter.string(from: timeTaken)
            
            let messageBody = "<b>Device:</b> \(UIDevice.current.modelName) <br/> <b>iOS Version:</b> \(UIDevice.current.systemVersion) <br/> <b>Email Tokopedia:</b> \(email ?? "") <br/> <b>App Version:</b> \(UIApplication.getAppVersionString()) <br/> <b>Waktu:</b> \(currentTime) <br/><br/> <b>Tulis laporan kamu di sini:</b> "
            
            emailController.setSubject("Laporan Screenshot")
            emailController.setMessageBody(messageBody, isHTML: true)
            emailController.setToRecipients(["ios.feedback@tokopedia.com"])
            emailController.navigationBar.tintColor = UIColor.white
            
            if viewController.navigationController != nil {
                viewController.navigationController?.present(emailController, animated: true, completion:nil)
            } else {
                self.tabBarController.present(emailController, animated: true, completion: nil)
            }
        } else {
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: "Report", label: "Can't Send Report")
            StickyAlertView.showErrorMessage(["Silakan login terlebih dahulu di aplikasi email pada perangkat yang Anda gunakan sebelum menggunakan fitur ini."])
        }
    }
}

extension ScreenshotHelper: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .sent:
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: "Report", label: "Sent")
            break
        case .saved:
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: "Report", label: "Saved")
            break
        case .failed:
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: "Report", label: "Failed")
            break
        case .cancelled:
            AnalyticsManager.trackEventName("clickScreenshot", category: GA_EVENT_CATEGORY_SCREENSHOT, action: "Report", label: "Cancelled")
            break
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
}
