//
//  DigitalLastOrder.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class DigitalLastOrder: NSObject, NSCoding {
    let clientNumber:String?
    let operatorId:String?
    let productId:String?
    let categoryId:String

    init(categoryId:String, operatorId:String? = nil, productId:String? = nil, clientNumber:String? = nil) {
        self.clientNumber = clientNumber
        self.operatorId = operatorId
        self.productId = productId
        self.categoryId = categoryId
    }

    required init(coder decoder: NSCoder) {
        self.clientNumber = decoder.decodeObject(forKey: "client_number") as? String
        self.operatorId = decoder.decodeObject(forKey: "operator_id") as? String
        self.productId = decoder.decodeObject(forKey: "product_id") as? String
        self.categoryId = decoder.decodeObject(forKey: "category_id") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(clientNumber, forKey: "client_number")
        aCoder.encode(operatorId, forKey: "operator_id")
        aCoder.encode(productId, forKey: "product_id")
        aCoder.encode(categoryId, forKey: "category_id")
    }

}

extension DigitalLastOrder : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> DigitalLastOrder {
        let json = JSON(source)
        
        let clientNumber = json["client_number"].stringValue
        let operatorId = json["operator_id"].stringValue
        let productId = json["product_id"].stringValue
        let categoryId = json["category_id"].stringValue
        
        return DigitalLastOrder(categoryId: categoryId, operatorId: operatorId, productId: productId, clientNumber: clientNumber)
    }
}
