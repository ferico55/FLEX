//
//  NotificationCache.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SPTPersistentCache

class NotificationCache: NSObject {
    private static let cacheIdentifier: String = "com.tokopedia.notification-\(UIApplication.getAppVersionStringWithoutDot())"
    
    private let cache: SPTPersistentCache = {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + cacheIdentifier
        
        let cacheOption = SPTPersistentCacheOptions()
        cacheOption.cachePath = cachePath
        cacheOption.cacheIdentifier = cacheIdentifier
        cacheOption.defaultExpirationPeriod = UInt(24 * 60 * 60)
        cacheOption.garbageCollectionInterval = 1 * SPTPersistentCacheDefaultGCIntervalSec
        
        return SPTPersistentCache(options: cacheOption)
    }()
    
    static let sharedManager = NotificationCache()
    
    func pruneCache() {
        self.cache.prune(callback: nil, on: DispatchQueue.main)
    }
    
    func storeNotification(_ notification: NotificationData) {
        let data = NSKeyedArchiver.archivedData(withRootObject: notification)
        self.cache.store(data,
                         forKey: "notifications", ttl: 24 * 60 * 60,
                         locked: false,
                         withCallback: nil,
                         on: DispatchQueue.main)
    }
    
    func loadNotification(_ loadNotificationCallBack: @escaping (_ notification: NotificationData?) -> Void) {
        self.cache.loadData(forKey: "notifications",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record else {
                                    return loadNotificationCallBack(nil)
                                }
                                
                                let notification = NSKeyedUnarchiver.unarchiveObject(with: record.data) as! NotificationData
                                return loadNotificationCallBack(notification)
                                
                            },
                            on: DispatchQueue.main)
    }
}
