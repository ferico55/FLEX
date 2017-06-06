//
//  IntermediarySlide.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class IntermediarySlide: Slide, Unboxable {
    
    required public convenience init(unboxer:Unboxer) throws {
        self.init()
        self.title = unboxer.unbox(keyPath: "title")
        self.message = unboxer.unbox(keyPath: "description")
        self.image_url = unboxer.unbox(keyPath: "image_url")
        self.redirect_url = unboxer.unbox(keyPath: "redirect_url")
        self.applinks = unboxer.unbox(keyPath: "applinks")
    }

}
