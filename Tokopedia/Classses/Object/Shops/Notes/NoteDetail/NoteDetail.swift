//
//  NoteDetail.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class NoteDetail : NSObject, TKPObjectMapping
{
    var status : NSString = ""
    var server_process_time : NSString = ""
    var result : NoteDetailResult = NoteDetailResult()
    
    class func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["status" : "status",
                "server_process_time" : "server_process_time"]
    }
    
    class func mapping() -> RKObjectMapping!{
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        mapping.addAttributeMappings(from:attributeMappingDictionary())
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "result", with: NoteDetailResult.mapping()))
        
        return mapping
    }
}
