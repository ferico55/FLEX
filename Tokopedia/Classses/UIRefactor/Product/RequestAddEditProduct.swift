//
//  RequestAddEditProduct.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class RequestAddEditProduct: NSObject {
    
    static var errorCompletionHandler:()->Void={}
    
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
    
    
    class func fetchAddProduct(isDuplicate:String, product:ProductEditDetail, selectedImages:[SelectedImage],wholesale:[String:String], onSuccess: (() -> Void), onFailure:(()->Void)) {
        
        RequestAddEditProduct.errorCompletionHandler = onFailure
        
        var imageFilePaths : [String] = []

        self.fetchGenerateHost({ (generatedHost) in
            
            selectedImages.forEach{ selectedImage in
                
                self.fetchUploadProductImage(selectedImage.image,
                    path: "https://\(generatedHost.upload_host)",
                    serverID: generatedHost.server_id,
                    onSuccess: { (pictObj) in
                        
                        imageFilePaths.append(pictObj.file_path)
                        selectedImage.filePath = pictObj.file_path
                        
                        if imageFilePaths.count == selectedImages.count{
                            
                            self.fetchValidationAddProduct(isDuplicate,
                                product: product,
                                selectedImages: selectedImages,
                                generatedHost: generatedHost,
                                wholesale: wholesale,
                                onSuccess: { (postKey) in
                                    
                                    self.fetchAddProductImages(isDuplicate,
                                        selectedImages: selectedImages,
                                        generatedHost: generatedHost,
                                        onSuccess: { (fileUploaded) in
                                            
                                            self.fetchAddProductSubmit(isDuplicate,
                                                fileUploaded: fileUploaded,
                                                postKey: postKey,
                                                onSuccess: {
                                                    
                                                    onSuccess()
                                                
                                                })
                                        
                                        })
                                    
                                })
                        }
                        
                    })
            }
            
        })
    }
    
    private class func fetchValidationAddProduct(isDuplicate:String, product:ProductEditDetail, selectedImages:[SelectedImage], generatedHost:GeneratedHost,wholesale:[String:String], onSuccess: ((postKey:String) -> Void)){
        
        let filePaths:[String] = selectedImages.map{$0.filePath}
        let filePathString : String = filePaths.joinWithSeparator("~")
        
        let pictDescriptions:[String] = selectedImages.map{$0.desc}
        let pictDescriptionString : String = pictDescriptions.joinWithSeparator("~")
        
        var pictureDefault : String = ""
        for selectedImage in selectedImages where selectedImage.imagePrimary == "1" {
            pictureDefault = selectedImage.filePath
        }
        
        /*
         Upload to
         1 -> etalase
         2 -> warehouse
         3 -> pending
         */
        
        var uploadTo : String = "1"
        if product.product_status == "3" {
            uploadTo = "2"
        }
 
        var param : [String:String] = [
            "server_id"             : generatedHost.server_id,
            "duplicate"             : isDuplicate,
            "product_name"          : product.product_name,
            "product_description"   : product.product_short_desc,
            "product_department_id" : product.product_category.categoryId,
            "product_catalog_id"    : (product.product_catalog.catalog_id)!,
            "product_min_order"     : product.product_min_order,
            "product_price_currency": product.product_currency_id,
            "product_price"         : product.product_price,
            "product_weight_unit"   : product.product_weight_unit,
            "product_weight"        : product.product_weight,
            "product_photo"         : filePathString,
            "product_photo_desc"    : pictDescriptionString,
            "product_photo_default" : pictureDefault,
            "product_must_insurance": product.product_must_insurance,
            "product_upload_to"     : uploadTo,
            "product_etalase_id"    : product.product_etalase_id,
            "product_etalase_name"  : product.product_etalase,
            "product_condition"     : product.product_condition,
            //"po_process_type -> value type 1 = day , 2 = week , 3 = month
            //"po_process_value -> for processing value
        ]
        
        param.update(wholesale)
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/product/add_product_validation.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: AddProductValidation.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : AddProductValidation = result[""] as! AddProductValidation
                                            
                                            if response.data.post_key != nil {
                                                if response.message_status?.count>0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(postKey:response.data.post_key)
                                            } else {
                                                if let errors = response.message_error{
                                                    StickyAlertView.showErrorMessage(errors)
                                                } else {
                                                    StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                                                }
                                                RequestAddEditProduct.errorCompletionHandler()
                                            }
                                            
        }) { (error) in
            RequestAddEditProduct.errorCompletionHandler()
            StickyAlertView.showErrorMessage(["Gagal menambah produk"])
        }
        
    }
    
    
    private class func fetchGenerateHost( onSuccess: ((generatedHost:GeneratedHost) -> Void)) {
        RequestGenerateHost .fetchGenerateHostSuccess({ (generatedHost) in
            
            onSuccess(generatedHost:generatedHost)
            
        }) { (error) in
            RequestAddEditProduct.errorCompletionHandler()
            StickyAlertView.showErrorMessage(["Gagal generate host"])
        }
    }
    
    private class func fetchUploadProductImage(Image:UIImage, path:String, serverID:String, onSuccess: ((pictObj:ImageResult) -> Void)){
        let auth : UserAuthentificationManager = UserAuthentificationManager();
        let postObject :RequestObjectUploadImage = RequestObjectUploadImage() 
        postObject.user_id = auth.getUserId()
        postObject.server_id = serverID
        
        RequestUploadImage.requestUploadImage(Image,
                                              withUploadHost: path,
                                              path: "/web-service/v4/action/upload-image/upload_product_image.pl",
                                              name: "fileToUpload",
                                              fileName: "Image",
                                              requestObject: postObject,
                                              onSuccess: { (imageResult) in
                                                
                                                onSuccess(pictObj: imageResult)
            }, onFailure: { (error) in
                RequestAddEditProduct.errorCompletionHandler()
                StickyAlertView.showErrorMessage(["Gagal mengupload gambar"])
        })
    }
    
    private class func fetchAddProductImages(isDuplicate:String, selectedImages:[SelectedImage], generatedHost:GeneratedHost, onSuccess: ((fileUploaded:String) -> Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let filePaths:[String] = selectedImages.map{$0.filePath}
        let filePathString : String = filePaths.joinWithSeparator("~")
        
        let pictDescriptions:[String] = selectedImages.map{$0.desc}
        let pictDescriptionString : String = pictDescriptions.joinWithSeparator("~")
        
        var pictureDefault : String = ""
        for selectedImage in selectedImages where selectedImage.imagePrimary == "1" {
            pictureDefault = selectedImage.filePath
        }
        
        let param :[String:String] = [
            "duplicate"             : isDuplicate,
            "product_photo"         : filePathString,
            "product_photo_default" : pictureDefault,
            "product_photo_desc"    : pictDescriptionString,
            "server_id"             : generatedHost.server_id
        ]
        
        networkManager.requestWithBaseUrl("https://\(generatedHost.upload_host)",
                                          path: "/web-service/v4/action/upload-image-helper/add_product_picture.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: UploadImage.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : UploadImage = result[""] as! UploadImage
                                            
                                            if response.data.is_success == "1"{
                                                if response.message_status?.count>0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(fileUploaded: response.data.file_uploaded)
                                            } else {
                                                if let errors = response.message_error{
                                                    StickyAlertView.showErrorMessage(errors)
                                                } else {
                                                    StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                                                }
                                                RequestAddEditProduct.errorCompletionHandler()
                                            }
                                            
        }) { (error) in
            RequestAddEditProduct.errorCompletionHandler()
            StickyAlertView.showErrorMessage(["Gagal menambah produk"])
        }
    }
    
    private class func fetchAddProductSubmit(isDuplicate:String, fileUploaded:String, postKey:String, onSuccess: (() -> Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param :[String:String] = [
            "file_uploaded" : fileUploaded,
            "post_key"      : postKey,
            "duplicate"     : isDuplicate,
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/product/add_product_submit.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: GeneralAction.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : GeneralAction = result[""] as! GeneralAction
                                            
                                            if response.message_error?.count > 0 {
                                                StickyAlertView.showErrorMessage(response.message_error)
                                            } else {
                                                RequestAddEditProduct.errorCompletionHandler()
                                                if response.message_status?.count>0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess()

                                            }
                                            
        }) { (error) in
            RequestAddEditProduct.errorCompletionHandler()
            StickyAlertView.showErrorMessage(["Gagal menambah produk"])
        }
    }
    
    private class func fetchEditProductPictObj(picObj:String, onSuccess: ((productID:String) -> Void), onFailure:(()->Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : Dictionary = [
            "pic_obj"  : picObj
        ]
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/product/edit_product_picture.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: UploadImage.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : UploadImage = result[""] as! UploadImage
                                            
                                            if response.data.is_success == "1"{
                                                if response.message_status?.count>0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(productID: response.data.pic_id)
                                            } else {
                                                if let errors = response.message_error{
                                                    StickyAlertView.showErrorMessage(errors)
                                                } else {
                                                    StickyAlertView.showErrorMessage(["Gagal menambahkan image"])
                                                }
                                                onFailure()
                                            }
                                            
        }) { (error) in
            onFailure()
        }
    }

}

extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
