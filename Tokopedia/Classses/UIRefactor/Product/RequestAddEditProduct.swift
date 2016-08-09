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
    
    class func fetchDeleteProductImageObject(imageObject:ProductEditImages, productID:String, shopID:String, onSuccess: (() -> Void), onFailure:(()->Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param : Dictionary = [
            "product_id"  : productID,
            "shop_id"     : shopID,
            "picture_id"  : imageObject.image_id
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
    
    // MARK: - EDIT PRODUCT REQUEST
    
    class func fetchEditProduct(form:ProductEditResult, onSuccess: (() -> Void), onFailure:(()->Void)) {
        
        RequestAddEditProduct.errorCompletionHandler = onFailure
        
        var imageIDs : [String] = []
        
        self.fetchGenerateHost { (generatedHost) in
            
            form.product_images.forEach({ (selectedImage) in
                
                if selectedImage.image_id == "" {
                    self.fetchEditProductPicture(generatedHost,
                        selectedImage: selectedImage,
                        productID:  form.product.product_id,
                        onSuccess: { (imageID) in
                            
                            imageIDs.append(imageID)
                            selectedImage.image_id = imageID
                            
                            if imageIDs.count == form.product_images.count {
                                self.fetchEditProductSubmit(form,
                                    generatedHost: generatedHost,
                                    onSuccess: { () in
                                        
                                        onSuccess()
                                    
                                })
                            }
                        
                    })
                } else {
                    imageIDs.append(selectedImage.image_id)
                    if imageIDs.count == form.product_images.count {
                        self.fetchEditProductSubmit(form,
                            generatedHost: generatedHost,
                            onSuccess: { () in
                                
                                onSuccess()
                                
                        })
                    }
                }
                
            })
            
        }
    }
    
    private class func fetchEditProductPicture(generatedHost:GeneratedHost, selectedImage:ProductEditImages, productID:String, onSuccess: ((imageID:String) -> Void)) {
        
        self.fetchUploadProductImage(selectedImage.image,
            path: "https://\(generatedHost.upload_host)",
            serverID: generatedHost.server_id,
            productID: productID,
            onSuccess: { (pictObj) in
                
                if pictObj.pic_obj != nil{
                    self.fetchEditProductPictureGetImageID(pictObj.pic_obj,
                        onSuccess: { (imageID) in
                            
                            onSuccess(imageID:imageID)
                    })
                } else {
                    RequestAddEditProduct.errorCompletionHandler()
                }
        })

    }
    
    private class func fetchEditProductPictureGetImageID(picObj:String, onSuccess: ((imageID:String) -> Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let param :[String:String] = [
            "pic_obj" : picObj,
        ]
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
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
                                                onSuccess(imageID: response.data.pic_id)
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
    
    private class func fetchEditProductSubmit(form:ProductEditResult, generatedHost:GeneratedHost, onSuccess: (() -> Void)){
        
        let imageIDs:[String] = form.product_images.map{$0.image_id}
        let imageIDString : String = imageIDs.joinWithSeparator("~")
        
        var pictureDefault : String = ""
        for selectedImage in form.product_images where selectedImage.image_primary == "1" {
            pictureDefault = selectedImage.image_id
        }
        
        /*
         Upload to
         1 -> etalase
         2 -> warehouse
         3 -> pending
         */
        
        let product :ProductEditDetail = form.product
        
        var uploadTo : String = "1"
        if product.product_status == "3" {
            uploadTo = "2"
        }
        
        var param : [String:String] = [
            "product_catalog_id"        : product.product_catalog.catalog_id,
            "product_change_catalog"    : "1",
            "product_change_wholesale"  : "1",
            "product_change_photo"      : "1",
            "product_condition"         : product.product_condition,
            "product_department_id"     : product.product_category.categoryId,
            "product_description"       : product.product_short_desc,
            "product_etalase_id"        : product.product_etalase_id,
            "product_etalase_name"      : product.product_etalase,
            "product_id"                : product.product_id,
            "product_min_order"         : product.product_min_order,
            "product_must_insurance"    : product.product_must_insurance,
            "product_name"              : product.product_name,
            "product_photo"             : imageIDString,
            "product_photo_default"     : pictureDefault,
            "product_price"             : product.product_price,
            "product_price_currency"    : product.product_currency_id,
            "product_returnable"        : product.product_returnable,
            "product_upload_to"         : uploadTo,
            "product_weight"            : product.product_weight,
            "product_weight_unit"       : product.product_weight_unit,
//            "po_process_type -> value type 1 = day , 2 = week , 3 = month
//            "po_process_value -> for processing value
            "server_id"                 : generatedHost.server_id
        ]
        
        form.product_images.forEach { (imageObject) in
            let photoDescriptionParam :[String:String] = [
                "product_photo_desc\(imageObject.image_id)" : imageObject.image_description
            ]
            param.update(photoDescriptionParam)
        }
        
        for (index,wholesale) in form.wholesale_price.enumerate() {
            let wholesaleParam : [String:String] = [
                "qty_max_\(index+1)" : wholesale.wholesale_max,
                "qty_min_\(index+1)" : wholesale.wholesale_min,
                "prd_prc_\(index+1)" : wholesale.wholesale_price
            ]
            param.update(wholesaleParam)
        }
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/product/edit_product.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: AddProductValidation.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : AddProductValidation = result[""] as! AddProductValidation
                                            
                                            if response.data.is_success == "1" {
                                                if response.message_status?.count>0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess()
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
    
    //MARK: - ADD PRODUCT REQUEST
    
    class func fetchAddProduct(form:ProductEditResult,isDuplicate:String,  onSuccess: (() -> Void), onFailure:(()->Void)) {
        
        RequestAddEditProduct.errorCompletionHandler = onFailure
        
        var imageFilePaths : [String] = []
        
        self.getGeneratedHost()
        .flatMap { (generateHost) -> Observable<ImageResult> in
            return getUploadProductImage(UIImage(), path: "", serverID: "", productID: "")
            Observable.zip(<#T##source1: ObservableType##ObservableType#>, <#T##source2: ObservableType##ObservableType#>, resultSelector: <#T##(O1.E, O2.E) throws -> Element#>)
        }
        
        self.getGeneratedHost()
        .subscribeNext { (generatedHost) in
            form.product_images.forEach{ selectedImage in
                self.getUploadProductImage(selectedImage.image,
                    path: "https://\(generatedHost.upload_host)",
                    serverID: generatedHost.server_id,
                    productID: "")
                .subscribeNext{ (pictObj) in
                        
                    imageFilePaths.append(pictObj.file_path)
                    selectedImage.image_src = pictObj.file_path
                        
                       if imageFilePaths.count == form.product_images.count{
                            self.getPostKey(form, isDuplicate: isDuplicate,
                                generatedHost: generatedHost)
                            .subscribeNext({ (postKey) in
                                
                            })
                        }
                }
            }
        }

        self.fetchGenerateHost({ (generatedHost) in
            
            form.product_images.forEach{ selectedImage in
                
                self.fetchUploadProductImage(selectedImage.image,
                    path: "https://\(generatedHost.upload_host)",
                    serverID: generatedHost.server_id,
                    productID: "",
                    onSuccess: { (pictObj) in
                        
                        imageFilePaths.append(pictObj.file_path)
                        selectedImage.image_src = pictObj.file_path
                        
                        if imageFilePaths.count == form.product_images.count{
                            
                            self.fetchValidationAddProduct(form,
                                isDuplicate: isDuplicate,
                                generatedHost: generatedHost,
                                onSuccess: { (postKey) in
                                    
                                    self.fetchAddProductImages(isDuplicate,
                                        selectedImages: form.product_images,
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
    private class func getPostKey(form:ProductEditResult, isDuplicate:String, generatedHost:GeneratedHost) -> Observable<String> {
        return Observable.create({ (observer) -> Disposable in
            let filePaths:[String] = form.product_images.map{$0.image_src}
            let filePathString : String = filePaths.joinWithSeparator("~")
            
            let pictDescriptions:[String] = form.product_images.map{$0.image_description}
            let pictDescriptionString : String = pictDescriptions.joinWithSeparator("~")
            
            var pictureDefault : String = ""
            for selectedImage in form.product_images where selectedImage.image_primary == "1" {
                pictureDefault = selectedImage.image_src
            }
            
            /*
             Upload to
             1 -> etalase
             2 -> warehouse
             3 -> pending
             */
            
            let product: ProductEditDetail = form.product
            
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
            
            for (index,wholesale) in form.wholesale_price.enumerate() {
                let wholesaleParam : [String:String] = [
                    "qty_max_\(index+1)" : wholesale.wholesale_max,
                    "qty_min_\(index+1)" : wholesale.wholesale_min,
                    "prd_prc_\(index+1)" : wholesale.wholesale_price
                ]
                param.update(wholesaleParam)
            }
            
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            
            _ = networkManager.requestWithBaseUrl(NSString .v4Url(),
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
                        observer.onNext(response.data.post_key)
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
            
            return AnonymousDisposable {
                RequestAddEditProduct.errorCompletionHandler()
                StickyAlertView.showErrorMessage(["Gagal generate host"])
            }
            
        })
    }
    
    
    private class func fetchValidationAddProduct(form:ProductEditResult, isDuplicate:String, generatedHost:GeneratedHost, onSuccess: ((postKey:String) -> Void)){
        
        let filePaths:[String] = form.product_images.map{$0.image_src}
        let filePathString : String = filePaths.joinWithSeparator("~")
        
        let pictDescriptions:[String] = form.product_images.map{$0.image_description}
        let pictDescriptionString : String = pictDescriptions.joinWithSeparator("~")
        
        var pictureDefault : String = ""
        for selectedImage in form.product_images where selectedImage.image_primary == "1" {
            pictureDefault = selectedImage.image_src
        }
        
        /*
         Upload to
         1 -> etalase
         2 -> warehouse
         3 -> pending
         */
        
        let product: ProductEditDetail = form.product
        
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
        
        for (index,wholesale) in form.wholesale_price.enumerate() {
            let wholesaleParam : [String:String] = [
                "qty_max_\(index+1)" : wholesale.wholesale_max,
                "qty_min_\(index+1)" : wholesale.wholesale_min,
                "prd_prc_\(index+1)" : wholesale.wholesale_price
            ]
            param.update(wholesaleParam)
        }
        
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
    
    
    private class func fetchAddProductImages(isDuplicate:String, selectedImages:[ProductEditImages], generatedHost:GeneratedHost, onSuccess: ((fileUploaded:String) -> Void)) {
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let filePaths:[String] = selectedImages.map{$0.image_src}
        let filePathString : String = filePaths.joinWithSeparator("~")
        
        let pictDescriptions:[String] = selectedImages.map{$0.image_description}
        let pictDescriptionString : String = pictDescriptions.joinWithSeparator("~")
        
        var pictureDefault : String = ""
        for selectedImage in selectedImages where selectedImage.image_primary == "1" {
            pictureDefault = selectedImage.image_src
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
                                            
                                            if response.data?.is_success == "1"{
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
    
    //MARK: - UPLOAD IMAGE
    private class func fetchGenerateHost( onSuccess: ((generatedHost:GeneratedHost) -> Void)) {
        RequestGenerateHost .fetchGenerateHostSuccess({ (generatedHost) in
            
            onSuccess(generatedHost:generatedHost)
            
        }) { (error) in
            RequestAddEditProduct.errorCompletionHandler()
            StickyAlertView.showErrorMessage(["Gagal generate host"])
        }
    }
    private class func getGeneratedHost() -> Observable<GeneratedHost> {
        return Observable.create({ (observer) -> Disposable in
            _ = RequestGenerateHost .fetchGenerateHostSuccess({ (generatedHost) in
                observer.onNext(generatedHost)
                observer.onCompleted()
            }) { (error) in
                observer.onError(error)
                RequestAddEditProduct.errorCompletionHandler()
                StickyAlertView.showErrorMessage(["Gagal generate host"])
            }
            
            return AnonymousDisposable {
                RequestAddEditProduct.errorCompletionHandler()
                StickyAlertView.showErrorMessage(["Gagal generate host"])
            }
        })
    }
    
    private class func fetchUploadProductImage(Image:UIImage, path:String, serverID:String, productID:String, onSuccess: ((pictObj:ImageResult) -> Void)){
        let auth : UserAuthentificationManager = UserAuthentificationManager();
        let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
        postObject.user_id = auth.getUserId()
        postObject.server_id = serverID
        postObject.add_new = "1"
        if productID != "" {
            postObject.product_id = productID
        }
        
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
    
    private class func getUploadProductImage(Image:UIImage, path:String, serverID:String, productID:String) -> Observable<ImageResult>{
        return Observable.create({ (observer) -> Disposable in
            let auth : UserAuthentificationManager = UserAuthentificationManager();
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = auth.getUserId()
            postObject.server_id = serverID
            postObject.add_new = "1"
            if productID != "" {
                postObject.product_id = productID
            }
            
            _ = RequestUploadImage.requestUploadImage(Image,
                withUploadHost: path,
                path: "/web-service/v4/action/upload-image/upload_product_image.pl",
                name: "fileToUpload",
                fileName: "Image",
                requestObject: postObject,
                onSuccess: { (imageResult) in
                    observer.onNext(imageResult)
                    observer.onCompleted()
                }, onFailure: { (error) in
//                    observer.onError(error)
                    RequestAddEditProduct.errorCompletionHandler()
                    StickyAlertView.showErrorMessage(["Gagal mengupload gambar"])
            })
            return AnonymousDisposable{
                RequestAddEditProduct.errorCompletionHandler()
            }
        })
    }

}


extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
