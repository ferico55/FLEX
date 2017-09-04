
//
//  OneClickResult.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

class OneClickResponse: Unboxable {

    var list: [OneClickData]?

    init(list: [OneClickData]?) {
        self.list = list
    }

    required convenience init(unboxer: Unboxer) throws {
        self.init(
            list: try? unboxer.unbox(keyPath: "data.bca_oneklik_data")
        )
    }
}
