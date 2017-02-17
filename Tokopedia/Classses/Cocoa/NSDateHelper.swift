//
//  NSDateHelper.swift
//  
//
//  Created by Billion Goenawan on 9/6/16.
//
//

import Foundation

extension NSDate {
    static func convertDateString(_ string: String, fromFormat format1: String, toFormat format2: String ) -> String{
        let dtf: DateFormatter = DateFormatter()

        //Need to add local and timezone for iOS above 8.1
        let Locale:Foundation.Locale=Foundation.Locale(identifier: "id_ID")
        dtf.locale=Locale
        dtf.timeZone = TimeZone(identifier: "GMT")
        
        dtf.dateFormat = format1
        let date: Date = dtf.date(from: string)!
        let dateFormat: DateFormatter = DateFormatter()
        dateFormat.dateFormat = format2
        let result = dateFormat.string(from: date)
        return result
    }
    
    func timeStamp() -> String {
        let myDateString = String(Int64(self.timeIntervalSince1970*1000))
        return "\(myDateString)"
    }
    
    func stringWithFormat(_ dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from: self as Date)
    }
}
