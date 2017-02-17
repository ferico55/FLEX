//
//  Notes.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class Notes: NSObject {
    
    var status : NSString = ""
    var server_process_time : NSString = ""
    var result : NotesResult = NotesResult()
    
    
    class fileprivate func attributeMappingDictionary() -> [AnyHashable: Any]! {
        return ["status" : "status",
                "server_process_time" : "server_process_time"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        
        mapping.addAttributeMappings(from:self.attributeMappingDictionary())
        mapping.addPropertyMapping(RKRelationshipMapping(fromKeyPath: "data", toKeyPath: "result", with: NotesResult.mapping()))
        
        return mapping
    }
}
