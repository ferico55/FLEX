//
//  ProductLabel.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox
import RestKit

@objc(ProductLabel)
final class ProductLabel:NSObject, Unboxable {
    var title:String = ""
    var color:String = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["title", "color"])
        return mapping
    }
    
    override init () {
    }
    
    init(title:String, color:String) {
        self.title = title
        self.color = color
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            title: try unboxer.unbox(keyPath: "title"),
            color: try unboxer.unbox(keyPath: "color")
        )
    }
}
