//
//  NotesList.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class NotesListSwift : NSObject{
    
    var note_id : NSString = ""
    var note_status : NSNumber = 0
    var note_title : NSString = ""
    
    class private func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["note_id" :"note_id",
                "note_status" : "note_status",
                "note_title" : "note_title"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        return mapping
    }
    
}