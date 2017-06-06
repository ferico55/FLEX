//
//  Errors.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class ErrorsSwift:NSObject, Unboxable {
    let name:String
    let title:String
    let desc:String
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["name":"name",
                                            "title":"title",
                                            "description":"desc"])
        return mapping
    }
    
    init(name:String, title:String, desc:String) {
        self.name = name
        self.title = title
        self.desc = desc
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            name: try unboxer.unbox(keyPath:"name"),
            title: try unboxer.unbox(keyPath:"title"),
            desc: try unboxer.unbox(keyPath:"description")
        )
    }
}
