//
//  FuzzySearchDataSuggestionText.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(FuzzySearchDataSuggestionText)
final class FuzzySearchDataSuggestionText : NSObject, Unboxable {
    var text:String?
    var query:String?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        text = try? unboxer.unbox(keyPath: "text")
        query = try? unboxer.unbox(keyPath: "query")
    }
}
