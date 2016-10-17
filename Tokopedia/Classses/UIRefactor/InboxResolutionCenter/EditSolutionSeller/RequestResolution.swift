//
//  RequestResolution.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestResolution: NSObject {
    
    class func fetchEditAddressID(addressID:String, resolutionID: String, oldAddressID: String, oldConversationID: String, onSuccess: ((data:ResolutionActionResult) -> Void), onFailure:(()->Void)) {
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        
        let param :[String:String] = [
            "resolution_id" : resolutionID,
            "address_id"    : addressID,
            "old_data"      : "\(oldAddressID)-\(oldConversationID)",//(old_address_id-old_conversation_id)
            "user_id"       : auth.getUserId()
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/resolution-center/edit_address_resolution.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: ResolutionAction.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : ResolutionAction = result[""] as! ResolutionAction
                                            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else if (response.data?.is_success == 1) {
                                                if response.message_status.count > 0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(data: response.data)
                                            } else {
                                                StickyAlertView.showErrorMessage(["Gagal Mengubah Alamat"])
                                                onFailure()
                                            }
                                            
                                            if (response.data?.is_success == 1) {
                                            } else {
                                            }
                                            
        }) { (error) in
            StickyAlertView.showErrorMessage(["Gagal Mengubah Alamat"])
            onFailure()
        }
    }
    
    class func fetchInputAddressID(addressID:String, resolutionID: String, onSuccess: ((data:ResolutionActionResult) -> Void), onFailure:(()->Void)) {
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()

        let param :[String:String] = [
            "resolution_id" : resolutionID,
            "address_id"    : addressID,
            "new_address"   : "1",
            "user_id"       : auth.getUserId()
            ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString .v4Url(),
                                          path: "/v4/action/resolution-center/input_address_resolution.pl",
                                          method: .POST,
                                          parameter: param,
                                          mapping: ResolutionAction.mapping(),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : ResolutionAction = result[""] as! ResolutionAction
                                            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else if (response.data?.is_success == 1) {
                                                if response.message_status.count > 0 {
                                                    StickyAlertView.showSuccessMessage(response.message_status)
                                                }
                                                onSuccess(data: response.data)
                                            } else {
                                                StickyAlertView.showErrorMessage(["Gagal Mengubah Alamat"])
                                                onFailure()
                                            }
                                            
                                            if (response.data?.is_success == 1) {
                                            } else {
                                            }
                                            
        }) { (error) in
            StickyAlertView.showErrorMessage(["Gagal Mengubah Alamat"])
            onFailure()
        }
    }
    
    class func fetchReplayConversation(postData:ReplayConversationPostData, onSuccess: ((data:ResolutionActionResult) -> Void), onFailure:(()->Void)) {
        
        if postData.selectedAssets.count == 0 {
            self.getPostKey(postData).doOnNext({ (postData) in
                onSuccess(data: postData)
            }).doOnError({ (error) in
                onFailure()
            }).subscribe()
            
        } else {
            
            
            GenerateHostObservable.getGeneratedHost().doOnError({ (error) in
                onFailure()
            })
            .flatMap({ (host) -> Observable<[ImageResult]> in
                postData.generatedHost = host
                
                return self.getUploadedImages(postData).doOnError({ (error) in
                    onFailure()
                })
                
            })
            .flatMap({ (uploadedImages) -> Observable<ResolutionActionResult> in
                postData.uploadedImages = uploadedImages
                
                return self.getPostKey(postData).doOnError({ (error) in
                    onFailure()
                })

            })
            .flatMap({ (data) -> Observable<String> in
                postData.postKey = data.post_key
                
                return self.getFileUploaded(postData).doOnError({ (error) in
                    onFailure()
                })
            })
            .flatMap({ (fileUploaded) -> Observable<ResolutionActionResult> in
                postData.fileUploaded = fileUploaded
                
                return self.submitReplayConversation(postData)
            })
            .subscribeNext { (data) in
                    onSuccess(data: data)
            }
        }
        
    }
    
    private class func jsonStringProductList(postData: ReplayConversationPostData)-> String {
        var jsonString : String = "{\"data\" : ["
        if postData.postObjectProducts.count > 0 {
            for (index,product) in postData.postObjectProducts.enumerate() {
                let requestDescriptor : RKRequestDescriptor = RKRequestDescriptor.init(mapping: ResolutionCenterCreatePOSTProduct.mapping().inverseMapping(), objectClass: ResolutionCenterCreatePOSTProduct.self, rootKeyPath: nil, method: .POST)
                var paramForObject : NSDictionary = NSDictionary()
                do {
                    paramForObject = try RKObjectParameterization.parametersWithObject(product, requestDescriptor: requestDescriptor)
                    // use anyObj here
                } catch {
                }
                var jsonData: NSData = NSData()
                
                do {
                    jsonData = try NSJSONSerialization.dataWithJSONObject(paramForObject, options: NSJSONWritingOptions())
                    // use anyObj here
                } catch {
                    print("json error: \(error)")
                }
                
                let jsonStr = String.init(data: jsonData, encoding: NSUTF8StringEncoding)
                jsonString = jsonString.stringByAppendingString(jsonStr!)

                if index <  postData.postObjectProducts.count-1 {
                    jsonString = jsonString.stringByAppendingString(",")
                }
            }
            jsonString = jsonString.substringToIndex(jsonString.endIndex)
            jsonString = jsonString.stringByAppendingString("]}")
        }
        
        return jsonString
    }
    
    //MARK: - Replay Conversation
    private class func getUploadedImages(postData:ReplayConversationPostData) -> Observable<[ImageResult]> {
        
        return postData.selectedAssets
            .toObservable()
            .flatMap({ (asset) -> Observable<ImageResult> in
                
                return Observable.create({ (observer) -> Disposable in
                    
                    let auth : UserAuthentificationManager = UserAuthentificationManager()
                    let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
                    postObject.user_id = auth.getUserId()
                    postObject.server_id = postData.generatedHost.server_id
                    
                    RequestUploadImage.requestUploadImage(asset.resizedImage,
                        withUploadHost: "https://\(postData.generatedHost.upload_host)",
                        path: "/web-service/v4/action/upload-image/upload_contact_image.pl",
                        name: "fileToUpload",
                        fileName: "Image",
                        requestObject: postObject,
                        onSuccess: { (imageResult) in
                            observer.onNext(imageResult)
                            observer.onCompleted()
                        }, onFailure: { (error) in
                            observer.onError(RequestError.networkError)
                    })
                    
                    return NopDisposable.instance
                })
                
            })
            .toArray()
        
    }
    
    private class func getPostKey(postData:ReplayConversationPostData)-> Observable<ResolutionActionResult>{
        
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        
        var param :[String:String] = [
            "edit_sol_flag" : postData.editSolution,
            "flag_received" : postData.flagReceived,
            "refund_amount" : postData.refundAmount,
            "reply_msg"     : postData.replyMessage,
            "resolution_id" : postData.resolutionID,
            "solution"      : postData.selectedSolution.solution_id,
            "user_id"       : auth.getUserId(),
            "action_by"     : postData.actionBy,
            "category_trouble_id"  : postData.category_trouble_id,
        ]
        
        if postData.uploadedImages.count > 0 {
            let filePaths : [String] = postData.uploadedImages.map{$0.file_path}
            let photos : String = filePaths.joinWithSeparator("~")
            param["photos"] = photos
            param["server_id"] = postData.generatedHost.server_id
        }
        
        if postData.troubleType != ""{
            param["trouble_id"] = postData.troubleType
        }
        
        if postData.postObjectProducts.count > 0 {
            param["product_list"] = self.jsonStringProductList(postData)
        }
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.requestWithBaseUrl(NSString .v4Url(),
                path: "/v4/action/resolution-center/reply_conversation_validation_new.pl",
                method: .POST,
                parameter: param,
                mapping: ResolutionAction.mapping(),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : ResolutionAction = result[""] as! ResolutionAction
                    
                    if response.message_error.count > 0{
                        StickyAlertView.showErrorMessage(response.message_error)
                    }
                    
                    if (response.data.is_success == 1) {
                        observer.onNext(response.data)
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Gagal membalas resolusi"])
            }
            
            return NopDisposable.instance
        })
        
    }
    
    
    private class func getFileUploaded(postData:ReplayConversationPostData)-> Observable<String>{
        
        let filePaths : [String] = postData.uploadedImages.map{$0.file_path}
        let photos : String = filePaths.joinWithSeparator("~")
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        
        let param :[String:String] = [
            "attachment_string" : photos,
            "file_path"         : photos,
            "server_id"         : postData.generatedHost.server_id,
            "user_id"           : auth.getUserId(),
            ]
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.requestWithBaseUrl("https://\(postData.generatedHost.upload_host)",
                path: "/web-service/v4/action/upload-image-helper/create_resolution_picture.pl",
                method: .POST,
                parameter: param,
                mapping: ResolutionAction.mapping(),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : ResolutionAction = result[""] as! ResolutionAction
                    
                    if (response.data.is_success == 1) {
                        observer.onNext(response.data.file_uploaded)
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Gagal membalas resolusi"])
            }
            
            return NopDisposable.instance
        })
        
    }
    
    
    private class func submitReplayConversation(postData:ReplayConversationPostData)-> Observable<ResolutionActionResult>{
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        
        let param :[String:String] = [
                "file_uploaded" : postData.fileUploaded,
                "post_key"      : postData.postKey,
                "resolution_id" : postData.resolutionID,
                "user_id"       : auth.getUserId()
            ]
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.requestWithBaseUrl(NSString.v4Url(),
                path: "/v4/action/resolution-center/reply_conversation_submit.pl",
                method: .POST,
                parameter: param,
                mapping: ResolutionAction.mapping(),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : ResolutionAction = result[""] as! ResolutionAction
                    
                    if (response.data.is_success == 1) {
                        observer.onNext(response.data)
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Gagal membalas resolusi"])
            }
            
            return NopDisposable.instance
        })
        
    }

}
