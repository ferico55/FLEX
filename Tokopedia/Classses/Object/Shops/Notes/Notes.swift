//
//  Notes.swift
//  Tokopedia
//
//  Created by Tedo Pranowo on 7/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class NotesSwift: NSObject {
    
    var status : NSString = ""
    var server_process_time : NSString = ""
    var result : NotesResultSwift = NotesResultSwift()
    
    
    class private func attributeMappingDictionary() -> [NSObject : AnyObject]! {
        return ["status" : "status",
                "server_process_time" : "server_process_time"]
    }
    
    class func mapping() -> RKObjectMapping! {
        let mapping : RKObjectMapping = RKObjectMapping.init(forClass: self)
        
        mapping.addAttributeMappingsFromDictionary(self.attributeMappingDictionary())
        mapping.addPropertyMapping(RKRelationshipMapping.init(fromKeyPath: "data", toKeyPath: "result", withMapping: NotesResultSwift.mapping()))
        
        return mapping
    }
}
