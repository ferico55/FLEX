//
//  ListOption.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 6/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit
import Unbox

struct Filters {
    var filters: [ListOption] = []
    var sort : ListOption = ListOption()
}

class ListOption: NSObject, TKPObjectMapping, NSCopying, Unboxable {
    
    var name : String = ""
    var value : String?
    var key : String = "sc"
    var input_type : String = ""
    var isSelected : Bool = false
    var applinks: String = ""
    var iconImageUrl: String?
    var weight: String?
    var parent: String?
    var tree: String? = "1"
    var has_catalog :String?
    var identifier :String?
    var url : String?
    var child : [ListOption]?
    var isExpanded : Bool = false
    var isLastCategory : Bool? {
        didSet{
            if let _ = self.child {
                self.isLastCategory = true
            } else {
                self.isLastCategory = false
            }
        }
    }
    var hasChildCategories : Bool? {
        didSet{
            if let _ = self.child {
                self.hasChildCategories = false
            } else {
                self.hasChildCategories = true
            }
        }
    }
    
    //Use value rather than d_id or department_id or categoryID
    var categoryId :String? {
        didSet {
            value = categoryId
        }
    }
    var d_id :String? {
        didSet {
            value = d_id!
        }
    }
    var department_id :String? {
        didSet {
            value = department_id!
        }
    }
    
    //Use name rather than title or department_name
    var title :String? {
        didSet {
            name = title!
        }
    }
    var department_name :String? {
        didSet {
            name = department_name!
        }
    }
    
    var isNewCategory :Bool = false
    
    
    required override init() {
    }
    
    required init(_ model: ListOption) {
        name = model.name
        key = model.key
        input_type = model.input_type
        value = model.value
        categoryId = model.categoryId
        isSelected = model.isSelected
        weight = model.weight
        parent = model.parent
        tree = model.tree
        has_catalog = model.has_catalog
        identifier = model.identifier
        url = model.url
        child = model.child
        isExpanded = model.isExpanded
        isLastCategory = model.isLastCategory
        hasChildCategories = model.hasChildCategories
    }
    
    func copy(with zone: NSZone?) -> Any {
        return type(of: self).init(self)
    }
    
    static func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return [
            "name"          :"name",
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
            "department_id" :"department_id",
            "input_type"    :"input_type",
            "key"           :"key",
            "value"         :"value"
        ]
    }
    
    static func mapping() -> RKObjectMapping! {
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
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        self.value = try? unboxer.unbox(keyPath: "value") ?? unboxer.unbox(keyPath: "id")
        self.name = try unboxer.unbox(keyPath: "name")
        self.weight = try? unboxer.unbox(keyPath: "weight")
        self.parent = try? unboxer.unbox(keyPath: "parent")
        self.tree = try? unboxer.unbox(keyPath: "tree")
        self.has_catalog = try? unboxer.unbox(keyPath: "has_catalog")
        self.identifier = try? unboxer.unbox(keyPath: "identifier")
        self.url = try? unboxer.unbox(keyPath: "url")
        self.categoryId = try? unboxer.unbox(keyPath: "id")
        self.d_id = try? unboxer.unbox(keyPath: "d_id")
        self.title = try? unboxer.unbox(keyPath: "title")
        self.department_name = try? unboxer.unbox(keyPath: "department_name")
        self.department_id = try? unboxer.unbox(keyPath: "department_id")
        self.child = try? unboxer.unbox(keyPath: "child")
        self.applinks = try unboxer.unbox(keyPath: "applinks")
        self.iconImageUrl = try? unboxer.unbox(keyPath: "icon_image_url")
        self.hasChildCategories = try? unboxer.unbox(keyPath: "has_child")
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let object = object as? ListOption,
            object.value == value && object.key == key {
            if object.isNewCategory && isNewCategory {
                return true
            } else if object.tree == tree {
                return true
            }
        }
        return false
    }

}
