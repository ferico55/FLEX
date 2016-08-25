//
//  PulsaOperatorAttribute.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaOperatorAttribute: NSObject, NSCoding {
    var name : String = ""
    var weight : Int = 0
    var image : String = ""
    var status : Int = 1
    var prefix: [String] = []
    var minimum_length: Int = 0
    var maximum_length: Int = 0
    
    static func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return [
            "name"  : "name",
            "weight" : "weight",
            "image" : "image",
            "status" : "status",
            "prefix" : "prefix",
            "minimum_length" : "minimum_length",
            "maximum_length" : "maximum_length",
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObjectForKey("name") as? String {
            self.name = name
        }
        
        if let weight = aDecoder.decodeObjectForKey("weight") as? Int {
            self.weight = weight
        }
        
        if let image = aDecoder.decodeObjectForKey("image") as? String {
            self.image = image
        }
        
        if let minimum_length = aDecoder.decodeObjectForKey("minimum_length") as? Int {
            self.minimum_length = minimum_length
        }
        
        if let maximum_length = aDecoder.decodeObjectForKey("maximum_length") as? Int {
            self.maximum_length = maximum_length
        }
        
        if let status = aDecoder.decodeObjectForKey("status") as? Int {
            self.status = status
        }
        
        if let prefix = aDecoder.decodeObjectForKey("prefix") as? [String] {
            self.prefix = prefix
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeObject(weight, forKey: "weight")
        aCoder.encodeObject(image, forKey: "image")
        aCoder.encodeObject(status, forKey: "status")
        aCoder.encodeObject(prefix, forKey: "prefix")
        aCoder.encodeObject(minimum_length, forKey: "minimum_length")
        aCoder.encodeObject(maximum_length, forKey: "maximum_length")
    }
}
