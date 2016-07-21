//
//  NoteDetailResult.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/5/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class NoteDetailResult : NSObject, TKPObjectMapping
{
    var detail : NoteDetails = NoteDetails()
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "detail", toKeyPath: "detail", withMapping: NoteDetails.mapping()))
        
        return mapping
    }
    
}