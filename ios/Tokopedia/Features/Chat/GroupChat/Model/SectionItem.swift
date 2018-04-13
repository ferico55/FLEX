//
//  SectionItem.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 24/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum MsgCustomType: String {
    case announcement
    case pollingStart = "polling_start"
    case pollingFinish = "polling_finish"
    case pollingCancel = "polling_cancel"
    case pollingUpdate = "polling_update"
    case join
    case chat
    case normal
    case generatedMsg = "generated_msg"
    case flashsaleEnd = "flashsale_end"
    case flashsaleStart = "flashsale_start"
    case flashsaleUpcoming = "flashsale_upcoming"
    case vibrateMsg = "is_vibrate"
    case gratificationMsg = "gratification_msg"
}

public class GroupChatDataSources: NSObject {
    public let list: [SectionItem]
    
    public init(list: [SectionItem]) {
        self.list = list
    }
    
    public convenience init(json: JSON) {
        var listArr = [SectionItem]()
        for value in json.arrayValue {
            let sectionList = SectionItem(json: value)
            listArr.append(sectionList)
        }
        
        self.init(list: listArr)
    }
}

public class SectionItem: NSObject {
    public let title: String
    public var data: [ChatItem]
    
    public init(title: String, data: [ChatItem]) {
        self.title = title
        self.data = data
    }
    
    public convenience init(json: JSON) {
        var chatArr = [ChatItem]()
        let title = json["title"].stringValue
        for value in json["data"].arrayValue {
            let list = ChatItem(json: value)
            chatArr.append(list)
        }
        self.init(title: title, data: chatArr)
    }
}

public class ChatItem: NSObject {
    public let channelType: String
    public let channelUrl: String
    public let createdAt: String
    public let customType: MsgCustomType
    public let data: [String: Any]?
    public let message: NSAttributedString
    public let messageId: Int
    public let sender: SenderObject
    
    public init(channelType: String, channelUrl: String, createdAt: String, customType: MsgCustomType, data: [String: Any]?, message: NSAttributedString, messageId: Int, sender: SenderObject) {
        self.channelType = channelType
        self.channelUrl = channelUrl
        self.createdAt = createdAt
        self.customType = customType
        self.data = data
        self.message = message
        self.messageId = messageId
        self.sender = sender
    }
    
    public convenience init(json: JSON) {
        var profileUrl: URL?
        var data: [String: Any]?
        let channelType = json["channelType"].stringValue
        let channelUrl = json["channelUrl"].stringValue
        let createdAt = json["createdAt"].stringValue
        
        let customType = json["customType"].stringValue
        var msgCustomType = MsgCustomType.normal
        if customType != "", let enumType = MsgCustomType(rawValue: customType) {
            msgCustomType = enumType
        }
        
        let stringData = json["data"].stringValue
        if let json = JSON(parseJSON: stringData).dictionaryObject {
            data = json
            if let msg = data?["message"] as? String, msgCustomType == .generatedMsg {
                data?["message"] = NSAttributedString(fromHTML: "<div>\(msg)</div>", normalFont: .largeTheme(), boldFont: .largeThemeSemibold(), italicFont: .largeThemeSemibold())
            } else if let question = data?["question"] as? String, msgCustomType == .pollingStart || msgCustomType == .pollingFinish {
                data?["question"] = NSAttributedString(fromHTML: "<div>\(question)</div>", normalFont: .largeThemeSemibold(), boldFont: .largeThemeSemibold(), italicFont: .largeThemeSemibold())
            }
        }
        
        let text = json["message"].stringValue
        let message = NSAttributedString(fromHTML: "<div>\(text)</div>", normalFont: .largeTheme(), boldFont: .largeThemeSemibold(), italicFont: .largeThemeSemibold())
        
        let messageId = json["messageId"].intValue
        let nickname = json["sender"]["nickname"].stringValue
        if let url = json["sender"]["profileUrl"].string, url != "" {
            profileUrl = URL(string: url)
        }
        let sender = SenderObject(nickname: nickname, profileUrl: profileUrl)
        
        self.init(channelType: channelType, channelUrl: channelUrl, createdAt: createdAt, customType: msgCustomType, data: data, message: message, messageId: messageId, sender: sender)
    }
}

public class SenderObject: NSObject {
    public let nickname: String
    public let profileUrl: URL?
    
    public init(nickname: String, profileUrl: URL?) {
        self.nickname = nickname
        self.profileUrl = profileUrl
    }
}

internal class SprintSaleProductObject: NSObject {
    internal var list: [SprintSaleProductItem]
    
    internal init(list: [SprintSaleProductItem]) {
        self.list = list
    }
    
    internal convenience init(data: NSArray) {
        let json = JSON(data)
        var list = [SprintSaleProductItem]()
        for item in json.arrayValue {
            let imageUrl = URL(string: item["image_url"].stringValue)
            let urlMobile = item["url_mobile"].stringValue
            let name = item["name"].stringValue
            let campaignProductId = item["campaign_product_id"].intValue
            let discountPercentage = item["discount_percentage"].intValue
            let discountPrice = item["discounted_price"].stringValue
            let originalPrice = item["original_price"].stringValue
            let stockPercentage = Float(item["remaining_stock_percentage"].intValue)
            let stockText = item["stock_text"].stringValue
            
            let productItem = SprintSaleProductItem(campaignProductId: campaignProductId, name: name, urlMobile: urlMobile, imageUrl: imageUrl, discountPercentage: discountPercentage, discountPrice: discountPrice, originalPrice: originalPrice, stockPercentage: stockPercentage, stockText: stockText)
            list.append(productItem)
        }
        
        self.init(list: list)
    }
}

internal class SprintSaleProductItem: NSObject {
    internal let campaignProductId: Int
    internal let name: String
    internal let urlMobile: String // Applink
    internal let imageUrl: URL?
    internal let discountPercentage: Int
    internal let discountPrice: String
    internal let originalPrice: String
    internal let stockPercentage: Float
    internal let stockText: String
    
    internal init(campaignProductId: Int, name: String, urlMobile: String, imageUrl: URL?, discountPercentage: Int, discountPrice: String, originalPrice: String, stockPercentage: Float, stockText: String) {
        self.campaignProductId = campaignProductId
        self.name = name
        self.urlMobile = urlMobile
        self.imageUrl = imageUrl
        self.discountPercentage = discountPercentage
        self.discountPrice = discountPrice
        self.originalPrice = originalPrice
        self.stockPercentage = stockPercentage / 100.0
        self.stockText = stockText
    }
}
