//
//  NoteDetails.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class NoteDetails : NSObject, TKPObjectMapping
{
    var notes_position : NSString = ""
    var notes_status : NSString = ""
    var notes_create_time : NSString = ""
    var notes_id : NSString = ""
    var notes_title : NSString = ""
    var notes_active : NSString = ""
    var notes_update_time : NSString = ""
    var notes_content : NSString = ""
    
    class func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["notes_position" : "notes_position",
                "notes_status" : "notes_status",
                "notes_create_time" : "notes_create_time",
                "notes_id" : "notes_id",
                "notes_title" : "notes_title",
                "notes_active" : "notes_active",
                "notes_update_time" : "notes_update_time",
                "notes_content" : "notes_content"]
    }
    
    class func mapping() -> RKObjectMapping! {
        
        let mapping : RKObjectMapping! = RKObjectMapping(for: self)
        
        mapping.addAttributeMappings(from:attributeMappingDictionary())
        
        return mapping
    }
    
}
