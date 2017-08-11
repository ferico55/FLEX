//
//  ReplacementData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ReplacementData : Unboxable {
    
    var replacements: [Replacement]!
    var page : Paging!
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            replacements: try unboxer.unbox(key:"list"),
            page: try unboxer.unbox(key:"paging")
        )
    }
    
    init(replacements: [Replacement], page: Paging) {
        self.replacements = replacements
        self.page = page
    }

}
