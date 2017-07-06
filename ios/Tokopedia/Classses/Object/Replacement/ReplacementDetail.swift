//
//  ReplacementDetail.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ReplacementDetail: Unboxable {
    
    var totalPriceIdr : String
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            totalPriceIdr: try unboxer.unbox(key:"detail_open_amount_idr")
        )
    }
    
    init(totalPriceIdr: String){
        self.totalPriceIdr = totalPriceIdr
    }
}
