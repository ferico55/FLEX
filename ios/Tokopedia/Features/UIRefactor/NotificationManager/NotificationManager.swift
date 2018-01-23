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

class NotificationManager: NSObject {
    
    static let sharedManager = NotificationManager()
    
    override init() {
        super.init()
        
        // add observer for clearing notification cache (in case logout)
        NotificationCenter.default.addObserver(self, selector: #selector(clearCache), name: NSNotification.Name(rawValue: "clearCacheNotificationBar"), object: nil)
        
        // add observer for reloading notification in case receiving push notification
        NotificationCenter.default.addObserver(self, selector: #selector(loadNotifications), name: NSNotification.Name(rawValue: TokopediaNotificationReload), object: nil)
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
            if let notification = notificationData {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationLoaded"), object: nil, userInfo: ["notification": notification])
            }
            self.loadNotificationsFromRemote()
        }
    }
    
    func loadNotificationsFromRemote() {
        
        Observable.zip(requestNotifications(), requestChatUnreadCount(), requestSellerInfoNotifications()) { notification, chatUnreadData, sellerInfoData in
            return (notification, chatUnreadData, sellerInfoData)
        }.subscribe(onNext: {[weak self] (notification, chatUnreadData, sellerInfoData) in
            guard let `self` = self, let notification = notification else {
                return
            }
            
            if let chatUnreadData = chatUnreadData {
                // recalculate total notification
                let totalNotification = notification.totalNotif - (notification.inbox?.message ?? 0) + chatUnreadData.notificationUnread
                notification.totalNotif = totalNotification
                notification.inbox?.message = chatUnreadData.notificationUnread
            }
            
            if let sellerInfoData = sellerInfoData {
                let notif = sellerInfoData.notificationUnread
                
                // only increment seller info data if user has shop
                if UserAuthentificationManager().userHasShop() {
                    notification.totalNotif     += notif
                }
                notification.sellerInfoNotif = notif
            }
            
            // set to cache
            let cacheManager = NotificationCache.sharedManager
            cacheManager.storeNotification(notification)
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NotificationLoaded"), object: nil, userInfo: ["notification": notification])
        })
        .disposed(by: rx_disposeBag)
    }
    
    func requestSellerInfoNotifications() -> Observable<SellerInfoNotificationData?> {
        return NetworkProvider<SellerInfoTarget>()
            .request(.getNotifications)
            .mapJSON()
            .mapTo(object: SellerInfoNotificationData.self)
            .map({ (sellerInfoNotificationData) -> SellerInfoNotificationData? in
                return sellerInfoNotificationData
            })
            .catchError({ (error) -> Observable<SellerInfoNotificationData?> in
                return .just(nil)
            })
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
