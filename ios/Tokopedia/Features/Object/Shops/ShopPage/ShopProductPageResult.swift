//
//  ShopProductPageResultSwift.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

@objc(ShopProductPageResult)
final class ShopProductPageResult: NSObject, Unboxable {
    let paging: Paging?
    let list: [ShopProductPageList]

    init(paging: Paging?, list: [ShopProductPageList]) {
        self.paging = paging
        self.list = list
    }

    convenience init(unboxer: Unboxer) throws {
        self.init(
            paging: try? unboxer.unbox(keyPath: "data.paging") as Paging,
            list: try unboxer.unbox(keyPath: "data.list")
        )
    }
}
