//
//  FuzzySearchDataSuggestion.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(FuzzySearchDataSuggestion)
final class FuzzySearchDataSuggestion : NSObject, Unboxable {
    var suggestion:String?
    var totalData:Int?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        suggestion = try? unboxer.unbox(keyPath: "suggestion")
        totalData = try? unboxer.unbox(keyPath: "total_data")
    }
}
