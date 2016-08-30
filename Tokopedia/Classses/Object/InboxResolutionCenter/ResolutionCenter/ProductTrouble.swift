//
//  ProductTrouble.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProductTrouble: NSObject {
    
    var pt_snapshot_uri : String = ""
    var pt_product_name : String = ""
    var pt_trouble_name : String = ""
    var pt_trouble_id   : String = ""
    var pt_show_input_quantity : String = ""
    var pt_product_id : String = ""
    var pt_solution_remark : String = ""
    var pt_order_dtl_id : String = ""
    var pt_quantity : String = ""
    var pt_free_return : String = ""
    
    var sellerEditViewModel : ProductResolutionViewModel {
        get {
            let viewModel : ProductResolutionViewModel = ProductResolutionViewModel()
            viewModel.productImageURLString = self.pt_snapshot_uri
            viewModel.productName = self.pt_product_name
            viewModel.productTrouble = "\(self.pt_quantity) \(self.pt_trouble_name)"
            viewModel.productTroubleDescription = pt_solution_remark
            return viewModel
        }
    }
    
    class func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        mapping.addAttributeMappingsFromArray([
            "pt_snapshot_uri",
            "pt_product_name",
            "pt_trouble_name",
            "pt_trouble_id",
            "pt_show_input_quantity",
            "pt_product_id",
            "pt_solution_remark",
            "pt_order_dtl_id",
            "pt_quantity",
            "pt_free_return"
            ])
        
        return mapping
    }

}
