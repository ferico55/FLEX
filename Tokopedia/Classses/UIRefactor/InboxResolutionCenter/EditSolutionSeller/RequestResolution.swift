//
//  RequestResolution.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class RequestResolution: NSObject {
    
    class func fetchReplayConversation(postData:ReplayConversationPostData, onSuccess: ((data:ResolutionActionResult) -> Void), onFailure:(()->Void)) {
        
        if postData.selectedAssets.count == 0 {
            self.fetchReplayConversationValidation(postData).doOnNext({ (data) in
                onSuccess(data: data)
            }).doOnError({ (error) in
                onFailure()
            }).subscribe()
            
        } else {
            
            self.getGeneratedHost().doOnError({ (error) in
                onFailure()
            })
            .flatMap({ (host) -> Observable<[ImageResult]> in
                postData.generatedHost = host
                
                return self.getUploadedImages(postData).doOnError({ (error) in
                    onFailure()
                })
                
            })
            .flatMap({ (uploadedImages) -> Observable<String> in
                postData.uploadedImages = uploadedImages
                
                return self.getPostKey(postData).doOnError({ (error) in
                    onFailure()
                })

            })
            .flatMap({ (postKey) -> Observable<String> in
                postData.postKey = postKey
                
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
    
    private class func fetchReplayConversationValidation(postData:ReplayConversationPostData)-> Observable<ResolutionActionResult>{
    
        let auth : UserAuthentificationManager = UserAuthentificationManager()

        let param :[String:String] = [
            "edit_sol_flag" : postData.editSolution,
            "flag_received" : postData.flagReceived,
            "refund_amount" : postData.refundAmount,
            "reply_msg"     : postData.replyMessage,
            "resolution_id" : postData.resolutionID,
            "solution"      : postData.selectedSolution.solution_id,
            "trouble_type"  : postData.troubleType,
            "user_id"       : auth.getUserId(),
            "action_by"     : postData.actionBy,
            "problem_type"  : postData.category_trouble_id
            ]
        
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
                    
                    if (response.data.is_success == 1) {
                        observer.onNext(response.data)
                        observer.onCompleted()
                    } else {
                        StickyAlertView.showErrorMessage(response.message_error)
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
                StickyAlertView.showErrorMessage(["Gagal membalas resolution"])
            }
            
            return NopDisposable.instance
        })

    }
    
    //MARK: - Replay Conversation
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
    
    private class func getPostKey(postData:ReplayConversationPostData)-> Observable<String>{
        
        let filePaths : [String] = postData.uploadedImages.map{$0.file_path}
        let photos : String = filePaths.joinWithSeparator("~")
        
        let auth : UserAuthentificationManager = UserAuthentificationManager()
        
        let param :[String:String] = [
            "edit_sol_flag" : postData.editSolution,
            "flag_received" : postData.flagReceived,
            "photos"        : photos,
            "refund_amount" : postData.refundAmount,
            "reply_msg"     : postData.replyMessage,
            "resolution_id" : postData.resolutionID,
            "server_id"     : postData.generatedHost.server_id,
            "solution"      : postData.selectedSolution.solution_id,
            "trouble_type"  : postData.troubleType,
            "user_id"       : auth.getUserId(),
            "action_by"     : postData.actionBy,
            "problem_type"  : postData.category_trouble_id
        ]
        
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
                        observer.onNext(response.data.post_key)
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
