//
//  InboxTicketRequest.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 8/2/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class InboxTicketRequest: NSObject {
    class func requestInboxTicketList(status: NSString,
                                      filter: NSString,
                                      page: NSNumber,
                                onSuccess:(InboxTicket -> Void),
                                onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        let parameter = ["action" : "get_inbox_ticket",
                         "status" : "\(status)",
                         "filter" : "\(filter)",
                         "page"   : "\(page)"
                        ]
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/inbox-ticket/get_inbox_ticket.pl",
                                          method: .GET,
                                          parameter: parameter,
                                          mapping: InboxTicket.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : InboxTicket = result[""] as! InboxTicket
                                            onSuccess(response)
                                            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
                                            })
    }
    
    class func requestInboxTicketDetail(ticketInboxId:NSString,
                                        onSuccess:(DetailInboxTicket -> Void),
                                        onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/inbox-ticket/get_inbox_ticket_detail.pl",
                                          method: .GET,
                                          parameter: ["ticket_inbox_id" : "\(ticketInboxId)"],
                                          mapping: DetailInboxTicket.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : DetailInboxTicket = result[""] as! DetailInboxTicket
                                            onSuccess(response)
            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
        })

    }
    
    class func requestInboxTicketViewMore(ticketId:NSString,
                                        onSuccess:(DetailInboxTicket -> Void),
                                        onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/inbox-ticket/get_inbox_ticket_view_more.pl",
                                          method: .GET,
                                          parameter: ["ticket_id" : "\(ticketId)"],
                                          mapping: DetailInboxTicket.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : DetailInboxTicket = result[""] as! DetailInboxTicket
                                            onSuccess(response)
            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
        })
        
    }
    
    class func requestTicketGiveRating(ticketId:NSString,
                                          onSuccess:(DetailInboxTicket -> Void),
                                          onFailure:(NSError -> Void))
    {
        let networkManager : TokopediaNetworkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                          path: "/v4/inbox-ticket/get_inbox_ticket_view_more.pl",
                                          method: .GET,
                                          parameter: ["ticket_id" : "\(ticketId)"],
                                          mapping: DetailInboxTicket.mapping(),
                                          onSuccess: { (successResult, _) in
                                            let result : Dictionary = successResult.dictionary() as Dictionary
                                            let response : DetailInboxTicket = result[""] as! DetailInboxTicket
                                            onSuccess(response)
            },
                                          onFailure: { (errorResult) in
                                            onFailure(errorResult)
        })
        
    }

}
