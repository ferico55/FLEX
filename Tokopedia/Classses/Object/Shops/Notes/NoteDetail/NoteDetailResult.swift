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
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "detail", toKeyPath: "detail", with: NoteDetails.mapping()))
        
        return mapping
    }
    
}
