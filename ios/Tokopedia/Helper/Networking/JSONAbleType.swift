//
//  JSONAbleType.swift
//  Tokopedia
//
//  Created by Ronald Budianto on 6/2/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
protocol JSONAbleType {
    static func fromJSON(_: [String: Any]) -> Self
}
