//
//  FuzzySearchDataSuggestionInstead.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(FuzzySearchDataSuggestionInstead)
final class FuzzySearchDataSuggestionInstead : NSObject, Unboxable {
    let suggestionInstead:String?
    let currentKeyword:String?
    let totalData:Int?
    
    init(suggestionInstead: String?, currentKeyword: String?, totalData: Int?) {
        self.suggestionInstead = suggestionInstead
        self.currentKeyword = currentKeyword
        self.totalData = totalData ?? 0
    }
    
    convenience init(unboxer:Unboxer) throws {
        self.init(
            suggestionInstead: try? unboxer.unbox(keyPath: "suggestion_instead") as String,
            currentKeyword: try? unboxer.unbox(keyPath: "current_keyword") as String,
            totalData: try? unboxer.unbox(keyPath: "total_data") as Int
        )
    }
}
