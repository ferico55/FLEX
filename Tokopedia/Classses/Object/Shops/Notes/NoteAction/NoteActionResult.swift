//
//  NoteActionResult.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class NoteActionResult : NSObject, TKPObjectMapping
{
    var note_id : String = ""
    var is_success : String = ""
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addAttributeMappingsFromArray(["note_id", "is_success"])
        
        return mapping
    }
    
}