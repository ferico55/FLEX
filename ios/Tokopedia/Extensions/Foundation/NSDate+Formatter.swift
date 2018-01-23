//
//  NSDate+Formatter.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 19/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

extension NSDate {
    static func getNow(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: NSDate() as Date)
    }
}
