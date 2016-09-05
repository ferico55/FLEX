//
//  ProductResolutionViewModel.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProductResolutionViewModel: NSObject {
    
    var productImageURLString : String = ""
    var productName : String = ""
    var productTrouble: String = ""
    var productTroubleDescription: String = ""
    var isFreeReturn : Bool = true
    var productQuantity : String = ""
    
    var maxQuantity : String = "1"
    var minQuantity : String = "0"
    
    var isSelected : Bool = false
    
    var troubleTypeList : [ResolutionCenterCreateTroubleList] = []
}
