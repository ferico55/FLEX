//
//  Date.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 07/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

extension Date {
    public static func aWeekAgo() -> Date {
        let calendar = Calendar.current
        let aWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date())
        return aWeekAgo ?? Date()
    }
    
    public static func aMonthAgo() -> Date {
        let calendar = Calendar.current
        let aWeekAgo = calendar.date(byAdding: .day, value: -30, to: Date())
        return aWeekAgo ?? Date()
    }
    
    public static func firstDayOfThisMonth() -> Date {
        let calendar = Calendar.current
        let firstDayOfThisMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))
        return firstDayOfThisMonth ?? Date()
    }
    
    public static func lastDayOfThisMonth() -> Date {
        let calendar = Calendar.current
        let lastDayOfThisMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.firstDayOfThisMonth())
        return lastDayOfThisMonth ?? Date()
    }
    
    public static func firstDayOfLastMonth() -> Date {
        let calendar = Calendar.current
        let firstDayOfLastMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()))
        return firstDayOfLastMonth ?? Date()
    }
    
    public static func lastDayOfLastMonth() -> Date {
        let calendar = Calendar.current
        let lastDayOfThisMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: self.firstDayOfLastMonth())
        return lastDayOfThisMonth ?? Date()
    }
    
    public func tpDateFormat1() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd+MM+yyyy"
        let string = formatter.string(from: self)
        return string
    }
    
    public func tpDateFormat2() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id")
        formatter.dateFormat = "dd MMM yyyy"
        let string = formatter.string(from: self)
        return string
    }
}
