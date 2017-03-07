//
//  PulsaProductAttribute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaProductAttribute: NSObject, NSCoding {
    var desc : String = ""
    var info : String = ""
    var detail : String = ""
    var detail_url : String = ""
    var price : String = ""
    var status : Int = 1
    var weight : Int = 1
    var promo : PulsaProductPromo?
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "desc"  : "desc",
            "info"  : "info",
            "detail"  : "detail",
            "detail_url"  : "detail_url",
            "price"  : "price",
            "status"  : "status",
            "weight" : "weight"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "promo", toKeyPath: "promo", with: PulsaProductPromo.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let desc = aDecoder.decodeObject(forKey: "desc") as? String {
            self.desc = desc
        }
        
        if let info = aDecoder.decodeObject(forKey: "info") as? String {
            self.info = info
        }
        
        if let detail = aDecoder.decodeObject(forKey: "detail") as? String {
            self.detail = detail
        }
        
        if let detail_url = aDecoder.decodeObject(forKey: "detail_url") as? String {
            self.detail_url = detail_url
        }
        
        if let price = aDecoder.decodeObject(forKey: "price") as? String {
            self.price = price
        }
        
        if let status = aDecoder.decodeObject(forKey: "status") as? Int {
            self.status = status
        }
        
        if let weight = aDecoder.decodeObject(forKey: "weight") as? Int {
            self.weight = weight
        }
        
        if let promo = aDecoder.decodeObject(forKey:"promo") as? PulsaProductPromo {
            self.promo = promo
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(desc as Any?, forKey: "desc")
        aCoder.encode(weight as Any?, forKey: "weight")
        aCoder.encode(info as Any?, forKey: "info")
        aCoder.encode(detail as Any?, forKey: "detail")
        aCoder.encode(detail_url as Any?, forKey: "detail_url")
        aCoder.encode(price as Any?, forKey: "price")
        aCoder.encode(status as Any?, forKey: "status")
        aCoder.encode(promo as Any?, forKey: "promo")
    }
}
