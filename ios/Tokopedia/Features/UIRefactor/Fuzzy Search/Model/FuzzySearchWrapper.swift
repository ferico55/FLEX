//
//  FuzzySearchWrapper.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 06/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(FuzzySearchWrapper)
final class FuzzySearchWrapper: NSObject, Unboxable {
    var header: EnvelopeHeader?
    var data: FuzzySearchData = FuzzySearchData()

    convenience required init(unboxer:Unboxer) throws {
        self.init()
        self.header = try? unboxer.unbox(keyPath: "header")
        self.data = try unboxer.unbox(keyPath: "data")
    }
}
