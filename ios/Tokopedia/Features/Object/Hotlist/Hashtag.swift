//
//  Hashtag.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

@objc(Hashtag)
final class Hashtag : NSObject, Unboxable {
    var name:String?
    var url:String?
    var department_id:String?
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["name", "url", "department_id"])
        return mapping
    }
    
    override init() {
        self.name = ""
        self.url = ""
        self.department_id = "";
        //do nothing
    }
    
    init(name:String, url:String, department_id:String) {
        self.name = name
        self.url = url
        self.department_id = department_id
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            name: try unboxer.unbox(keyPath: "name"),
            url: try unboxer.unbox(keyPath: "url"),
            department_id: try unboxer.unbox(keyPath: "department_id")
        )
    }
}
