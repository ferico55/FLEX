//
//  NotesResult.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit

class NotesResult : NSObject{
    
    var is_allow : NSString = ""
    var allow_add : NSString = ""
    var has_terms : NSString = ""
    var list : Array<NotesList> = Array<NotesList>()
    var detail : NoteDetails = NoteDetails()
    
    class fileprivate func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["is_allow" : "is_allow",
                "allow_add" : "allow_add",
                "has_terms" : "has_terms"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        
        let listMapping = RKRelationshipMapping(fromKeyPath: "list", toKeyPath: "list", with: NotesList.mapping())
        mapping.addPropertyMapping(listMapping)
        
        return mapping
    }
}
