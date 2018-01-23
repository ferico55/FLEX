//
//  TokoCashHelpCategory.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 13/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

final class TokoCashHelpCategory: NSObject {
    var categoryId: String
    var translation: String
    
    init(categoryId: String, translation: String) {
        self.categoryId = categoryId
        self.translation = translation
    }
}

