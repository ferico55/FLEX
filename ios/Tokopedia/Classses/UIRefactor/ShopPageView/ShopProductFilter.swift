//
//  ShopProductFilter.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 1/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ShopProductFilter: NSObject {
    var query = ""
    var orderBy = ""
    var page = 1
    var etalaseId = ""
    var isGetListProductToAce = false
    
    class func fromUrlQuery(_ dictionary: [AnyHashable: Any]) -> ShopProductFilter {
        let filter = ShopProductFilter()
        filter.query = dictionary["keyword"] as? String ?? ""
        filter.orderBy = dictionary["sort"] as? String ?? ""
        filter.page = dictionary["page"] as? Int ?? 1
        filter.etalaseId = dictionary["etalaseId"] as? String ?? ""
        
        return filter
    }
}
