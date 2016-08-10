//
//  RequestAddEditProduct.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 7/13/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

enum RequestError : ErrorType {
    case networkError
}


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
        
        var generatedHost : GeneratedHost = GeneratedHost()
        
        self.getGeneratedHost()
            .flatMap { (host) -> Observable<[ProductEditImages]> in
                generatedHost = host
                return self.getEditProductImages(form.product_images, generatedHost: generatedHost, productID: form.product.product_id).doOnError({ (error) in
                    onFailure()
                })
            }
            .flatMap { (selectedImages) -> Observable<String>  in
                return self.fetchEditProductSubmit(form, generatedHost: generatedHost).doOnError({ (error) in
                    onFailure()
                })
            }
            .subscribeNext { (isSuccess) in
                onSuccess()
        }
    }
    
    private class func getEditProductImages(selectedImages:[ProductEditImages], generatedHost:GeneratedHost, productID:String) -> Observable<[ProductEditImages]> {
        
        return selectedImages
            .toObservable()
            .takeWhile({ selectedImage -> Bool in
                return (selectedImage.image_id != "")
            })
            .flatMap({ selectedImage -> Observable<ProductEditImages> in
                return self.getPostKeyEditProductID(productID, selectedImage: selectedImage, generatedHost: generatedHost)
            })
            .flatMap({ selectedImage -> Observable<ProductEditImages>  in
                return self.getImageID(selectedImage)
            })
            .toArray()
    }
    
    private class func getImageID(selectedImage:ProductEditImages) -> Observable<ProductEditImages> {
        
          return Observable.create({ (observer) -> Disposable in
            let param :[String:String] = [
                "pic_obj" : selectedImage.fileUploaded
            ]
            
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            
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
                        selectedImage.image_id = response.data.pic_id
                        observer.onNext(selectedImage)
                        observer.onCompleted()
                    } else {
                        if let errors = response.message_error{
                            StickyAlertView.showErrorMessage(errors)
                        } else {
                            StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                        }
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                observer.onError(RequestError.networkError)
            }
            
            return NopDisposable.instance
        })
    }
    
    private class func fetchEditProductSubmit(form:ProductEditResult, generatedHost:GeneratedHost) -> Observable<String> {
        
        return Observable.create({ (observer) -> Disposable in
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
                        observer.onNext("1")
                        observer.onCompleted()
                    } else {
                        if let errors = response.message_error{
                            StickyAlertView.showErrorMessage(errors)
                        } else {
                            StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                        }
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                observer.onError(RequestError.networkError)
            }
            
            return NopDisposable.instance
        })
    }
    
    //MARK: - ADD PRODUCT REQUEST
    
    class func fetchAddProduct(form:ProductEditResult,isDuplicate:String,  onSuccess: (() -> Void), onFailure:(()->Void)) {
        
        RequestAddEditProduct.errorCompletionHandler = onFailure
        
        var generatedHost : GeneratedHost = GeneratedHost()
        var uploadedImages : [ProductEditImages] = form.product_images
        var postKeyParam : String = ""

        self.getGeneratedHost()
        .flatMap { (host) -> Observable<[ProductEditImages]> in
            generatedHost = host
            return getImageURLAddProducts(form.product_images, generatedHost: host).doOnError({ (error) in
                onFailure()
            })
        }.flatMap { (selectedImages) -> Observable<String> in
            uploadedImages = selectedImages
            return getPostKeyAddProduct(form, isDuplicate: isDuplicate, generatedHost: generatedHost).doOnError({ (error) in
                onFailure()
            })
        }.flatMap { (postKey) -> Observable<String> in
            postKeyParam  = postKey
            return getFileUploadedAddProduct(isDuplicate, selectedImages:uploadedImages , generatedHost: generatedHost).doOnError({ (error) in
                onFailure()
            })
        }.flatMap { (fileUploaded) -> Observable<String> in
            return fetchSubmitAddProduct(isDuplicate, fileUploaded: fileUploaded, postKey: postKeyParam).doOnError({ (error) in
                onFailure()
            })
        }.subscribeNext { (isSuccess) in
            onSuccess()
        }
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
                        observer.onNext(response.data.post_key)
                        observer.onCompleted()
                    } else {
                        if let errors = response.message_error{
                            StickyAlertView.showErrorMessage(errors)
                        } else {
                            StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                        }
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                observer.onError(RequestError.networkError)
            }
            
            return NopDisposable.instance
            
        })
    }
    
    
    private class func getPostKeyAddProduct(form:ProductEditResult, isDuplicate:String, generatedHost:GeneratedHost) -> Observable<String> {
        
        
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
        
        return Observable.create({ (observer) -> Disposable in
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
                        observer.onNext(response.data.post_key)
                        observer.onCompleted()
                    } else {
                        var errors : [AnyObject] = []
                        if response.message_error != nil{
                            errors = response.message_error
                        } else {
                            errors = ["Gagal menambah produk"]
                        }
                        StickyAlertView .showErrorMessage(errors)
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
            }
            
            return NopDisposable.instance
        })
    }
    
    
    private class func getFileUploadedAddProduct(isDuplicate:String, selectedImages:[ProductEditImages], generatedHost:GeneratedHost) ->Observable<String> {
        
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
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
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
                        observer.onNext(response.data.file_uploaded)
                        observer.onCompleted()
                    } else {
                        if let errors = response.message_error{
                            StickyAlertView.showErrorMessage(errors)
                        } else {
                            StickyAlertView.showErrorMessage(["Gagal menambah produk"])
                        }
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Gagal menambah produk"])
            }

            return NopDisposable.instance
        })
    }
    
    private class func fetchSubmitAddProduct(isDuplicate:String, fileUploaded:String, postKey:String)-> Observable<String> {
        
        let param :[String:String] = [
            "file_uploaded" : fileUploaded,
            "post_key"      : postKey,
            "duplicate"     : isDuplicate,
        ]
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
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
                        observer.onError(RequestError.networkError)
                    } else {
                        RequestAddEditProduct.errorCompletionHandler()
                        if response.message_status?.count>0 {
                            StickyAlertView.showSuccessMessage(response.message_status)
                        }
                        observer.onNext("1")
                        observer.onCompleted()
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Gagal menambah produk"])
            }
            
            return NopDisposable.instance
        })

    }

    //MARK: - UPLOAD IMAGE
    private class func getGeneratedHost() -> Observable<GeneratedHost> {
        return Observable.create({ (observer) -> Disposable in
            RequestGenerateHost .fetchGenerateHostSuccess({ (generatedHost) in
                observer.onNext(generatedHost)
                observer.onCompleted()
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Gagal generate host"])
            }
            
            return NopDisposable.instance
        })
    }
    
    private class func getPostKeyEditProductID(productID:String, selectedImage:ProductEditImages, generatedHost:GeneratedHost) -> Observable<ProductEditImages>{

        return Observable.create({ (observer) -> Disposable in
            
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = auth.getUserId()
            postObject.server_id = generatedHost.server_id
            postObject.product_id = productID
            
            RequestUploadImage.requestUploadImage(selectedImage.image,
                withUploadHost: "https://\(generatedHost.upload_host)",
                path: "/web-service/v4/action/upload-image/upload_product_image.pl",
                name: "fileToUpload",
                fileName: "Image",
                requestObject: postObject,
                onSuccess: { (imageResult) in
                    
                    if imageResult.pic_obj != nil{
                        selectedImage.image_src = imageResult.pic_obj
                        observer.onNext(selectedImage)
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError)
                        StickyAlertView.showErrorMessage(["Gagal mengupload gambar"])
                    }

                }, onFailure: { (error) in
                    observer.onError(RequestError.networkError)
                    StickyAlertView.showErrorMessage(["Gagal mengupload gambar"])
            })
            
            return NopDisposable.instance
        })
    }
    
    private class func getImageURLAddProducts(selectedImages:[ProductEditImages], generatedHost:GeneratedHost) -> Observable<[ProductEditImages]>{
        
        return selectedImages
            .toObservable()
            .flatMapWithIndex({ (uploadedImages, index) -> Observable<ProductEditImages> in
                
                return Observable.create({ (observer) -> Disposable in
                    
                    let auth : UserAuthentificationManager = UserAuthentificationManager()
                    let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
                    postObject.user_id = auth.getUserId()
                    postObject.server_id = generatedHost.server_id
                    
                    RequestUploadImage.requestUploadImage(selectedImages[index].image,
                        withUploadHost: "https://\(generatedHost.upload_host)",
                        path: "/web-service/v4/action/upload-image/upload_product_image.pl",
                        name: "fileToUpload",
                        fileName: "Image",
                        requestObject: postObject,
                        onSuccess: { (imageResult) in
                            selectedImages[index].image_src = imageResult.file_path
                            observer.onNext(selectedImages[index])
                            observer.onCompleted()
                        }, onFailure: { (error) in
                            observer.onError(RequestError.networkError)
                            StickyAlertView.showErrorMessage(["Gagal mengupload gambar"])
                    })
                    
                    return NopDisposable.instance
                })
            })
            .toArray()
    }
}


extension Dictionary {
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
