//
//  ReplacementDeadline.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 4/4/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class ReplacementDeadline: Unboxable {
    
    var processDayLeft: String!
    var processHourLeft: String!
    var processText: String!
    var poDayLeft: String!
    var shippingDayLeft: String!
    var shippingHourLeft: String!
    var shippingText: String!
    var finishDayLeft: String!
    var finishHourLeft: String!
    var backgroundColorHex: String!
    
    required convenience init(unboxer: Unboxer) throws {
        self.init(
            processDayLeft: try unboxer.unbox(key:"deadline_process_day_left"),
            processHourLeft: try unboxer.unbox(key:"deadline_process_hour_left"),
            processText: try unboxer.unbox(key:"deadline_process"),
            poDayLeft: try unboxer.unbox(key:"deadline_po_process_day_left"),
            shippingDayLeft: try unboxer.unbox(key:"deadline_shipping_day_left"),
            shippingHourLeft: try unboxer.unbox(key:"deadline_shipping_hour_left"),
            shippingText: try unboxer.unbox(key:"deadline_shipping"),
            finishDayLeft: try unboxer.unbox(key:"deadline_finish_day_left"),
            finishHourLeft: try unboxer.unbox(key:"deadline_finish_hour_left"),
            backgroundColorHex: try unboxer.unbox(key:"deadline_color")
        )
    }
    
    init(processDayLeft: String!, processHourLeft: String!, processText: String!, poDayLeft: String!, shippingDayLeft: String!, shippingHourLeft: String!, shippingText : String!, finishDayLeft: String!, finishHourLeft: String!, backgroundColorHex: String!) {
        self.processDayLeft = processDayLeft
        self.processHourLeft = processHourLeft
        self.processText = processText
        self.poDayLeft = poDayLeft
        self.shippingDayLeft = shippingDayLeft
        self.shippingHourLeft = shippingHourLeft
        self.shippingText = shippingText
        self.finishDayLeft = finishDayLeft
        self.finishHourLeft = finishHourLeft
        self.backgroundColorHex = backgroundColorHex
    }
}
