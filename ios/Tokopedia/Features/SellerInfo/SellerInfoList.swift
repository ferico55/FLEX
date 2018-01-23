//
//  SellerInfoList.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 04/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

enum SellerInfoItemSectionId: Int {
    case forAll
    case forYou
    case promo
    case insight
    case featureUpdate
    case event
    case other // in case we are sent a section we do not yet support
    
    func describe() -> String {
        var description = ""
        switch self {
            case .forAll:
                description = "Semua"
            case .forYou:
                description = "For You"
            case .promo:
                description = "Promo"
            case .insight:
                description = "Insight"
            case .featureUpdate:
                description = "Feature Update"
            case .event:
                description = "Event"
            case .other:
                description = "Other"
        }
        
        return description
    }
}

final class SellerInfoList: NSObject {
    private(set) var list : [SellerInfoItem]
    private(set) var hasNext: Bool
    
    init(list: [SellerInfoItem], hasNext: Bool) {
        self.list = list
        self.hasNext = hasNext
        super.init()
    }
    
    // return array of sorted dates, and group seller info items
    func groupedSellerInfoItems() -> ([String], [String : [SellerInfoItem]]) {
        var grouped: [String : [SellerInfoItem]] = [String : [SellerInfoItem]]()
        
        // group items by date (not time)
        for item in self.list {
            let dateKey = item.createDate.string("YYYY-MM-dd")
            
            if grouped[dateKey] == nil {
                grouped[dateKey] = [item]
            } else {
                grouped[dateKey]!.append(item)
            }
        }
        
        // grab all unique dates from grouped list
        let unsortedDates: [String] = Array(grouped.keys)
        // sort unique dates
        let sortedDates  : [String] = unsortedDates.sorted(by: { $0 > $1 })
        return (sortedDates, grouped)
    }
}

extension SellerInfoList: Unboxable {
    convenience init(unboxer: Unboxer) throws {
        let list    = try unboxer.unbox(keyPath: "data.list") as [SellerInfoItem]
        let hasNext = try unboxer.unbox(keyPath: "data.paging.has_next") as Bool
        
        self.init(list: list, hasNext: hasNext)
    }
}

final class SellerInfoItem: NSObject {
    var infoId          : Int
    var status          : Int
    var type            : Int
    var title           : String
    var content         : String
    var shortDescription: String
    var externalLink    : String
    var infoThumbnailUrl: String
    var isRead          : Bool
    var createTimeUnix  : Int
    var expireTimeUnix  : Int
    var section         : SellerInfoItemSection
    var createDate      : Date // derived from createTimeUnix
    
    init(infoId: Int, status: Int, type: Int, title: String, content: String, shortDescription: String, externalLink: String, infoThumbnailUrl: String, isRead: Bool, createTimeUnix: Int, expireTimeUnix: Int, section: SellerInfoItemSection) {
        self.infoId           = infoId
        self.status           = status
        self.type             = type
        self.title            = title
        self.content          = content
        self.shortDescription = shortDescription
        self.externalLink     = externalLink
        self.infoThumbnailUrl = infoThumbnailUrl
        self.isRead           = isRead
        self.createTimeUnix   = createTimeUnix
        self.expireTimeUnix   = expireTimeUnix
        self.section          = section
        self.createDate       = Date(timeIntervalSince1970: Double(self.createTimeUnix))
        
        super.init()
    }
}

extension SellerInfoItem: Unboxable {
    convenience init(unboxer: Unboxer) throws {
        let infoId           = try unboxer.unbox(key: "info_id") as Int
        let status           = try unboxer.unbox(key: "status") as Int
        let type             = try unboxer.unbox(key: "type") as Int
        let title            = try unboxer.unbox(key: "title") as String
        let content          = try unboxer.unbox(key: "content") as String
        let shortDescription = try unboxer.unbox(key: "short_description") as String
        let externalLink     = try unboxer.unbox(key: "external_link") as String
        let infoThumbnailUrl = try unboxer.unbox(key: "info_thumbnail_url") as String
        let isRead           = try unboxer.unbox(key: "is_read") as Bool
        let createTimeUnix   = try unboxer.unbox(key: "create_time_unix") as Int
        let expireTimeUnix   = try unboxer.unbox(key: "expire_time_unix") as Int
        let section          = try unboxer.unbox(keyPath: "section") as SellerInfoItemSection
        
        self.init(infoId: infoId, status: status, type: type, title: title, content: content, shortDescription: shortDescription, externalLink: externalLink, infoThumbnailUrl: infoThumbnailUrl, isRead: isRead, createTimeUnix: createTimeUnix, expireTimeUnix: expireTimeUnix, section: section)
    }
}

final class SellerInfoItemSection: NSObject {
    var id     : SellerInfoItemSectionId
    var name   : String
    var iconUrl: String
    
    init(id: SellerInfoItemSectionId, name: String, iconUrl: String) {
        self.id      = id
        self.name    = name
        self.iconUrl = iconUrl
        
        super.init()
    }
}

extension SellerInfoItemSection: Unboxable {
    convenience init(unboxer: Unboxer) throws {
        let rawId   = try unboxer.unbox(key: "section_id") as Int
        var id : SellerInfoItemSectionId = .other
        if let trueId = SellerInfoItemSectionId(rawValue: rawId) {
            id = trueId
        }
        let name    = try unboxer.unbox(keyPath: "name") as String
        let iconUrl = try unboxer.unbox(keyPath: "icon_url") as String
        
        self.init(id: id, name: name, iconUrl: iconUrl)
    }
}
