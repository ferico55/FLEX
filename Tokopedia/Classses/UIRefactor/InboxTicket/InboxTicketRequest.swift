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

class TicketListRequestObject: NSObject {
    var keyword = ""
    var filter  : InboxTicketFilterType = .All
    var status  : InboxCustomerServiceType  = .All
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

}
