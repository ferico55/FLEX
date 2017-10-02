//
//  CategoryIntermediaryBanner.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(CategoryIntermediaryBanner)
final class CategoryIntermediaryBanner:NSObject, Unboxable {
    
    var images: [IntermediarySlide]!
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        self.images = unboxer.unbox(keyPath: "images")
    }

}
