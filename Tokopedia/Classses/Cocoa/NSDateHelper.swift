//
//  NSDateHelper.swift
//  
//
//  Created by Billion Goenawan on 9/6/16.
//
//

import Foundation

extension NSDate {
    class func convertDateString(string: String, fromFormat format1: String, toFormat format2: String ) -> String{
        let dtf: NSDateFormatter = NSDateFormatter()
        dtf.dateFormat = format1
        let date: NSDate = dtf.dateFromString(string)!
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = format2
        let result = dateFormat.stringFromDate(date)
        return result
    }
}
