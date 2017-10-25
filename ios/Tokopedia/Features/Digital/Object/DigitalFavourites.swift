//
//  DigitalFavourites.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 10/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class DigitalFavourites : NSObject {
    let index:Int
    let list:[DigitalFavourite]?
    
    init(index:Int = 0, list:[DigitalFavourite]? = nil) {
        self.index = index
        self.list = list
    }
}

extension DigitalFavourites : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> DigitalFavourites {
        let json = JSON(source)
        
        let index = json["meta"]["default_index"].intValue
        var list:[DigitalFavourite]? = nil
        if let data = json["data"].array {
            list = data.flatMap {
                if let dictionary = $0.dictionaryObject {
                    return DigitalFavourite.fromJSON(dictionary)
                } else {
                    return nil
                }
            }
        }
        return DigitalFavourites(index: index, list: list)
    }
}
