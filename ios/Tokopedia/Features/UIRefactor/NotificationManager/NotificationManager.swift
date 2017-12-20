//
//  NotificationManager.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import RxSwift

@objc protocol NotificationManagerDelegate {
    @objc optional func notificationManager(_ notificationManager: Any, notificationLoaded notification: Any)
}

class NotificationManager: NSObject {
    
    @objc var delegate: NotificationManagerDelegate? = nil
    
    var notification: NotificationData? = nil
    
    override init() {
        super.init()
        
        // add observer for clearing notification cache (in case logout)
        NotificationCenter.default.addObserver(self, selector: #selector(clearCache), name: NSNotification.Name(rawValue: "clearCacheNotificationBar"), object: nil)
    }
    
    func clearCache() {
        let cacheManager = NotificationCache.sharedManager
        cacheManager.pruneCache()
    }
    
    @objc func loadNotifications() {
        // get from cache first
        let cacheManager = NotificationCache.sharedManager
        cacheManager.loadNotification { [weak self] (notificationData) in
            guard let `self` = self else {
                return
            }
            
            self.notification = notificationData
            self.delegate?.notificationManager?(self, notificationLoaded: notificationData)
            self.loadNotificationsFromRemote()
        }
    }
    
    func loadNotificationsFromRemote() {
        
        Observable.zip(requestNotifications(), requestChatUnreadCount()) { notification, chatUnreadData in
            return (notification, chatUnreadData)
        }.subscribe(onNext: {[weak self] (notification, chatUnreadData) in
            guard let `self` = self, let notification = notification else {
                return
            }
            
            if let chatUnreadData = chatUnreadData {
                // recalculate total notification
                let totalNotification = notification.totalNotif - (notification.inbox?.message ?? 0) + chatUnreadData.notificationUnread
                notification.totalNotif = totalNotification
                notification.inbox?.message = chatUnreadData.notificationUnread
            }
            
            // set to cache
            let cacheManager = NotificationCache.sharedManager
            cacheManager.storeNotification(notification)
            
            self.delegate?.notificationManager?(self, notificationLoaded: notification)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationUpdate"), object: nil, userInfo: ["count": notification.totalNotif, "isRead": notification.incrNotif <= 0])
        })
        .disposed(by: rx_disposeBag)
    }
    
    func requestChatUnreadCount() -> Observable<TopchatUnreadData?> {
        return NetworkProvider<TopchatTarget>()
            .request(.getUnreadCount)
            .mapJSON()
            .mapTo(object: TopchatUnreadData.self)
            .map({ (topchatUnreadData) -> TopchatUnreadData? in
                return topchatUnreadData
            })
            .catchError({ (error) -> Observable<TopchatUnreadData?> in
                return .just(nil)
            })
    }
    
    func requestNotifications() -> Observable<NotificationData?> {
        return NetworkProvider<NotificationTarget>()
            .request(.getNotifications)
            .mapJSON()
            .mapTo(object: NotificationData.self)
            .map({ (notificationData) -> NotificationData? in
                return notificationData
            })
            .catchError({ (error) -> Observable<NotificationData?> in
                return .just(nil)
            })
    }
    
    func resetNotifications() {
        let cacheManager = NotificationCache.sharedManager
        cacheManager.loadNotification { (notificationData) in
            guard let notificationData = notificationData else {
                return
            }
            
            notificationData.incrNotif = 0
            cacheManager.storeNotification(notificationData)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationRead"), object: nil)
        }
        
        _ = NetworkProvider<NotificationTarget>()
            .request(.resetNotifications)
            .subscribe()
            .disposed(by: rx_disposeBag)
    }
}
