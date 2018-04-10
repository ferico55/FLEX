//
//  DictionaryHelper.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 30/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

extension Dictionary where Value == Any? {
    func avoidImplicitNil() -> [Key: Value] {
        var newDictionary: [Key: Value] = [:]
        for (key, value) in self {
            if (value != nil) {
                newDictionary[key] = value
            } else {
                newDictionary[key] = NSNull()
            }
        }
        return newDictionary
    }
}
