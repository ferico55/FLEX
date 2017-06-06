//
//  SearchProductWrapper.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(SearchProductWrapper)
final class SearchProductWrapper: NSObject, Unboxable {
    let status:String
    let serverProcessTime:String
    let header:EnvelopeHeader?
    let data:SearchProductResult
    
    init(status:String,
         server_process_time:String,
         header:EnvelopeHeader?,
         data:SearchProductResult) {
        self.status = status
        self.serverProcessTime = server_process_time
        self.header = header
        self.data = data
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            status: try unboxer.unbox(keyPath: "status"),
            server_process_time: try unboxer.unbox(keyPath: "server_process_time"),
            header: try? unboxer.unbox(keyPath: "header") as EnvelopeHeader,
            data: try unboxer.unbox(keyPath: "data")
        )
    }
}
