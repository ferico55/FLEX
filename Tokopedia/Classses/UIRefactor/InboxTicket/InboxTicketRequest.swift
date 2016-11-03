//
//  InboxTicketRequest.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 10/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc enum InboxTicketFilterType :Int {
    case All, Unread
    func description() -> String {
        switch self {
        case .All:
            return "all"
        case .Unread:
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
    var filter  : InboxTicketFilterType = .All
    var status  : InboxCustomerServiceType  = .All
}

class ReplayTicketRequestObject: NSObject {
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
    
    class func fetchListTicket(objectRequest: TicketListRequestObject, page: NSInteger, onSuccess: ((InboxTicketResult) -> Void), onFailure: (() -> Void)) {
        
        let param : [String : String] = [
            "filter"  : objectRequest.filter.description(),
            "keyword" : objectRequest.keyword,
            "page"    : "\(page)",
            "status"  : "\(objectRequest.status.rawValue)"
        ]
        
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/inbox-ticket/get_inbox_ticket.pl",
                                          method: .GET,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(InboxTicketResult.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
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
    
    class func fetchDetailTicket(ticketID: String, isLoadMore: Bool, page: NSInteger, onSuccess: ((InboxTicketResultDetail) -> Void), onFailure: (() -> Void)) {
        
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
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: path,
                                          method: .GET,
                                          parameter: param,
                                          mapping: V4Response.mappingWithData(InboxTicketResultDetail.mapping()),
                                          onSuccess: { (mappingResult, operation) in
                                            
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
                                            let data = response.data as! InboxTicketResultDetail
                                            
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
    
    class func fetchReplayTicket(objectRequest: ReplayTicketRequestObject, onSuccess: (() -> Void), onFailure: (() -> Void)) {
        
        var host : GeneratedHost?
        var postKeyParam : String?
        
        _ = GenerateHostObservable.getGeneratedHost()
            .flatMap { (generatedHost) -> Observable<String> in
                host = generatedHost
                
                return self.getPostKeyReplayTicket(objectRequest, host: host!).doOnCompleted({ 
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
                return self.submitReplayTicket(fileUploaded, postKey: postKeyParam!, ticketID: objectRequest.ticketID)
            }
            .subscribe(onNext: {(success) in
                    onSuccess()
                }, onError: { (error) in
                    onFailure()
                }
            )
    }
    
    private class func getPostKeyReplayTicket(postData:ReplayTicketRequestObject, host: GeneratedHost)-> Observable<String>{
        
        let imageIds = postData.selectedImages.map{$0.imageID}
        let imageIdParam = imageIds.joinWithSeparator("~")
        
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
            networkManager.requestWithBaseUrl(NSString .v4Url(),
                path: "/v4/action/ticket/reply_ticket_validation.pl",
                method: .POST,
                parameter: param,
                mapping: V4Response.mappingWithData(ReplyInboxTicketResult.mapping()),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response = result[""] as! V4Response
                    let data = response.data as! ReplyInboxTicketResult
                    
                    guard response.message_error.count == 0 else {
                        StickyAlertView.showErrorMessage(response.message_error)
                        observer.onError(RequestError.networkError)
                        return;
                    }
                    
                    guard data.post_key != nil else {
                        observer.onCompleted()
                        return;
                    }
                    
                    observer.onNext(data.post_key)
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
            }
            
            return NopDisposable.instance
        })
        
    }
    
    private class func getFileUploaded(postData:ReplayTicketRequestObject, host: GeneratedHost)-> Observable<String>{
        
        let imagesDictionary : NSMutableDictionary = NSMutableDictionary()
        postData.selectedImages.forEach { (imageObj) in
            imagesDictionary[imageObj.imageID] = imageObj.picObj
        }
        
        return Observable.create({ (observer) -> Disposable in
            observer.onNext(imagesDictionary.json)
            
            return NopDisposable.instance
            
        })
    }
    
    private class func submitReplayTicket(fileUploaded: String, postKey: String, ticketID: String)-> Observable<String>{
        
        let param : [String : String] = [
            "file_uploaded" : fileUploaded,
            "post_key"      : postKey,
            "ticket_id"     : ticketID,
        ]
        
        
        return Observable.create({ (observer) -> Disposable in
            let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            networkManager.requestWithBaseUrl(NSString .v4Url(),
                path: "/v4/action/ticket/reply_ticket_submit.pl",
                method: .POST,
                parameter: param,
                mapping: V4Response.mappingWithData(ReplyInboxTicketResult.mapping()),
                onSuccess: { (mappingResult, operation) in
                    
                    let result : Dictionary = mappingResult.dictionary() as Dictionary
                    let response = result[""] as! V4Response
                    
                    if response.message_error.count > 0{
                        StickyAlertView.showErrorMessage(response.message_error)
                    }
                    
                    if (response.data.is_success == "1") {
                        observer.onNext("1")
                        observer.onCompleted()
                    } else {
                        observer.onError(RequestError.networkError)
                    }
                    
            }) { (error) in
                observer.onError(RequestError.networkError)
            }
            
            return NopDisposable.instance
        })
        
    }
}

extension NSDictionary {
    
    var json: String {
        let invalidJson = ""
        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(self, options: NSJSONWritingOptions(rawValue: 0))
            return String(data: jsonData,
                encoding: NSASCIIStringEncoding) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
}
