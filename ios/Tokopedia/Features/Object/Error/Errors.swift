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

@objc(Errors)
final class Errors:NSObject, Unboxable {
    var name:String = ""
    var title:String = ""
    var desc:String?
    
    override init() { }
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["name":"name",
                                            "title":"title",
                                            "description":"desc"])
        return mapping
    }
    
    init(name:String, title:String, desc:String? = nil) {
        self.name = name
        self.title = title
        self.desc = desc
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            name: try unboxer.unbox(keyPath:"name"),
            title: try unboxer.unbox(keyPath:"title"),
            desc: try? unboxer.unbox(keyPath:"description")
        )
    }
}
