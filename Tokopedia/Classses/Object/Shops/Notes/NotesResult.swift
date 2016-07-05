//
//  NotesResult.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class NotesResultSwift : NSObject{
    
    var is_allow : NSNumber = 0
    var allow_add : NSNumber = 0
    var has_terms : NSNumber = 0
    var list : Array<NotesListSwift> = Array<NotesListSwift>()
    var detail : NoteDetails = NoteDetails()
    
    class private func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["is_allow" : "is_allow",
                "allow_add" : "allow_add",
                "has_terms" : "has_terms"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        
        let listMapping = RKRelationshipMapping.init(fromKeyPath: "list", toKeyPath: "list", withMapping: NotesListSwift.mapping())
        mapping.addPropertyMapping(listMapping)
        
        return mapping
    }
}
