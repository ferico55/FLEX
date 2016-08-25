//
//  PulsaCache.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

class PulsaCache: NSObject {
    let cacheIdentifier: String = "com.tokopedia.pulsa"
    var cache: SPTPersistentCache!
    
    override init()  {
        let cachePath = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true).first! .stringByAppendingString(cacheIdentifier)
        
        let cacheOption = SPTPersistentCacheOptions.init(
                            cachePath: cachePath,
                            identifier: cacheIdentifier,
                            defaultExpirationInterval: 24*60*60,
                            garbageCollectorInterval: (1*SPTPersistentCacheDefaultGCIntervalSec)) { (string: String) in
            
                            }
        self.cache = SPTPersistentCache.init(options: cacheOption)
    }
    
    func storeCategories(category: PulsaCategoryRoot) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(category)
        self.cache .
            storeData(data,
              forKey: "categories", ttl: 24*60*60,
              locked: false,
              withCallback: { (response: SPTPersistentCacheResponse) in

              },
              onQueue: dispatch_get_main_queue())
    }
    
    func loadCategories(loadCategoryCallBack: (category: PulsaCategoryRoot?) -> ()) {
        self.cache .
            loadDataForKey("categories",
               withCallback: { (response: SPTPersistentCacheResponse) in
                    if(response.record.data.length != 0) {
                        let category = NSKeyedUnarchiver.unarchiveObjectWithData(response.record.data) as! PulsaCategoryRoot
                        return loadCategoryCallBack(category: category)
                    } else {
                        return loadCategoryCallBack(category: nil)
                    }
                
               },
               onQueue: dispatch_get_main_queue())
    }
    
    func storeOperators(op: PulsaOperatorRoot) {
        let data = NSKeyedArchiver.archivedDataWithRootObject(op)
        self.cache .
            storeData(data,
                      forKey: "operators", ttl: 24*60*60,
                      locked: false,
                      withCallback: { (response: SPTPersistentCacheResponse) in
                        
                },
                      onQueue: dispatch_get_main_queue())
    }
    
    func loadOperators(loadOperatorCallBack: (op: PulsaOperatorRoot?) -> ()) {
        self.cache .
            loadDataForKey("operators",
                           withCallback: { (response: SPTPersistentCacheResponse) in
                            if(response.record.data.length != 0) {
                                let operators = NSKeyedUnarchiver.unarchiveObjectWithData(response.record.data) as! PulsaOperatorRoot
                                return loadOperatorCallBack(op: operators)
                            } else {
                                return loadOperatorCallBack(op: nil)
                            }
                            
                },
                           onQueue: dispatch_get_main_queue())
    }
}
