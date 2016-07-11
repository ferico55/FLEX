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
    
    func requestNoteDetail(shopId:NSNumber, noteId: NSNumber, terms:NSNumber, onSuccess:(NoteDetail, RKObjectRequestOperation) -> Void, onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true

        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/notes/get_notes_detail.pl",
                                          method: .GET,
                                          parameter: ["shop_id" : "\(shopId)", "note_id" : "\(noteId)", "terms" : "\(terms)"],
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
