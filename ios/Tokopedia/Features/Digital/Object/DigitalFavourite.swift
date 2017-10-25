//
//  DigitalFavourite.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class DigitalFavourite : NSObject {
    let categoryID:String?
    let operatorID:String?
    let productID:String?
    let clientNumber:String?
    let name:String?
    
    init(categoryID:String? = nil, operatorID:String? = nil, productID:String? = nil, clientNumber:String? = nil, name:String? = nil) {
        self.categoryID = categoryID
        self.operatorID = operatorID
        self.productID = productID
        self.clientNumber = clientNumber
        self.name = name
    }
}

extension DigitalFavourite : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> DigitalFavourite {
        let json = JSON(source)
        
        let categoryID = json["relationships"]["category"]["data"]["id"].stringValue
        let operatorID = json["relationships"]["operator"]["data"]["id"].stringValue
        let productID = json["attributes"]["last_product"].stringValue
        let clientNumber = json["attributes"]["client_number"].stringValue
        let name = json["attributes"]["label"].stringValue
        
        return DigitalFavourite(categoryID: categoryID, operatorID: operatorID, productID: productID, clientNumber: clientNumber, name: name)
    }
}
