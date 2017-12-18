//
//  PulsaCache.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import SPTPersistentCache

class PulsaCache: NSObject {
    let cacheIdentifier: String = "com.tokopedia.pulsa-\(UIApplication.getAppVersionStringWithoutDot())"
    var cache: SPTPersistentCache!
    
    override init()  {
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + cacheIdentifier
        
        let cacheOption = SPTPersistentCacheOptions()
        cacheOption.cachePath = cachePath
        cacheOption.cacheIdentifier = cacheIdentifier
        cacheOption.defaultExpirationPeriod = UInt(24 * 60 * 60)
        cacheOption.garbageCollectionInterval = 1*SPTPersistentCacheDefaultGCIntervalSec

        self.cache = SPTPersistentCache(options: cacheOption)
        
    }
    
    func storeCategories(_ category: PulsaCategoryRoot) {
        let data = NSKeyedArchiver.archivedData(withRootObject: category)
        
        self.cache.store(data,
                         forKey: "categories", ttl: 24*60*60,
                         locked: false,
                         withCallback: { (response: SPTPersistentCacheResponse) in
                            
        },
                         on: DispatchQueue.main)
    }
    
    func loadCategories(_ loadCategoryCallBack: @escaping (_ category: PulsaCategoryRoot?) -> Void) {
        if (!CacheTweaks.shouldCachePulsaRequest()) {
            pruneCache()
        }
        
        self.cache.loadData(forKey: "categories",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record else {
                                    return loadCategoryCallBack(nil)
                                }
                                
                                let category = NSKeyedUnarchiver.unarchiveObject(with: record.data) as! PulsaCategoryRoot
                                return loadCategoryCallBack(category)
        },
                            on: DispatchQueue.main)
    }
    
    func storeOperators(_ op: PulsaOperatorRoot) {
        let data = NSKeyedArchiver.archivedData(withRootObject: op)
        self.cache.store(data,
                         forKey: "operators", ttl: 24*60*60,
                         locked: false,
                         withCallback: { (response: SPTPersistentCacheResponse) in
                            
        },
                         on: DispatchQueue.main)
    }
    
    func loadOperators(_ loadOperatorCallBack: @escaping (_ op: PulsaOperatorRoot?) -> Void) {
        if (!CacheTweaks.shouldCachePulsaRequest()) {
            pruneCache()
        }
        
        self.cache.loadData(forKey: "operators",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record else {
                                    return loadOperatorCallBack(nil)
                                }
                                
                                let operators = NSKeyedUnarchiver.unarchiveObject(with: record.data) as! PulsaOperatorRoot
                                return loadOperatorCallBack(operators)
                                
        },
                            on: DispatchQueue.main)
    }
    
    func storeProducts(_ product: PulsaProductRoot) {
        let data = NSKeyedArchiver.archivedData(withRootObject: product)
        self.cache.store(data,
                         forKey: "products", ttl: 1*60*60,
                         locked: false,
                         withCallback: { (response: SPTPersistentCacheResponse) in
                            
        },
                         on: DispatchQueue.main)
    }
    
    fileprivate func pruneCache() {
        self.cache.prune(callback: { (response) in
            
        }, on: DispatchQueue.main)
    }
    
    func loadProducts(_ loadProductCallBack: @escaping (_ product: PulsaProductRoot?) -> Void) {
        if (!CacheTweaks.shouldCachePulsaRequest()) {
            pruneCache()
        }
        
        self.cache.loadData(forKey: "products",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record else {
                                    return loadProductCallBack(nil)
                                }
                                
                                let products = NSKeyedUnarchiver.unarchiveObject(with: record.data) as! PulsaProductRoot
                                return loadProductCallBack(products)
                                
        },
                            on: DispatchQueue.main)
    }
    
    func storeLastOrder(lastOrder:DigitalLastOrder) {
        if (UserAuthentificationManager().isLogin) {
            let data = NSKeyedArchiver.archivedData(withRootObject: lastOrder)
            self.cache.store(data,
                             forKey: lastOrder.categoryId,
                             locked: true,
                             withCallback: nil,
                             on: DispatchQueue.main)
        }
    }
    
    func loadLastOrder(categoryId:String, loadLastOrderCallBack: @escaping (_ lastOrder: DigitalLastOrder?) -> Void) {
        if (!CacheTweaks.shouldCachePulsaRequest()) {
            pruneCache()
        }
        
        self.cache.loadData(forKey: categoryId,
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record else {
                                    return loadLastOrderCallBack(nil)
                                }
                                
                                let products = NSKeyedUnarchiver.unarchiveObject(with: record.data) as! DigitalLastOrder
                                return loadLastOrderCallBack(products)
                                
        }, on: DispatchQueue.main)
    }
    
    func clearLastOrder() {
        self.cache.wipeLockedFiles(callback: nil, on: DispatchQueue.main)
    }
}
