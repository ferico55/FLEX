//
//  InboxTicketRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import DKImagePickerController

@objc enum InboxTicketFilterType :Int {
    case all, unread
    func description() -> String {
        switch self {
        case .all:
            return "all"
        case .unread:
            return "unread"
        }
    }
}

class AttachedImageObject: NSObject {
    var asset: DKAsset!
    var imageID = ""
    var picObj = ""
}

class TicketListRequestObject: NSObject {
    var keyword = ""
    var filter  : InboxTicketFilterType = .all
    var status  : InboxCustomerServiceType  = .all
}

class ReplyTicketRequestObject: NSObject {
    var newTicketStatus = ""
    var ticketID = ""
    var message = ""
    var selectedImages : [AttachedImageObject] = []
    var rate = ""
    
    var isHasImage : String {
        if selectedImages.count>0 {
            return "1"
        }
        return ""
    }
}

class InboxTicketRequest: NSObject {
    
    class func fetchListTicket(_ objectRequest: TicketListRequestObject, page: NSInteger, onSuccess: @escaping ((InboxTicketResult) -> Void), onFailure: @escaping (() -> Void)) {
        
        let param : [String : String] = [
            "filter"  : objectRequest.filter.description(),
            "keyword" : objectRequest.keyword,
            "page"    : "\(page)",
            "status"  : "\(objectRequest.status.rawValue)"
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString.v4Url(),
                                          path: "/v4/inbox-ticket/get_inbox_ticket.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: V4Response<AnyObject>.mapping(withData: InboxTicketResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : V4Response<AnyObject> = result[""] as! V4Response<AnyObject>
                                            let data = response.data as! InboxTicketResult
                                            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                onSuccess(data)
                                            }
        }) { (error) in
            onFailure()
        }
    }
    
    class func fetchDetailTicket(_ ticketID: String, isLoadMore: Bool, page: NSInteger, onSuccess: @escaping ((InboxTicketResultDetail) -> Void), onFailure: @escaping (() -> Void)) {
        
        var param : [String : String] = [:]
        var path = ""

        if isLoadMore {
            param.update([
                "ticket_id"  : ticketID,
                "page"       : "\(page)"
                ])
            path =  "/v4/inbox-ticket/get_inbox_ticket_view_more.pl"
        } else {
            param.update(["ticket_inbox_id"  : ticketID])
            path = "/v4/inbox-ticket/get_inbox_ticket_detail.pl"
        }
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.request(withBaseUrl: NSString.v4Url(),
                                          path: path,
                                          method: .GET,
                                          parameter: param,
                                          mapping: V4Response<AnyObject>.mapping(withData: InboxTicketResultDetail.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response : V4Response = result[""] as! V4Response<InboxTicketResultDetail>
                                            let data = response.data as InboxTicketResultDetail
                                            
                                            if response.message_error.count > 0{
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                onFailure()
                                            } else {
                                                onSuccess(data)
                                            }
        }) { (error) in
            onFailure()
        }
    }
    
    class func fetchReplyTicket(_ objectRequest: ReplyTicketRequestObject, onSuccess: @escaping (() -> Void), onFailure: @escaping (() -> Void)) {
        
        var host : GeneratedHost?
        var postKeyParam : String?
        
        _ = GenerateHostObservable.getGeneratedHost()
            .flatMap { (generatedHost) -> Observable<String> in
                host = generatedHost
                
                return self.getPostKeyReplyTicket(objectRequest, host: host!).do(onCompleted: {
                    onSuccess()
                    return
                })
            }
            .flatMap{ (postkey) -> Observable<[ImageResult]> in
                postKeyParam = postkey
                
                let postObject = UploadImageRequestObject()
                postObject.selectedImages = objectRequest.selectedImages
                postObject.host = host!
                
                return UploadImageObserver.getUploadedAttachments(postObject)
            }
            .flatMap { (imageResults) ->  Observable<String> in
                
                return self.getFileUploaded(objectRequest, host: host!)
            }
            .flatMap{ (fileUploaded) -> Observable<String> in
                return self.submitReplyTicket(fileUploaded, postKey: postKeyParam!, ticketID: objectRequest.ticketID)
            }
            .subscribe(onNext: {(success) in
                    onSuccess()
                }, onError: { (error) in
                    onFailure()
                }
            )
    }
    
    fileprivate class func getPostKeyReplyTicket(_ postData:ReplyTicketRequestObject, host: GeneratedHost)-> Observable<String>{
        
        let imageIds = postData.selectedImages.map{$0.imageID}
        let imageIdParam = imageIds.joined(separator: "~")
        
        let imagesDictionary : NSMutableDictionary = NSMutableDictionary()
        postData.selectedImages.forEach { (imageObj) in
            imagesDictionary[imageObj.imageID] = [
                "image_id" : imageObj.imageID,
                "is_temp" : "1"
            ]
        }
        
        let param : [String : String] = [
            "new_ticket_status" : postData.newTicketStatus,
            "server_id"         : host.server_id,
            "ticket_id"         : postData.ticketID,
            "ticket_reply_message" : postData.message,
            "rate"              : postData.rate,
            "p_photo"           : postData.isHasImage,
            "prd_pic_obj"       : imagesDictionary.json,
            "p_photo_all"       : imageIdParam
        ]
        
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.request(withBaseUrl: NSString .v4Url(),
                path: "/v4/action/ticket/reply_ticket_validation.pl",
                method: .POST,
                parameter: param,
                mapping: V4Response<AnyObject>.mapping(withData: ReplyInboxTicketResult.mapping()),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : V4Response<AnyObject> = result[""] as! V4Response<AnyObject>
                    let data = response.data as! ReplyInboxTicketResult
                    
                    guard response.message_error.count == 0 else {
                        StickyAlertView.showErrorMessage(response.message_error)
                        observer.onError(RequestError.networkError as Error)
                        return;
                    }
                    
                    guard data.post_key != nil else {
                        observer.onCompleted()
                        return;
                    }
                    
                    observer.onNext(data.post_key)
                    
            }) { (error) in
                observer.onError(RequestError.networkError as Error)
            }
            
            return Disposables.create()
        })
        
    }
    
    fileprivate class func getFileUploaded(_ postData:ReplyTicketRequestObject, host: GeneratedHost)-> Observable<String>{
        
        let imagesDictionary : NSMutableDictionary = NSMutableDictionary()
        postData.selectedImages.forEach { (imageObj) in
            imagesDictionary[imageObj.imageID] = imageObj.picObj
        }
        
        return Observable.create({ (observer) -> Disposable in
            observer.onNext(imagesDictionary.json)
            
            return Disposables.create()
            
        })
    }
    
    fileprivate class func submitReplyTicket(_ fileUploaded: String, postKey: String, ticketID: String)-> Observable<String>{
        
        let param : [String : String] = [
            "file_uploaded" : fileUploaded,
            "post_key"      : postKey,
            "ticket_id"     : ticketID,
        ]
        
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.request(withBaseUrl: NSString .v4Url(),
                path: "/v4/action/ticket/reply_ticket_submit.pl",
                method: .POST,
                parameter: param,
                mapping: V4Response<AnyObject>.mapping(withData: ReplyInboxTicketResult.mapping()),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response : V4Response<AnyObject> = result[""] as! V4Response<AnyObject>
                    
                    if response.message_error.count > 0{
                        StickyAlertView.showErrorMessage(response.message_error)
                    }
                    
                    if (response.data.is_success == "1") {
                        observer.onNext("1")
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError as Error)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError as Error)
            }
            
            return Disposables.create()
        })
        
    }
}

