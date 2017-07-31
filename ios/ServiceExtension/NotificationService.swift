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
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler:@escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)        
        
        let notificationData = request.content.userInfo["data"] as? [String : String]
        
        if notificationData != nil {
            self.handleTransactionalNotification(request)
        } else {
            self.handleMoEngageNotification(request, andContentHandler: contentHandler)
        }
    }
    
    // Handle notification from MoEngage
    private func handleMoEngageNotification(_ request: UNNotificationRequest, andContentHandler contentHandler:@escaping (UNNotificationContent) -> Void) {
        MORichNotification.enableDebugging(true)
        MORichNotification.getAttachmentFrom(request, withCompletionBlock: { (attachment) in
            if let att = attachment {
                self.bestAttemptContent?.attachments = [att]
            }
            
            if let bestAttemptContent = self.bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
        })
    }
    
    // Handle notification from Tokopedia
    private func handleTransactionalNotification(_ request: UNNotificationRequest) {
        if let bestAttemptContent = bestAttemptContent,
            let notificationData = request.content.userInfo["data"] as? [String: String],
            let urlString = notificationData["attachment-url"],
            let fileUrl = URL(string: urlString) {
            URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
                if let location = location {
                    let tmpDirectory = NSTemporaryDirectory()
                    let tmpFile = "file://\(tmpDirectory)\((fileUrl.lastPathComponent))"
                    
                    let tmpUrl = URL(string: tmpFile)!
                    
                    _ = try? FileManager.default.moveItem(at: location, to: tmpUrl)
                    
                    if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl, options: nil) {
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
