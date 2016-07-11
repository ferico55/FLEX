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
    
    
//    "status": "OK",
//    "config": null,
//    "server_process_time": "0.016287",
//    "result": {
//    "detail": {
//    "notes_position": "3",
//    "notes_status": "2",
//    "notes_create_time": "11 Agustus 2015, 15:58",
//    "notes_id": "520",
//    "notes_title": "Kebijakan Pengembalian Produk",
//    "notes_active": 1,
//    "notes_update_time": "",
//    "notes_content": "<p>eqweqweqweqweqweqw</p>"
//    }
}