//
//  PromoUnbox.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 10/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox
import Foundation

struct PromoUnbox {
    let cacheExpire: Int
    let list: [PromoDetail]
}

extension PromoUnbox: Unboxable {
    init(unboxer: Unboxer) throws {
        self.cacheExpire = try unboxer.unbox(keyPath: "data.cache_expire")
        self.list = try unboxer.unbox(keyPath: "data.list") as [PromoDetail]
    }
}

struct PromoDetail {
    let type: String
    let id: String
    let code: String
    let codeHTML: String
    let targetURL: String
    let shortDesc: String
    let shortDescHTML: String
    let shortCond: String
    let shortCondHTML: String
}

extension PromoDetail: Unboxable {
    init(unboxer: Unboxer) throws {
        self.type = try unboxer.unbox(key: "type")
        self.id = try unboxer.unbox(key: "id")
        self.code = try unboxer.unbox(keyPath: "attributes.code")
        self.codeHTML = try unboxer.unbox(keyPath: "attributes.code_html")
        self.targetURL = try unboxer.unbox(keyPath: "attributes.target_url")
        self.shortDesc = try unboxer.unbox(keyPath: "attributes.short_desc")
        self.shortDescHTML = try unboxer.unbox(keyPath: "attributes.short_desc_html")
        self.shortCond = try unboxer.unbox(keyPath: "attributes.short_cond")
        self.shortCondHTML = try unboxer.unbox(keyPath: "attributes.short_cond_html")
    }
}
