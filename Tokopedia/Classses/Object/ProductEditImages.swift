//
//  ProductEditImages.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import DKImagePickerController

class ProductEditImages: NSObject {
    var image_description: String = ""
    var image_src: String = ""
    var image_id: String = ""
    var image_status: String = ""
    var image_primary: String = ""
    var image_src_300: String = ""
    var image : UIImage = UIImage()
    var fileUploaded : String = ""
    var asset : DKAsset?
    var isFromAsset : Bool = false
    
    static func mapping() -> RKObjectMapping! {
        let mapping = RKObjectMapping(for: self)
        
        mapping?.addAttributeMappings(from:[
            "image_description" : "image_description",
            "image_src" : "image_src",
            "image_id" : "image_id",
            "image_status" : "image_status",
            "image_primary" : "image_primary",
            "image_src_300" : "image_src_300"
        ])
        
        return mapping
    }
}
