//
//  Referable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
protocol Referable {
    var desktopUrl: String{get}
    var deeplinkPath: String{get}
    var feature: String{get}
    var title: String{get}
    var buoDescription: String{get}
    var utm_campaign: String{get}
}
