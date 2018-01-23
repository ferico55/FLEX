//
//  SellerInfoInboxViewModel.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 12/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxSwift
import RxDataSources

import UIKit

struct SellerInfoInboxViewModel {
    // filter
    var filter : SellerInfoItemSectionId = .forAll // filter defaults to for all, ignore for all flag. In current implementation product wants for all to display all messages
    
    // data
    private(set) var groupedItems : Variable<[String: [SellerInfoItem]]> = Variable([:]) // main data source, contains list of items grouped by create data
    private(set) var itemDates    : Variable<[String]>                   = Variable([])  // array of unique dates of grouped items
    
    // pagination
    var nextPage   : Variable<Int>  = Variable(1)       // determines page index of items data grabbed from backend
    var hasNextPage: Variable<Bool> = Variable(false)   // determines if next page is available
    
    // request state
    var pullingData : Variable<Bool> = Variable(false) // determines if a network request is currently active
    
    // derived observables
    var OitemDatesAndNextPage: Observable<([String], Int)> {
        return Observable.combineLatest(self.itemDates.asObservable(), self.nextPage.asObservable())
    }
    
    var OshouldHideNoResults: Observable<Bool> {
        return self.OitemDatesAndNextPage.map {
            return !($0.count == 0 && $1 > 1)
        }
    }
    
    var Osections: Observable<[SellerInfoItemSectionModel]> {
        return self.groupedItems.asObservable().map { groupedItems in
            var sections = [SellerInfoItemSectionModel]()
            for (_, items) in groupedItems {
                sections.append(SellerInfoItemSectionModel(items: items))
            }
            return sections
        }
    }
    
    // MARK: Getter
    func item(indexPath: IndexPath) -> SellerInfoItem? {
        
        // make sure items exist
        guard let items = self.items(section: indexPath.section) else { return nil }
        
        // make sure item exist
        guard items.indices.contains(indexPath.row) else { return nil }
        return items[indexPath.row]
    }
    
    func items(section: Int) -> [SellerInfoItem]? {
        
        // make sure index exist
        guard self.itemDates.value.indices.contains(section) else { return nil }
        let dateKey = self.itemDates.value[section]
        
        // make sure items exist
        guard let items = self.groupedItems.value[dateKey] else { return nil }
        
        return items
    }
    
    // MARK: Data Prep
    func formatForHeader(_ date: Date) -> String {
        var title = ""
        if date.isToday() {
            title = "Hari ini"
        } else if date.isYesterday() {
            title = "Kemarin"
        } else {
            title = date.year == Date().year ? date.string("d MMMM") : date.string("d MMMM YYYY")
        }
        return title
    }
    
    func formatForCell(_ date: Date) -> String {
        var text    = ""
        let now     = Date()
        let days    = date.daysTo(now)
        let hours   = date.hoursTo(now)
        let minutes = date.minutesTo(now)
        if days > 0 {
            // display date
            text = date.string("• HH.mm")
        } else if hours > 1 {
            // display hours
            text = String(format: "• %i jam yang lalu", hours)
        } else {
            // display minutes
            text = String(format: "• %i menit yang lalu", minutes)
        }
        
        return text
    }
    
    // MARK: Mutations
    mutating func reset() {
        self.nextPage.value     = 1
        self.hasNextPage.value  = false
        self.groupedItems.value = [:]
        self.itemDates.value    = []
    }
    
    mutating func add(_ groupedItems: [String: [SellerInfoItem]]) {
        for (dateKey, items) in groupedItems {
            if let items = self.groupedItems.value[dateKey] {
                for item in items {
                    self.groupedItems.value[dateKey]!.append(item)
                }
            } else {
                self.groupedItems.value[dateKey] = items
            }
        }
    }
    
    mutating func add(_ dates: [String]) {
        for date in dates {
            if !self.itemDates.value.contains(date) {
                self.itemDates.value.append(date)
            }
        }
    }
}

struct SellerInfoItemSectionModel {
    var items: [Item]
}
extension SellerInfoItemSectionModel: SectionModelType {
    typealias Item = SellerInfoItem
    
    init(original: SellerInfoItemSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
