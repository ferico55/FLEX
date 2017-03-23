//
//  PulsaRelationships.swift
//  Tokopedia
//
//  Created by Tonito Acen on 11/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class PulsaRelationships: NSObject, NSCoding {
    var relationCategory : PulsaRelationCategory = PulsaRelationCategory()
    var relationOperator : PulsaRelationOperator = PulsaRelationOperator()
    
    static func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        let categoryMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "category", toKeyPath: "relationCategory", with: PulsaRelationCategory.mapping())
        mapping.addPropertyMapping(categoryMapping)
        
        let operatorMapping : RKRelationshipMapping = RKRelationshipMapping(fromKeyPath: "operator", toKeyPath: "relationOperator", with: PulsaRelationOperator.mapping())
        mapping.addPropertyMapping(operatorMapping)
        
        return mapping
    }
    
    // MARK: NSCoding
    override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let relationCategory = aDecoder.decodeObject(forKey:"relationCategory") as? PulsaRelationCategory {
            self.relationCategory = relationCategory
        }
        
        if let relationOperator = aDecoder.decodeObject(forKey:"relationOperator") as? PulsaRelationOperator {
            self.relationOperator = relationOperator
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(relationCategory as Any?, forKey: "relationCategory")
        aCoder.encode(relationOperator as Any?, forKey: "relationOperator")
    }
}
