//
//  UIColorCategory.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 7/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

extension UIColor {
    class func fromHexString(hexString: String) -> UIColor {
        var rgbValue: UInt32 = 0
        let noHashHexString = hexString.stringByReplacingOccurrencesOfString("#", withString: "")
        let scanner = NSScanner(string: noHashHexString)
        scanner.scanHexInt(&rgbValue)
        
        let red = ((rgbValue & 0xFF0000) >> 16)
        let green = ((rgbValue & 0xFF00) >> 8)
        let blue = (rgbValue & 0xFF)
        
        return UIColor(red: CGFloat(red)/255,
                       green: CGFloat(green)/255,
                       blue: CGFloat(blue)/255,
                       alpha: 1)
    }
}
