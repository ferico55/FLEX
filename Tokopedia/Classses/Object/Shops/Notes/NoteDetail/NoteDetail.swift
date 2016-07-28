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
    
    class func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["status" : "status",
                "server_process_time" : "server_process_time"]
    }
    
    class func mapping() -> RKObjectMapping!{
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addAttributeMappingsFromDictionary(attributeMappingDictionary())
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "result", withMapping: NoteDetailResult.mapping()))
        
        return mapping
    }
}