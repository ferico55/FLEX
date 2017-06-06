//
//  CategoryIntermediaryChild.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

@objc(CategoryIntermediaryChild)
final class CategoryIntermediaryChild: NSObject, Unboxable {
    
    var id: String = ""
    var name: String = ""
    var url: String = ""
    var thumbnailImage:String?
    var hidden: Int = 0
    // isRevamp digunakan sebagai penanda apakah category memiliki design sub category yang bergambar atau tidak
    var isRevamp: Bool = false
    // isIntermediary digunakan sebagai penanda apakah category termasuk intermediary atau bukan (memiliki hotlist, top editor choice, top ads toko)
    var isIntermediary: Bool = false
    
    class func mapping() -> RKObjectMapping {
        let mapping: RKObjectMapping = RKObjectMapping(for: CategoryIntermediaryChild.self)
        mapping.addAttributeMappings(from:["id", "name", "url", "hidden"])
        mapping.addAttributeMappings(from: ["thumbnail_image" : "thumbnailImage",
                                            "is_revamp" : "isRevamp",
                                            "is_intermediary" : "isIntermediary"])
        return mapping;
    }
    
    init(id:String,
         name:String,
         url:String,
         hidden:Int,
         thumbnailImage:String?,
         isRevamp:Bool,
         isIntermediary:Bool) {
        self.id = id
        self.name = name
        self.hidden = hidden
        self.url = url
        self.thumbnailImage = thumbnailImage
        self.isRevamp = isRevamp
        self.isIntermediary = isIntermediary
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            id : try unboxer.unbox(keyPath: "id"),
            name : try unboxer.unbox(keyPath: "name"),
            url : try unboxer.unbox(keyPath: "url"),
            hidden : try unboxer.unbox(keyPath: "hidden"),
            thumbnailImage : try? unboxer.unbox(keyPath: "thumbnail_image") as String,
            isRevamp : try unboxer.unbox(keyPath: "is_revamp"),
            isIntermediary : try unboxer.unbox(keyPath: "is_intermediary")
        )
    }
}
