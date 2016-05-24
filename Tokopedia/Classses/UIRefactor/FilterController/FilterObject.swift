//
//  FilterObjects.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class FilterType: NSObject {
    
    var Category: NSNumber = 0
    var Etalase: NSNumber = 1
    var Shop: NSNumber = 2
    var Location: NSNumber = 3
    var Condition: NSNumber = 4
    var Price: NSNumber = 5
    var shipment: NSNumber = 6
    var preorder : NSNumber = 7
}


class FilterObject: NSObject, NSCopying {
    
    var filterID : NSString = "0"
    var title : NSString = ""
    var isSelected : Bool = false
    
    required override init() {
    }
    
    required init(_ model: FilterObject) {
        filterID = model.filterID
        title = model.title
        isSelected = model.isSelected
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
}

class FilterPrice: NSObject, NSCopying {
    
    var priceMin:String = "0"
    var priceMax:String = "0"
    var priceWholesale: Bool = false
    
    required override init() {
    }
    
    required init(_ model: FilterPrice) {
        priceMin = model.priceMin
        priceMax = model.priceMax
        priceWholesale = model.priceWholesale
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
}

class QueryObject: NSObject, NSCopying {
    
    var selectedCategory:[CategoryDetail] = []
    var selectedEtalase:EtalaseList = EtalaseList()
    var selectedShop:[FilterObject] = []
    var selectedLocation:[FilterObject] = []
    var selectedPrice : FilterPrice = FilterPrice()
    var selectedCondition : [FilterObject] = []
    var selectedShipping : [FilterObject] = []
    var selectedPreorder:[FilterObject] = []
    
    required override init() {
    }
    
    required init(_ model: QueryObject) {
        selectedCategory = model.selectedCategory
        selectedEtalase = model.selectedEtalase
        selectedShop = model.selectedShop
        selectedLocation = model.selectedLocation
        selectedPrice = model.selectedPrice
        selectedCondition = model.selectedCondition
        selectedShipping = model.selectedShipping
        selectedPreorder = model.selectedPreorder
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
}