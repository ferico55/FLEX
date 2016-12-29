//
//  PulsaRelationships.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaRelationships: NSObject, NSCoding {
    var relationCategory : PulsaRelationCategory = PulsaRelationCategory()
    var relationOperator : PulsaRelationOperator = PulsaRelationOperator()
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(forClass: self)
        
        let categoryMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "category", toKeyPath: "relationCategory", withMapping: PulsaRelationCategory.mapping())
        mapping.addPropertyMapping(categoryMapping)
        
        let operatorMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "operator", toKeyPath: "relationOperator", withMapping: PulsaRelationOperator.mapping())
        mapping.addPropertyMapping(operatorMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let relationCategory = aDecoder.decodeObjectForKey("relationCategory") as? PulsaRelationCategory {
            self.relationCategory = relationCategory
        }
        
        if let relationOperator = aDecoder.decodeObjectForKey("relationOperator") as? PulsaRelationOperator {
            self.relationOperator = relationOperator
        }
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(relationCategory, forKey: "relationCategory")
        aCoder.encodeObject(relationOperator, forKey: "relationOperator")
    }
}
