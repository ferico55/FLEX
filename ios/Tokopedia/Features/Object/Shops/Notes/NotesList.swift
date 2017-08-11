//
//  NotesList.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class NotesList : NSObject{
    
    var note_id : NSString = ""
    var note_status : NSString = ""
    var note_title : NSString = ""
    
    class fileprivate func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["note_id" :"note_id",
                "note_status" : "note_status",
                "note_title" : "note_title"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        return mapping
    }
    
}
