//
//  UploadImageObserver.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import DKImagePickerController

class UploadImageRequestObject : NSObject{
    var selectedImages : [AttachedImageObject] = []
    var host: GeneratedHost = GeneratedHost()
}

class UploadImageObserver: NSObject {
    
    class func getUploadedAttachments(_ postData: UploadImageRequestObject) -> Observable<[ImageResult]> {
        
        return Observable.from(postData.selectedImages)
            .flatMap({ (imageObject) -> Observable<ImageResult> in
                self.requestUploadImage(postData, imageObject: imageObject)
            })
            .toArray()
    }

    class func requestUploadImage(_ postData: UploadImageRequestObject, imageObject: AttachedImageObject) -> Observable<ImageResult> {
        
        return Observable.create({ (observer) -> Disposable in
            
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = auth.getUserId()
            postObject.server_id = postData.host.server_id
            postObject.image_id = imageObject.imageID
            postObject.web_service = "1"
            
            let baseURLString = "https://\(postData.host.upload_host)"
            
            imageObject.asset.fetchOriginalImage(false, completeBlock: { (image, info) in
                RequestUploadImage.requestUploadImage(image!,
                    withUploadHost: baseURLString,
                    path: "/upload/attachment",
                    name: "fileToUpload",
                    fileName: "image.png",
                    request: postObject,
                    onSuccess: { (imageResult) in
                        imageObject.picObj = (imageResult?.pic_obj)!
                        observer.onNext(imageResult!)
                        observer.onCompleted()
                    }, onFailure: { (error) in
                        observer.onError(RequestError.networkError as Error)
                })
            })
            
            return Disposables.create()
        })
    }
    
    class func requestUploadAccountsImage(_ host: GeneratedHost, token: String, imageObject: AttachedImageObject, userID: String) -> Observable<ImageResult> {
        return Observable.create({ (observer) -> Disposable in
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = userID
            postObject.server_id = host.server_id
            postObject.image_id = userID
            postObject.token = token
            postObject.web_service = "1"
            
            let baseURLString = host.upload_host
            
            imageObject.asset.fetchOriginalImage(false, completeBlock: { (image, info) in
                RequestUploadImage.requestUploadImage(image!,
                                                      withUploadHost: baseURLString,
                                                      path: "/upload/attachment",
                                                      name: "fileToUpload",
                                                      fileName: "image.png",
                                                      request: postObject,
                                                      onSuccess: { (imageResult) in
                                                        imageObject.picObj = (imageResult?.pic_obj)!
                                                        observer.onNext(imageResult!)
                                                        observer.onCompleted()
                }, onFailure: { (error) in
                    observer.onError(RequestError.networkError as Error)
                })
            })
            
            return Disposables.create()
        })
    }
}
