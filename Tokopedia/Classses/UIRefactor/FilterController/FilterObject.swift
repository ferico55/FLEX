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
    
    required override init() {
    }
    
    required init(_ model: FilterObject) {
        filterID = model.filterID
        title = model.title
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
}

class FilterPrice: NSObject, NSCopying {
    
    var priceMin:String = ""
    var priceMax:String = ""
    var priceGrosir: Bool = false
    
    required override init() {
    }
    
    required init(_ model: FilterPrice) {
        priceMin = model.priceMin
        priceMax = model.priceMax
        priceGrosir = model.priceGrosir
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
}

class QueryObject: NSObject, NSCopying {
    
    var selectedCategory:CategoryDetail = CategoryDetail()
    var selectedEtalase:EtalaseList = EtalaseList()
    var selectedShop:FilterObject = FilterObject()
    var selectedLocation:FilterObject = FilterObject()
    var selectedPrice : FilterPrice = FilterPrice()
    var selectedCondition : FilterObject = FilterObject()
    
    required override init() {
    }
    
    required init(_ model: QueryObject) {
        selectedCategory = model.selectedCategory
        selectedEtalase = model.selectedEtalase
        selectedShop = model.selectedShop
        selectedLocation = model.selectedLocation
        selectedPrice = model.selectedPrice
        selectedCondition = model.selectedCondition
    }
    
    func copyWithZone(zone: NSZone) -> AnyObject {
        return self.dynamicType.init(self)
    }
}