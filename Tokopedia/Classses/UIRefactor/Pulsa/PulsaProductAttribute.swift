//
//  PulsaProductAttribute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaProductAttribute: NSObject, NSCoding {
    var desc : String = ""
    var info : String = ""
    var detail : String = ""
    var detail_url : String = ""
    var price : String = ""
    var status : Int = 1
    var weight : Int = 1
    var promo : PulsaProductPromo?
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
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
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relMapping : RKRelationshipMapping = RKRelationshipMapping.init(fromKeyPath: "promo", toKeyPath: "promo", withMapping: PulsaProductPromo.mapping())
        mapping.addPropertyMapping(relMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let desc = aDecoder.decodeObjectForKey("desc") as? String {
            self.desc = desc
        }
        
        if let info = aDecoder.decodeObjectForKey("info") as? String {
            self.info = info
        }
        
        if let detail = aDecoder.decodeObjectForKey("detail") as? String {
            self.detail = detail
        }
        
        if let detail_url = aDecoder.decodeObjectForKey("detail_url") as? String {
            self.detail_url = detail_url
        }
        
        if let price = aDecoder.decodeObjectForKey("price") as? String {
            self.price = price
        }
        
        if let status = aDecoder.decodeObjectForKey("status") as? Int {
            self.status = status
        }
        
        if let weight = aDecoder.decodeObjectForKey("weight") as? Int {
            self.weight = weight
        }
        
        if let promo = aDecoder.decodeObjectForKey("promo") as? PulsaProductPromo {
            self.promo = promo
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(desc, forKey: "desc")
        aCoder.encodeObject(weight, forKey: "weight")
        aCoder.encodeObject(info, forKey: "info")
        aCoder.encodeObject(detail, forKey: "detail")
        aCoder.encodeObject(detail_url, forKey: "detail_url")
        aCoder.encodeObject(price, forKey: "price")
        aCoder.encodeObject(status, forKey: "status")
        aCoder.encodeObject(promo, forKey: "promo")
    }
}
