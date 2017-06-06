//
//  SearchProductResult.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 6/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(SearchProductResult)
final class SearchProductResult : NSObject, Unboxable {
    let searchUrl:String?
    let paging:Paging?
    let hasCatalog:Int
    let products:[SearchProduct]?
    let departmentId:String?
    let st:String?
    let hashtags:[Hashtag]?
    let breadcrumb:[CategoryDetail]?
    let redirectUrl:String?
    let shareUrl:String?
    let catalogs:[SearchProduct]?
    
    init(searchUrl:String?,
         paging: Paging?,
         hasCatalog:Int?,
         products:[SearchProduct]?,
         departmentId:String?,
         st:String?,
         hashtags:[Hashtag]?,
         breadcrumb:[CategoryDetail]?,
         redirectUrl:String?,
         shareUrl:String?,
         catalogs:[SearchProduct]?) {
        self.searchUrl = searchUrl
        self.paging = paging
        self.st = st
        self.hasCatalog = hasCatalog ?? 0
        self.products = products
        self.departmentId = departmentId
        self.hashtags = hashtags
        self.breadcrumb = breadcrumb
        self.redirectUrl = redirectUrl
        self.shareUrl = shareUrl
        self.catalogs = catalogs
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            searchUrl: try? unboxer.unbox(keyPath: "search_url") as String,
            paging: try? unboxer.unbox(keyPath: "paging") as Paging,
            hasCatalog: try? unboxer.unbox(keyPath: "has_catalog") as Int,
            products: try? unboxer.unbox(keyPath: "products") as [SearchProduct],
            departmentId: try? unboxer.unbox(keyPath: "department_id") as String,
            st: try? unboxer.unbox(keyPath: "st") as String,
            hashtags: try? unboxer.unbox(keyPath: "hashtag") as [Hashtag],
            breadcrumb: try? unboxer.unbox(keyPath: "breadcrumb") as [CategoryDetail],
            redirectUrl: try? unboxer.unbox(keyPath:"redirect_url") as String,
            shareUrl: try? unboxer.unbox(keyPath:"share_url") as String,
            catalogs: try? unboxer.unbox(keyPath:"catalogs") as [SearchProduct]
        )
    }
}
