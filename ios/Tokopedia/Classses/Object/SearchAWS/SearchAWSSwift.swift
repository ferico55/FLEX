//
//  SearchAWS.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class SearchAWSSwift : Unboxable {
    let status:String
    let server_process_time:String
    let header:EnvelopeHeader
    let data:SearchAWSResult
    
    init(status:String, server_process_time:String, header:EnvelopeHeader, data:SearchAWSResult) {
        self.status = status
        self.server_process_time = server_process_time
        self.header = header
        self.data = data
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            status: try unboxer.unbox(keyPath: "status") as String,
            server_process_time: try unboxer.unbox(keyPath: "server_process_time") as String,
            header: EnvelopeHeader(),
            data: SearchAWSResult()
        )
    }
}
