//
//  QueryObject.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class QueryObject: NSObject {
    
    var selectedCategory:CategoryDetail = CategoryDetail()
    var selectedEtalase:EtalaseList = EtalaseList()
    var selectedShop:FilterObject=FilterObject()
    var selectedLocation:FilterObject=FilterObject()
    var selectedPrice : FilterObject = FilterObject()
    var selectedCondition : FilterObject = FilterObject()
}
