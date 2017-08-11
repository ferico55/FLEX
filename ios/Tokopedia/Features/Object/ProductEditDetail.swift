//
//  ProductEditDetail.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RestKit

class ProductEditDetail: NSObject {
    var product_min_order: String = ""
    var product_id: String = ""
    var product_currency_id: String = ""
    var product_must_insurance: String = ""
    var product_weight: String = ""
    var product_price: String = ""
    var product_currency: String = ""
    var product_condition: String = ""
    var product_weight_unit: String = ""
    var product_department_id: String = ""
    var product_etalase_id: String = ""
    var product_status: String = ""
    var product_weight_unit_name: String = ""
    var product_catalog: CatalogList = CatalogList()
    var product_category :ListOption = ListOption()
    var product_name_editable: String = ""
    
    var productEtalaseEnc: String = ""
    var product_etalase: String {
        get {
            return productEtalaseEnc.kv_decodeHTMLCharacterEntities()
        }
        set (newValue) {
            self.productEtalaseEnc = newValue;
        }
    }
    var productNameEnc: String = ""
    var product_name: String {
        get {
            return productNameEnc.kv_decodeHTMLCharacterEntities()
        }
        set (newValue) {
            self.productNameEnc = newValue;
        }
    }
    var productShortDescEnc: String = ""
    var product_short_desc: String {
        get {
            return productShortDescEnc.kv_decodeHTMLCharacterEntities()
        }
        set (newValue) {
            self.productShortDescEnc = newValue;
        }
    }
    
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping .addAttributeMappings(from:[
            "product_min_order" : "product_min_order",
            "product_id" : "product_id",
            "product_currency_id" : "product_currency_id",
            "product_must_insurance" : "product_must_insurance",
            "product_weight" : "product_weight",
            "product_price" : "product_price",
            "product_currency" : "product_currency",
            "product_etalase" : "productEtalaseEnc",
            "product_condition" : "product_condition",
            "product_weight_unit" : "product_weight_unit",
            "product_name" : "productNameEnc",
            "product_department_id" : "product_department_id",
            "product_etalase_id" : "product_etalase_id",
            "product_status" : "product_status",
            "product_short_desc" : "productShortDescEnc",
            "product_weight_unit_name" : "product_weight_unit_name",
            "product_name_editable" : "product_name_editable"
        ])
        
        return mapping
    }
}
