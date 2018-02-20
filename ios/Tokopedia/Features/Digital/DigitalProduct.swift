//
//  DigitalProduct.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Render
import Unbox

public enum DigitalProductStatus: Int {
    case available = 1
    case inactive = 2
    case outOfStock = 3
}

final public class DigitalProduct: Unboxable, StateType {
    public let id: String
    public let name: String
    public let priceText: String
    public let promoPriceText: String
    public let detail: String
    public let promoTag: String
    public let status: DigitalProductStatus
    public let url:String
    public let urlText:String
    
    public var hasDiscount: Bool {
        return self.priceText != self.promoPriceText
    }
    
    public init(id: String,
                name: String,
                priceText: String,
                detail: String,
                promoPriceText: String? = nil,
                promoTag: String = "",
                status: DigitalProductStatus = .available,
                url:String = "",
                urlText:String = "") {
        self.id = id
        self.name = name
        self.priceText = priceText
        self.detail = detail
        self.promoPriceText = promoPriceText ?? priceText
        self.promoTag = promoTag
        self.status = status
        self.url = url
        self.urlText = urlText
    }
    
    convenience public init(unboxer: Unboxer) throws {
        let id = try unboxer.unbox(keyPath: "id") as String
        let name = try unboxer.unbox(keyPath: "attributes.desc") as String
        let priceText = try unboxer.unbox(keyPath: "attributes.price") as String
        let detail = try unboxer.unbox(keyPath: "attributes.detail") as String
        let promoPriceText = (try? unboxer.unbox(keyPath: "attributes.promo.new_price") as String) ?? priceText
        let promoTag = (try? unboxer.unbox(keyPath: "attributes.promo.tag") as String) ?? ""
        
        let statusInt = try unboxer.unbox(keyPath: "attributes.status") as Int
        let status = DigitalProductStatus(rawValue: statusInt) ?? .available
        let url = try unboxer.unbox(keyPath: "attributes.detail_url") as String
        let urlText = try unboxer.unbox(keyPath: "attributes.detail_url_text") as String
        
        self.init(
            id: id,
            name: name,
            priceText: priceText,
            detail: detail,
            promoPriceText: promoPriceText,
            promoTag: promoTag,
            status: status,
            url:url,
            urlText:urlText)
    }
}
