//
//  UploadImageObserver.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class UploadImageRequestObject : NSObject{
    var selectedImages : [AttachedImageObject] = []
    var host: GeneratedHost = GeneratedHost()
}

class UploadImageObserver: NSObject {
    
    class func getUploadedAttachments(postData: UploadImageRequestObject) -> Observable<[ImageResult]> {
        
        return postData.selectedImages
            .toObservable()
            .flatMap({ (imageObject) -> Observable<ImageResult> in
                self.requestUploadImage(postData, imageObject: imageObject)
            })
            .toArray()
    }

    class func requestUploadImage(postData: UploadImageRequestObject, imageObject: AttachedImageObject) -> Observable<ImageResult> {
        
        return Observable.create({ (observer) -> Disposable in
            
            let auth : UserAuthentificationManager = UserAuthentificationManager()
            
            let postObject :RequestObjectUploadImage = RequestObjectUploadImage()
            postObject.user_id = auth.getUserId()
            postObject.server_id = postData.host.server_id
            postObject.image_id = imageObject.imageID
            postObject.web_service = "1"
            
            let baseURLString = "https://\(postData.host.upload_host)"
            
            RequestUploadImage.requestUploadImage(imageObject.asset.resizedImage,
                withUploadHost: baseURLString,
                path: "/upload/attachment",
                name: "fileToUpload",
                fileName: "image.png",
                requestObject: postObject,
                onSuccess: { (imageResult) in
                    imageObject.picObj = imageResult.pic_obj
                    observer.onNext(imageResult)
                    observer.onCompleted()
                }, onFailure: { (error) in
                    observer.onError(RequestError.networkError)
            })
            
            return NopDisposable.instance
        })
    }
    
}
