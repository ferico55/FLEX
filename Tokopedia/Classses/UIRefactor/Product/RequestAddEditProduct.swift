//
//  RequestAddEditProduct.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class RequestAddEditProduct: NSObject {
    
    class func fetchFormEditProductID(productID:String, shopID:String, onSuccess: ((ProductEditResult) -> Void), onFailure:((NSError?)->Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : Dictionary = ["product_id":productID, "shop_id":shopID]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/product/get_edit_product_form.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: ProductEdit.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : ProductEdit = result[""] as! ProductEdit
                                            
                                            if response.message_error.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure(nil)
                                            } else {
                                                onSuccess(response.data)
                                            }
                                            
        }) { (error) in
            onFailure(error)
        }
    }
    
    class func fetchGetCatalog(productName:String, departmentID:String, onSuccess: (([CatalogList]) -> Void), onFailure:((NSError?)->Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : Dictionary = ["product_name":productName, "product_department_id":departmentID]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/catalog/get_catalog.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: CatalogAddProduct.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : CatalogAddProduct = result[""] as! CatalogAddProduct
                                            
                                            if response.message_error?.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure(nil)
                                            } else {
                                                onSuccess(response.data.list)
                                            }
                                            
        }) { (error) in
            onFailure(error)
        }
    }
}
