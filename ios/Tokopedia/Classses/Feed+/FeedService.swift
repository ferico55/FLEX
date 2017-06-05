//
//  FeedService.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/21/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class FeedService: NSObject {
    
    class func feedCreateTimeFormatted(withCreatedTime createdTime: String) -> String {
        var formatted = ""
        
        let calendar = NSCalendar.current
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxxx"
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
        let createdDate = dateFormatter.date(from: createdTime)
        let currentDate = Date()
        
        let currentYear = calendar.component(.year, from: currentDate)
        let createdYear = calendar.component(.year, from: createdDate!)
        
        var secondsAgo = Int(currentDate.timeIntervalSince(createdDate!))
        let second = Int(currentDate.timeIntervalSince(createdDate!))
        
        let daysAgo = Int(floor(Double(secondsAgo / (3600 * 24))))
        if daysAgo != 0 {
            secondsAgo -= daysAgo * 3600 * 24
        }
        
        let hoursAgo = Int(floor(Double(secondsAgo / 3600)))
        if hoursAgo != 0 {
            secondsAgo -= hoursAgo * 3600
        }
        
        let minutesAgo = Int(floor(Double(secondsAgo / 60)))
        if minutesAgo != 0 {
            secondsAgo -= minutesAgo * 60
        }
        
        if second >= 1 && second < 60 {
            formatted = "Saat ini"
        } else if daysAgo == 0 && hoursAgo == 0 && minutesAgo >= 1 && minutesAgo < 60 {
            formatted = "\(minutesAgo) menit lalu"
        } else if daysAgo == 0 && hoursAgo >= 1 && hoursAgo < 24 {
            formatted = "\(hoursAgo) jam lalu"
        } else if calendar.isDateInYesterday(createdDate!) && hoursAgo < 24 {
            let newFormat = DateFormatter()
            newFormat.dateFormat = "'Kemarin pukul' HH:mm"
            formatted = newFormat.string(from: createdDate!)
        } else if (currentYear == createdYear) && daysAgo >= 1 {
            let newFormat = DateFormatter()
            newFormat.dateFormat = "dd MMMM 'pukul' HH:mm"
            newFormat.locale = NSLocale(localeIdentifier: "id_ID") as Locale!
            formatted = newFormat.string(from: createdDate!)
        } else {
            let newFormat = DateFormatter()
            newFormat.dateFormat = "dd MMMM yyyy"
            newFormat.locale = NSLocale(localeIdentifier: "id_ID") as Locale!
            formatted = newFormat.string(from: createdDate!)
        }
        
        return formatted
    }
    
}
