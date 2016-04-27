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
}


class FilterObject: NSObject {
    
    var filterID : NSString = "0"
    var title : NSString = ""
    
}

class FilterPrice: NSObject {
    
    var priceMin:String = ""
    var priceMax:String = ""
    var priceGrosir: Bool = false
}

class QueryObject: NSObject {
    
    var selectedCategory:CategoryDetail = CategoryDetail()
    var selectedEtalase:EtalaseList = EtalaseList()
    var selectedShop:FilterObject = FilterObject()
    var selectedLocation:FilterObject = FilterObject()
    var selectedPrice : FilterPrice = FilterPrice()
    var selectedCondition : FilterObject = FilterObject()
}