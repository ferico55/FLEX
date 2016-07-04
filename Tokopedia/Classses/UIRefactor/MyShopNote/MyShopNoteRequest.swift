//
//  MyShopNoteRequest.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class MyShopNoteRequest: NSObject {
    
    func requestNoteList(onSuccess:(NotesSwift -> Void), onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/myshop-note/get_shop_note.pl",
                                          method: .GET,
                                          parameter: [:],
                                          mapping: NotesSwift.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : NotesSwift = result[""] as! NotesSwift
                                            onSuccess(response)
                                            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
                                            })
        
    }
    
    func requestDeleteNote(noteId:AnyObject, onSuccess:(ShopSettings -> Void), onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                            path:"/v4/action/myshop-note/delete_shop_note.pl",
                                            method: .POST,
                                            parameter: ["note_id" : noteId as! String],
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
}
