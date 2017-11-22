//
//  FuzzySearchData.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 06/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(FuzzySearchData)
final class FuzzySearchData : NSObject, Unboxable {
    
    var redirection:SearchRedirection?
    var suggestionText:FuzzySearchDataSuggestionText?
    var suggestion:FuzzySearchDataSuggestion?
    var suggestionInstead:FuzzySearchDataSuggestionInstead?
    var products:[FuzzySearchProduct]?
    var catalogs:[FuzzySearchCatalog]?
    var shareURL:String?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        redirection = try? unboxer.unbox(keyPath: "redirection")
        suggestionText = try? unboxer.unbox(keyPath: "suggestion_text")
        suggestion = try? unboxer.unbox(keyPath: "suggestions")
        suggestionInstead = try? unboxer.unbox(keyPath: "suggestions_instead")
        products = try? unboxer.unbox(keyPath: "products")
        catalogs = try? unboxer.unbox(keyPath: "catalogs")
        shareURL = try? unboxer.unbox(keyPath: "share_url")
    }
}
