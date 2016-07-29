//
//  RequestAddEditProduct.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class RequestAddEditProduct: NSObject {
    
    class func fetchFormEditProductID(productID:String, shopID:String, onSuccess: ((ProductEditResult) -> Void), onFailure:(()->Void)) {
        
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
                                                onFailure()
                                            } else {
                                                onSuccess(response.data)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
    
    class func fetchGetCatalog(productName:String, departmentID:String, onSuccess: (([CatalogList]) -> Void), onFailure:(()->Void)) {
        
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
                                                onFailure()
                                            } else {
                                                onSuccess(response.data.list)
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
    
    class func fetchDeleteProductPictID(pictureID:String, productID:String, shopID:String, onSuccess: (() -> Void), onFailure:(()->Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : Dictionary = [
            "product_id"  : productID,
            "shop_id"     : shopID,
            "picture_id"  : pictureID
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/product/delete_product_pic.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: GeneralAction.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : GeneralAction = result[""] as! GeneralAction
                                            
                                            if response.data.is_success == "1"{
                                                if response.message_status?.count>0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess()
                                            } else {
                                                if let errors = response.message_error{
                                                    StickyAlertView.showErrorMessage(errors)
                                                } else {
                                                    StickyAlertView.showErrorMessage(["Gagal menghapus image"])
                                                }
                                                onFailure()
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }
}
