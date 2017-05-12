//
//  DigitalCartInfo.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import Unbox

final class DigitalCartInfo:Unboxable {
    var title = ""
    var detail = [DigitalCartInfoDetail]()
    
    init(title:String, detail:[DigitalCartInfoDetail]) {
        self.title = title
        self.detail = detail
    }
    
    convenience init(unboxer: Unboxer) throws {
        let title = try unboxer.unbox(keyPath: "title" ) as String
        let detail = try unboxer.unbox(keyPath: "detail") as [DigitalCartInfoDetail]
        
        self.init(title:title, detail:detail)
    }
}
