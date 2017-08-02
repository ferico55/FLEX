//
//  ShopProductPageCampaignInfoResponse.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

final class ShopProductPageCampaignInfoResponse : Unboxable {
    let data:[ShopProductPageCampaignInfo]
    let message:String
    let process_time:String
    
    init(data:[ShopProductPageCampaignInfo], message:String, proccess_time:String) {
        self.data = data
        self.message = message
        self.process_time = proccess_time
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            data: try unboxer.unbox(keyPath:"data"),
            message: try unboxer.unbox(keyPath:"message"),
            proccess_time: try unboxer.unbox(keyPath:"process-time")
        )
    }
}
