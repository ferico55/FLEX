//
//  PulsaCache.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import SPTPersistentCache
import UIKit

public class PulsaCache: NSObject {
    private let cacheIdentifier: String = "com.tokopedia.pulsa-\(UIApplication.getAppVersionStringWithoutDot())"
    private var cache: SPTPersistentCache!
    
    public override init() {
        guard var cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        cachePath += cacheIdentifier
        
        let cacheOption = SPTPersistentCacheOptions()
        cacheOption.cachePath = cachePath
        cacheOption.cacheIdentifier = cacheIdentifier
        cacheOption.defaultExpirationPeriod = UInt(1 * 60 * 60)
        cacheOption.garbageCollectionInterval = 1 * SPTPersistentCacheDefaultGCIntervalSec
        
        self.cache = SPTPersistentCache(options: cacheOption)
        
    }
    
    internal func storeCategories(_ category: PulsaCategoryRoot) {
        let data = NSKeyedArchiver.archivedData(withRootObject: category)
        
        self.cache.store(data,
                         forKey: "categories", ttl: 1 * 60 * 60,
                         locked: false,
                         withCallback: { (_: SPTPersistentCacheResponse) in
                            
                         },
                         on: DispatchQueue.main)
    }
    
    internal func loadCategories(_ loadCategoryCallBack: @escaping (_ category: PulsaCategoryRoot?) -> Void) {
        let shouldCache = CacheTweaks.shouldCachePulsaRequest()
        if !shouldCache {
            self.pruneCache()
        }
        
        self.cache.loadData(forKey: "categories",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record, let category = NSKeyedUnarchiver.unarchiveObject(with: record.data) as? PulsaCategoryRoot else {
                                    return loadCategoryCallBack(nil)
                                }
                                return loadCategoryCallBack(category)
                            },
                            on: DispatchQueue.main)
    }
    
    internal func storeOperators(_ operators: PulsaOperatorRoot) {
        let data = NSKeyedArchiver.archivedData(withRootObject: operators)
        self.cache.store(data,
                         forKey: "operators", ttl: 1 * 60 * 60,
                         locked: false,
                         withCallback: { (_: SPTPersistentCacheResponse) in
                            
                         },
                         on: DispatchQueue.main)
    }
    
    internal func loadOperators(_ loadOperatorCallBack: @escaping (_ op: PulsaOperatorRoot?) -> Void) {
        let shouldCache = CacheTweaks.shouldCachePulsaRequest()
        if !shouldCache {
            self.pruneCache()
        }
        
        self.cache.loadData(forKey: "operators",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record, let operators = NSKeyedUnarchiver.unarchiveObject(with: record.data) as? PulsaOperatorRoot else {
                                    return loadOperatorCallBack(nil)
                                }
                                return loadOperatorCallBack(operators)
                                
                            },
                            on: DispatchQueue.main)
    }
    
    internal func storeProducts(_ product: PulsaProductRoot) {
        let data = NSKeyedArchiver.archivedData(withRootObject: product)
        self.cache.store(data,
                         forKey: "products", ttl: 1 * 60 * 60,
                         locked: false,
                         withCallback: { (_: SPTPersistentCacheResponse) in
                            
                         },
                         on: DispatchQueue.main)
    }
    
    fileprivate func pruneCache() {
        self.cache.prune(callback: { _ in
            
        }, on: DispatchQueue.main)
    }
    
    internal func loadProducts(_ loadProductCallBack: @escaping (_ product: PulsaProductRoot?) -> Void) {
        if !CacheTweaks.shouldCachePulsaRequest() {
            self.pruneCache()
        }
        
        self.cache.loadData(forKey: "products",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record, let products = NSKeyedUnarchiver.unarchiveObject(with: record.data) as? PulsaProductRoot else {
                                    return loadProductCallBack(nil)
                                }
                                return loadProductCallBack(products)
                                
                            },
                            on: DispatchQueue.main)
    }
    
    internal func storeLastOrder(lastOrder: DigitalLastOrder) {
        let isLogin = UserAuthentificationManager().isLogin
        if isLogin {
            let data = NSKeyedArchiver.archivedData(withRootObject: lastOrder)
            self.cache.store(data,
                             forKey: lastOrder.categoryId,
                             locked: true,
                             withCallback: nil,
                             on: DispatchQueue.main)
        }
    }
    
    internal func loadLastOrder(categoryId: String, loadLastOrderCallBack: @escaping (_ lastOrder: DigitalLastOrder?) -> Void) {
        let shouldCache = CacheTweaks.shouldCachePulsaRequest()
        if !shouldCache {
            self.pruneCache()
        }
        
        self.cache.loadData(forKey: categoryId,
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record, let products = NSKeyedUnarchiver.unarchiveObject(with: record.data) as? DigitalLastOrder else {
                                    return loadLastOrderCallBack(nil)
                                }
                                return loadLastOrderCallBack(products)
                                
        }, on: DispatchQueue.main)
    }
    
    internal func clearLastOrder() {
        self.cache.wipeLockedFiles(callback: nil, on: DispatchQueue.main)
    }
}
