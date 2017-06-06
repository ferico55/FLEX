//
//  ProductBadge.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox
import RestKit

@objc(ProductBadge)
final class ProductBadge:NSObject, Unboxable {
    var title:String = ""
    var image_url:String = ""
    
    static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)!
        mapping.addAttributeMappings(from: ["title", "color"])
        return mapping
    }
    
    override init() {
    }
    
    init(title:String, image_url:String) {
        self.title = title
        self.image_url = image_url
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            title: try unboxer.unbox(keyPath:"title"),
            image_url: try unboxer.unbox(keyPath: "image_url")
        )
    }
}
