//
//  CategoryIntermediaryChild.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(CategoryIntermediaryChild)
public final class CategoryIntermediaryChild: NSObject, Unboxable {
    
    public var id: String = ""
    public var name: String = ""
    public var url: String = ""
    public var thumbnailImage:String?
    public var hidden: Int = 0
    // isRevamp digunakan sebagai penanda apakah category memiliki design sub category yang bergambar atau tidak
    public var isRevamp: Bool = false
    // isIntermediary digunakan sebagai penanda apakah category termasuk intermediary atau bukan (memiliki hotlist, top editor choice, top ads toko)
    public var isIntermediary: Bool = false
    public var rootCategoryId = ""
    public var applinks = ""
    
    convenience public init(unboxer:Unboxer) throws {
        self.init()
        self.id = try unboxer.unbox(keyPath: "id")
        self.name = try unboxer.unbox(keyPath: "name")
        self.url = try unboxer.unbox(keyPath: "url")
        self.hidden = try unboxer.unbox(keyPath: "hidden")
        if let thumbnailImage = try? unboxer.unbox(keyPath: "thumbnail_image") as String {
            self.thumbnailImage = thumbnailImage
        }
        self.isRevamp = try unboxer.unbox(keyPath: "is_revamp")
        self.isIntermediary = try unboxer.unbox(keyPath: "is_intermediary")
        self.rootCategoryId = try unboxer.unbox(keyPath: "root_category_id")
        self.applinks = try unboxer.unbox(keyPath: "applinks")
    }
}
