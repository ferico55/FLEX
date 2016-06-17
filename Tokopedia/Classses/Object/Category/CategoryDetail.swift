//
//  CategoryDetail.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class CategoryDetail: NSObject, NSCopying {

    var d_id :String = String() {
        didSet {
            categoryId = d_id
        }
    }
    //MARK : Use categoryId rather than d_id
    var categoryId : String = String()
    var title :String = String(){
        didSet {
            name = title
        }
    }
    //MARK : Use name rather than title
    var name: String = String() 
    var weight : String = String()
    var parent: String = String()
    var tree :String = String()
    var has_catalog :String = String()
    var identifier :String = String()
    var url : String = String()
    var child : [CategoryDetail] = []
    var isExpanded : Bool = false
    var isLastCategory : Bool = false {
        didSet{
            if self.child.count == 0 {
            self.isLastCategory = true
            } else {
            self.isLastCategory = false
            }
        }
    }
    var hasChildCategories : Bool = true {
        didSet{
            if self.child.count == 0 {
                self.hasChildCategories = false
            } else {
                self.hasChildCategories = true
            }
        }
    }
    var isSelected : Bool = false
    
    required override init() {
    }
    
    required init(_ model: CategoryDetail) {
        self.categoryId = model.categoryId
        self.name = model.name
        self.weight = model.weight
        self.parent = model.parent
        self.tree = model.tree
        self.has_catalog = model.has_catalog
        self.identifier = model.identifier
        self.url = model.url
        self.child = model.child
        self.isExpanded = model.isExpanded
        self.isLastCategory = model.isLastCategory
        self.hasChildCategories = model.hasChildCategories
        self.isSelected = model.isSelected
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
    
    private class func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["name":"name",
                "weight":"weight",
                "parent":"parent",
                "tree":"tree",
                "has_catalog":"has_catalog",
                "identifer":"identifer",
                "url":"url",
                "id":"categoryId",
                "d_id" : "d_id",
                "title":"title"
        ]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let childmapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        childmapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let lastmapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        lastmapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let relChildMapping = RKRelationshipMapping.init(fromKeyPath: "child", toKeyPath: "child", withMapping: childmapping)
        mapping.addPropertyMapping(relChildMapping)
        
        let relLastChildMapping = RKRelationshipMapping.init(fromKeyPath: "child", toKeyPath: "child", withMapping: lastmapping)
        childmapping.addPropertyMapping(relLastChildMapping)
        
        return mapping
    }

}