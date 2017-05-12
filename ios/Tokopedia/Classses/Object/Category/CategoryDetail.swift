//
//  CategoryDetail.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 5/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

@objc class CategoryDetail: NSObject, NSCopying {
    //MARK : Use categoryId rather than d_id or department_id
    var categoryId : String = String()
    var d_id :String = String() {
        didSet {
            categoryId = d_id
        }
    }
    var department_id :String = String(){
        didSet {
            categoryId = department_id
        }
    }
    //
    
    //MARK : Use name rather than title or department_name
    var name: String = String()
    var title :String = String(){
        didSet {
            name = title
        }
    }
    var department_name :String = String(){
        didSet {
            name = department_name
        }
    }
    //
    
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
    
    func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(self)
    }
    
    fileprivate class func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["name"          :"name",
                "weight"        :"weight",
                "parent"        :"parent",
                "tree"          :"tree",
                "has_catalog"   :"has_catalog",
                "identifer"     :"identifer",
                "url"           :"url",
                "id"            :"categoryId",
                "d_id"          :"d_id",
                "title"         :"title",
                "department_name":"department_name",
                "department_id":"department_id"
        ]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from: self.attributeMappingDictionary())
        
        let childmapping : RKObjectMapping = RKObjectMapping(for: self)
        childmapping.addAttributeMappings(from: self.attributeMappingDictionary())
        
        let lastmapping : RKObjectMapping = RKObjectMapping(for: self)
        lastmapping.addAttributeMappings(from: self.attributeMappingDictionary())
        
        let relChildMapping = RKRelationshipMapping(fromKeyPath: "child", toKeyPath: "child", with: childmapping)
        mapping.addPropertyMapping(relChildMapping)
        
        let relLastChildMapping = RKRelationshipMapping(fromKeyPath: "child", toKeyPath: "child", with: lastmapping)
        childmapping.addPropertyMapping(relLastChildMapping)
        
        return mapping
    }

    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? CategoryDetail,
            object.categoryId == categoryId && object.tree == tree {
            return true
        } else {
            return false
        }
    }
}
