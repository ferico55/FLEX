//
//  SortCache.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 05/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import SPTPersistentCache

class SortCache: NSObject {
    
    private var kSortKey = "sort"
    private var cache: SPTPersistentCache = {
        let cacheIdentifier: String = "com.tokopedia.sort-\(UIApplication.getAppVersionStringWithoutDot())"
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + cacheIdentifier
        
        let cacheOption = SPTPersistentCacheOptions()
        cacheOption.cachePath = cachePath
        cacheOption.cacheIdentifier = cacheIdentifier
        cacheOption.defaultExpirationPeriod = UInt(24 * 60 * 60)
        cacheOption.garbageCollectionInterval = 1 * SPTPersistentCacheDefaultGCIntervalSec
        
        return SPTPersistentCache(options: cacheOption)
    }()
    
    func storeSortData(_ sort: [ListOption], source: Source) {
        let data = NSKeyedArchiver.archivedData(withRootObject: sort)
        self.cache.store(data,
                         forKey: getStoreKey(source: source), ttl: 24 * 60 * 60,
                         locked: false,
                         withCallback: nil,
                         on: DispatchQueue.main)
    }
    
    func loadSortData(source: Source, callBack loadSortCallBack: @escaping (_ sort: [ListOption]?) -> Void) {
        if !CacheTweaks.shouldCacheSortRequest() {
            self.pruneCache()
        }
        
        self.cache.loadData(forKey: self.getStoreKey(source: source),
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record else {
                                    return loadSortCallBack(nil)
                                }
                                
                                let sort = NSKeyedUnarchiver.unarchiveObject(with: record.data) as! [ListOption]
                                return loadSortCallBack(sort)
                            },
                            on: DispatchQueue.main)
    }
    
    private func pruneCache() {
        self.cache.prune(callback: nil, on: DispatchQueue.main)
    }
    
    private func getStoreKey(source: Source) -> String {
        return self.kSortKey + source.description()
    }
}

