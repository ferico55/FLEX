//
//  MyShopNoteRequest.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class MyShopNoteRequest: NSObject {
    func requestNoteList(onSuccess:(Notes -> Void), onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/myshop-note/get_shop_note.pl",
                                          method: .GET,
                                          parameter: [:],
                                          mapping: Notes.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : Notes = result[""] as! Notes
                                            onSuccess(response)
                                            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
                                            })
        
    }
    
    func requestAddNoteWithTitle(noteTitle:String,
                                 noteContent:String,
                                 terms:String,
                                 onSuccess:(NoteAction -> Void),
                                 onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/action/myshop-note/add_shop_note.pl",
                                          method: .POST,
                                          parameter: ["note_content":noteContent, "note_title":noteTitle, "terms":terms],
                                          mapping: NoteAction.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : NoteAction = result[""] as! NoteAction
                                            onSuccess(response)
                                            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
                                            })
    }
    
    func requestEditNote(noteId:String,
                         noteTitle:String,
                         noteContent:String,
                         terms:String,
                         onSuccess:(NoteAction -> Void),
                         onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/action/myshop-note/edit_shop_note.pl",
                                          method: .POST,
                                          parameter: ["note_content":noteContent, "note_id":noteId, "note_title":noteTitle, "terms":terms],
                                          mapping: NoteAction.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : NoteAction = result[""] as! NoteAction
                                            onSuccess(response)
                                          },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
                                          })
    }
    
    func requestDeleteNote(noteId:String, onSuccess:(ShopSettings -> Void), onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                            path:"/v4/action/myshop-note/delete_shop_note.pl",
                                            method: .POST,
                                            parameter: ["note_id" : noteId],
                                            mapping: ShopSettings.mapping(),
                                            onSuccess: { (successResult, _) in
                                                let result : Dictionary = successResult.dictionary() as Dictionary
                                                let response : ShopSettings = result[""] as! ShopSettings
                                                onSuccess(response)
                                            },
                                            onFailure: { (errorResult) in
                                                onFailure(errorResult)
                                            })
    }
    
    func requestNoteDetail(shopId:NSNumber, shopDomain: String, noteId: NSNumber, terms:NSNumber, onSuccess:(NoteDetail, RKObjectRequestOperation) -> Void, onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/notes/get_notes_detail.pl",
                                          method: .GET,
                                          parameter: ["shop_id" : "\(shopId)", "shop_domain" : shopDomain, "note_id" : "\(noteId)", "terms" : "\(terms)"],
                                          mapping: NoteDetail.mapping(),
                                          onSuccess: { (successResult, operation) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : NoteDetail = result[""] as! NoteDetail
                                            onSuccess(response, operation)
                                            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
        })
    }
}
