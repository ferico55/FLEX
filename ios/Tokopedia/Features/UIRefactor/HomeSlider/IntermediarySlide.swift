//
//  IntermediarySlide.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(IntermediarySlide)
final class IntermediarySlide: Slide, Unboxable {
    
    // these new variable is used for react native, based variable from class Slide cannot be wrapped to JSON because they are from obj-c
    var imageUrl: String = ""
    var title: String = ""
    var appLinks: String = ""
    
    required public convenience init(unboxer:Unboxer) throws {
        self.init()
        self.bannerTitle = unboxer.unbox(keyPath: "title")
        self.message = unboxer.unbox(keyPath: "description")
        self.image_url = unboxer.unbox(keyPath: "image_url")
        self.redirect_url = unboxer.unbox(keyPath: "redirect_url")
        self.applinks = unboxer.unbox(keyPath: "applinks")
        self.imageUrl = image_url
        self.title = bannerTitle
        self.appLinks = applinks
    }

}
