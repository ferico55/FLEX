//
//  NoteAction.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class NoteAction : NSObject, TKPObjectMapping
{
    var status : String = ""
    var message_status : NSArray = []
    var server_process_time : String = ""
    var result : NoteActionResult = NoteActionResult()
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addAttributeMappingsFromArray(["status", "message_status", "server_process_time"])
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "result", withMapping: NoteActionResult.mapping()))
        
        return mapping
    }
    
}