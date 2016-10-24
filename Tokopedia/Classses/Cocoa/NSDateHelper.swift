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

        //Need to add local and timezone for iOS above 8.1
        let Locale:NSLocale=NSLocale(localeIdentifier: "id_ID")
        dtf.locale=Locale
        dtf.timeZone = NSTimeZone(name: "GMT")
        
        dtf.dateFormat = format1
        let date: NSDate = dtf.dateFromString(string)!
        let dateFormat: NSDateFormatter = NSDateFormatter()
        dateFormat.dateFormat = format2
        let result = dateFormat.stringFromDate(date)
        return result
    }
    
    class func getStringDate(date: NSDate, withFormat dateFormat: String) -> String{
        let formatter = NSDateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.stringFromDate(date)
    }
}
