//
//  CategoryIntermediaryResponse.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class CategoryIntermediaryResponse: NSObject, Unboxable {
    
    var server_process_time: String!
    var result: CategoryIntermediaryResult!
    
    init(server_process_time:String, result:CategoryIntermediaryResult) {
        self.server_process_time = server_process_time
        self.result = result
    }

    convenience init(unboxer:Unboxer) throws {
        self.init(
            server_process_time : try unboxer.unbox(keyPath: "server_process_time"),
            result : try unboxer.unbox(keyPath: "result")
        )
    }
}
