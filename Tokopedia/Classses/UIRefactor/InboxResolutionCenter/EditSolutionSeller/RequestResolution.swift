//
//  RequestResolution.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import DKImagePickerController
import RestKit

class RequestResolution: NSObject {
    
    class func fetchEditAddressID(_ addressID:String, resolutionID: String, oldAddressID: String, oldConversationID: String, onSuccess:@escaping ((_ data:ResolutionActionResult) -> Void), onFailure:@escaping (()->Void)) {
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        
        let param :[String:String] = [
            "resolution_id" : resolutionID,
            "address_id"    : addressID,
            "old_data"      : "\(oldAddressID)-\(oldConversationID)",//(old_address_id-old_conversation_id)
            "user_id"       : auth.getUserId()
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString .v4Url(),
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
                                                onSuccess(response.data)
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
    
    class func fetchInputAddressID(_ addressID:String, resolutionID: String, onSuccess:@escaping ((_ data:ResolutionActionResult) -> Void), onFailure:@escaping (()->Void)) {
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()

        let param :[String:String] = [
            "resolution_id" : resolutionID,
            "address_id"    : addressID,
            "new_address"   : "1",
            "user_id"       : auth.getUserId()
            ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString .v4Url(),
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
                                                onSuccess(response.data)
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
    
    class func fetchReplayConversation(_ postData:ReplayConversationPostData, onSuccess: @escaping ((_ data:ResolutionActionResult) -> Void), onFailure:@escaping (()->Void)) {
        
        if postData.selectedAssets.count == 0 {
            self.getPostKey(postData).do(onNext : { (postData) in
                onSuccess(postData)
            }, onError : {error in
                onFailure()
            }).subscribe()
            
        } else {
            GenerateHostObservable.getGeneratedHost().do(onError : { (error) in
                onFailure()
            })
            .flatMap({ (host) -> Observable<[ImageResult]> in
                postData.generatedHost = host
                
                return self.getUploadedImages(postData).do(onError : { (error) in
                    onFailure()
                })
                
            })
            .flatMap({ (uploadedImages) -> Observable<ResolutionActionResult> in
                postData.uploadedImages = uploadedImages
                
                return self.getPostKey(postData).do(onError : { (error) in
                    onFailure()
                })

            })
            .flatMap({ (data) -> Observable<String> in
                postData.postKey = data.post_key
                
                return self.getFileUploaded(postData).do(onError : { (error) in
                    onFailure()
                })
            })
            .flatMap({ (fileUploaded) -> Observable<ResolutionActionResult> in
                postData.fileUploaded = fileUploaded
                
                return self.submitReplayConversation(postData)
            })
            .subscribe (onNext : { (data) in
                    onSuccess(data)
            })
        }
        
    }
    
    fileprivate class func jsonStringProductList(_ postData: ReplayConversationPostData)-> String {
        var jsonString : String = "{\"data\" : ["
        if postData.postObjectProducts.count > 0 {
            for (index,product) in postData.postObjectProducts.enumerated() {
                let requestDescriptor : RKRequestDescriptor = RKRequestDescriptor(mapping: ResolutionCenterCreatePOSTProduct.mapping().inverse(), objectClass: ResolutionCenterCreatePOSTProduct.self, rootKeyPath: nil, method: .POST)
                var paramForObject : NSDictionary = NSDictionary()
                do {
                    paramForObject = try RKObjectParameterization.parameters(with: product, requestDescriptor: requestDescriptor) as NSDictionary
                    // use anyObj here
                } catch {
                }
                var jsonData: NSData = NSData()
                
                do {
                    jsonData = try JSONSerialization.data(withJSONObject: paramForObject, options: JSONSerialization.WritingOptions()) as NSData
                    // use anyObj here
                } catch {
                    print("json error: \(error)")
                }
                
                let jsonStr = String(data: jsonData as Data, encoding: String.Encoding.utf8)
                jsonString = jsonString.appending(jsonStr!)

                if index <  postData.postObjectProducts.count-1 {
                    jsonString = jsonString.appending(",")
                }
            }
            jsonString = jsonString.substring(to: jsonString.endIndex)
            jsonString = jsonString + "]}"
        }
        
        return jsonString
    }
    
    //MARK: - Replay Conversation
    fileprivate class func getUploadedImages(_ postData:ReplayConversationPostData) -> Observable<[ImageResult]> {
        return Observable.from(postData.selectedAssets)
            .flatMap({ (asset) -> Observable<ImageResult> in
                
                return Observable.create({ (observer) -> Disposable in
                    
                    let auth : UserAuthentificationManager = UserAuthentificationManager()
                    let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
                    postObject.user_id = auth.getUserId()
                    postObject.server_id = postData.generatedHost.server_id
                    
                    asset.fetchOriginalImage(false, completeBlock: {(image, info) in
                        
                        let resizedImage = TKPImagePickerController.resizedImage(image!)
                        
                        RequestUploadImage.requestUploadImage(resizedImage,
                          withUploadHost: "https://\(postData.generatedHost.upload_host)",
                            path: "/web-service/v4/action/upload-image/upload_contact_image.pl",
                            name: "fileToUpload",
                            fileName: "Image",
                            request: postObject,
                            onSuccess: { (imageResult) in
                                observer.onNext(imageResult!)
                                observer.onCompleted()
                            }, onFailure: { (error) in
                                observer.onError(RequestError.networkError)
                        })
                    
                    })
                    
                    return Disposables.create()
                })
                
            })
            .toArray()
        
    }
    
    fileprivate class func getPostKey(_ postData:ReplayConversationPostData)-> Observable<ResolutionActionResult>{
        
        
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
            let photos : String = filePaths.joined(separator: "~")
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
            networkManager.request(withBaseUrl: NSString .v4Url(),
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
                        observer.onError(RequestError.networkError as Error)
                    }
                    
            }) { (error) in
                observer.onError((RequestError.networkError as? Error)!)
                StickyAlertView.showErrorMessage(["Gagal membalas resolusi"])
            }
            
            return Disposables.create()
        })
        
    }
    
    
    fileprivate class func getFileUploaded(_ postData:ReplayConversationPostData)-> Observable<String>{
        
        let filePaths : [String] = postData.uploadedImages.map{$0.file_path}
        let photos : String = filePaths.joined(separator: "~")
        
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
            networkManager.request(withBaseUrl: "https://\(postData.generatedHost.upload_host)",
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
                        observer.onError(RequestError.networkError as Error)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError as Error)
                StickyAlertView.showErrorMessage(["Gagal membalas resolusi"])
            }
            
            return Disposables.create()
        })
        
    }
    
    
    fileprivate class func submitReplayConversation(_ postData:ReplayConversationPostData)-> Observable<ResolutionActionResult>{
        
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
            networkManager.request(withBaseUrl: NSString.v4Url(),
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
                        observer.onError(RequestError.networkError as Error)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError as Error)
                StickyAlertView.showErrorMessage(["Gagal membalas resolusi"])
            }
            
            return Disposables.create()
        })
        
    }

}
