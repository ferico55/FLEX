//
//  TokoCashHelpCategory.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 13/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

public final class TokoCashHelpCategory: NSObject {
    public var categoryId: String
    public var translation: String
    
    public init(categoryId: String, translation: String) {
        self.categoryId = categoryId
        self.translation = translation
    }
}

