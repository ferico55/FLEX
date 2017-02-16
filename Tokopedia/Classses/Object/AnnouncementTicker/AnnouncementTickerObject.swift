//
//  AnnouncementTickerObject.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AnnouncementTickerObject: NSObject {
    var ticker_id: String = ""
    var title: String = ""
    var message: String = ""
    var target: String = ""
    var device: String = ""
    var expire_time: String = ""
    var created_by: String = ""
    var created_on: String = ""
    var updated_by: String = ""
    var updated_on: String = ""
    var status: String = ""
    var color : String = ""
    
    static func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(forClass: self)
        
        mapping.addAttributeMappingsFromDictionary(
            [
                "id" : "ticker_id",
                "title" : "title",
                "message" : "message",
                "target" : "target",
                "device" : "device",
                "status" : "status",
                "expire_time" : "expire_time",
                "created_by" : "created_by",
                "created_on" : "created_on",
                "updated_by" : "updated_by",
                "updated_on" : "updated_on",
                "color" : "color"
            ]
        )
        
        return mapping
    }
}
