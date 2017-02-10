//
//  NotificationService.swift
//  ServiceExtension
//
//  Created by Tonito Acen on 1/16/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceiveNotificationRequest(request: UNNotificationRequest, withContentHandler contentHandler: (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        let localyticsImageUrl = self.bestAttemptContent?.userInfo["ll_attachment_url"]
        let localyticsImageType = self.bestAttemptContent?.userInfo["ll_attachment_type"]
        
        if (localyticsImageUrl == nil || localyticsImageType == nil) {
            self.handleTransactionalNotification(request)
        } else {
            self.handleLocalyticsNotification(request)
        }
    }
    
    private func handleLocalyticsNotification(request: UNNotificationRequest) {
        if let bestAttemptContent = bestAttemptContent,
            let attachmentUrl = bestAttemptContent.userInfo["ll_attachment_url"] as? String,
            let fileUrl  = NSURL(string: attachmentUrl) {
            NSURLSession.sharedSession().downloadTaskWithURL(fileUrl) { (location, response, error) in
                if let location = location {
                    let tmpDirectory = NSTemporaryDirectory()
                    let tmpFile = "file://\(tmpDirectory)\((fileUrl.lastPathComponent)!)"
                    
                    let tmpUrl = NSURL(string: tmpFile)!
                    
                    _ = try? NSFileManager.defaultManager().moveItemAtURL(location, toURL: tmpUrl)
                    
                    if let attachment = try? UNNotificationAttachment(identifier: "", URL: tmpUrl, options: nil) {
                        bestAttemptContent.attachments = [attachment]
                    }
                }
                self.contentHandler?(bestAttemptContent)
                }.resume()
        }
    }

    //handle notification from Tokopedia
    private func handleTransactionalNotification(request: UNNotificationRequest) {
        if let bestAttemptContent = bestAttemptContent,
            let notificationData = request.content.userInfo["data"] as? [String: String],
            let urlString = notificationData["attachment-url"],
            let fileUrl = NSURL(string: urlString) {
            NSURLSession.sharedSession().downloadTaskWithURL(fileUrl) { (location, response, error) in
                if let location = location {
                    let tmpDirectory = NSTemporaryDirectory()
                    let tmpFile = "file://\(tmpDirectory)\((fileUrl.lastPathComponent)!)"
                    
                    let tmpUrl = NSURL(string: tmpFile)!
                    
                    _ = try? NSFileManager.defaultManager().moveItemAtURL(location, toURL: tmpUrl)
                    
                    if let attachment = try? UNNotificationAttachment(identifier: "", URL: tmpUrl, options: nil) {
                        bestAttemptContent.attachments = [attachment]
                    }
                }
                self.contentHandler?(bestAttemptContent)
                }.resume()
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
