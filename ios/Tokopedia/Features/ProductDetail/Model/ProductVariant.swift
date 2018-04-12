//
//  ProductVariant.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 02/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON

internal struct ProductVariant {
    internal let parentID: String
    internal var possibilityChildrens: [ProductPossibilityChildren]
    internal let sizeChart: String?
    internal let variants: [ProductChildrenVariant]
    internal let defaultChildID: String
    internal var productVariantSelected: [ProductVariantSelected]?

    internal init(parentID: String, sizeChart: String?, possibilityChildrens: [ProductPossibilityChildren], variants: [ProductChildrenVariant], defaultChildID: String) {
        self.parentID = parentID
        self.sizeChart = sizeChart
        self.possibilityChildrens = possibilityChildrens
        self.variants = variants
        self.defaultChildID = defaultChildID
    }

    internal init(json: JSON) {
        let parentID = json["parent_id"].stringValue
        let sizeChart = json["sizechart"].string
        let defaultChildID = json["default_child"].stringValue
        let variants = json["variant"].arrayValue.map { ProductChildrenVariant(json: $0) }
        let possibilityChildrens = json["children"].arrayValue.map { ProductPossibilityChildren(json: $0) }

        self.init(parentID: parentID, sizeChart: sizeChart, possibilityChildrens: possibilityChildrens, variants: variants, defaultChildID: defaultChildID)
    }

    internal var dictionary: [String : Any?] {

        var productVariant: [[String : Any]]?
        if let variantSelected = self.productVariantSelected {
            productVariant = variantSelected.map { $0.dictionary }
        }

        return [
            "parentID": self.parentID,
            "possibilityChildrens": self.possibilityChildrens.map { $0.dictionary },
            "sizeChart": self.sizeChart ?? "",
            "variants": self.variants.map { $0.dictionary },
            "defaultChildID": self.defaultChildID,
            "productVariantSelected": productVariant
        ]
    }
}

internal struct ProductPossibilityChildren {
    internal let productID: String
    internal let price: String
    internal let stock: Int
    internal let stockString: String
    internal let stockLimit: String
    internal let sku: String?
    internal let optionIDS: [String]
    internal let isEnabled: Bool
    internal let name: String
    internal let isBuyable: Bool
    internal var isWishlist: Bool
    internal let originalPicture: String
    internal let thumbnailPicture: String
    internal let priceFormat: String
    internal let url: String
    internal let campaign: ShopProductCampaign

    internal init(productID: String, price: String, stock: Int, sku: String?, optionIDS: [String], isEnabled: Bool, name: String, isBuyable: Bool, isWishlist: Bool, originalPicture: String, thumbnailPicture: String, priceFormat: String, url: String, campaign: ShopProductCampaign, stockString: String, stockLimit: String) {
        self.productID = productID
        self.price = price
        self.stock = stock
        self.stockString = stockString
        self.stockLimit = stockLimit
        self.sku = sku
        self.optionIDS = optionIDS
        self.isEnabled = isEnabled
        self.name = name
        self.isBuyable = isBuyable
        self.isWishlist = isWishlist
        self.originalPicture = originalPicture
        self.thumbnailPicture = thumbnailPicture
        self.priceFormat = priceFormat
        self.url = url
        self.campaign = campaign
    }

    internal init(json: JSON) {
        let productID = json["product_id"].stringValue
        let price = json["price"].stringValue
        let stock = json["stock"].intValue
        let stockString = json["stock_wording"].stringValue
        let stockLimit = json["is_limited_stock"].stringValue
        let sku = json["sku"].string
        let optionIDS = json["option_ids"].arrayValue.map { $0.stringValue }
        let isEnabled = json["enabled"].boolValue
        let name = json["name"].stringValue
        let isBuyable = json["is_buyable"].boolValue
        let isWishlist = json["is_wishlist"].boolValue
        let originalPicture = json["picture"]["original"].stringValue
        let thumbnailPicture = json["picture"]["thumbnail"].stringValue
        let priceFormat = json["price_fmt"].stringValue
        let url = json["url"].stringValue
        let campaign = ShopProductCampaign(json: json["campaign"])

        self.init(productID: productID, price: price, stock: stock, sku: sku, optionIDS: optionIDS, isEnabled: isEnabled, name: name, isBuyable: isBuyable, isWishlist: isWishlist, originalPicture: originalPicture, thumbnailPicture: thumbnailPicture, priceFormat: priceFormat, url: url, campaign: campaign, stockString: stockString, stockLimit: stockLimit)
    }

    internal var dictionary: [String : Any] {
        return [
            "productID": self.productID,
            "price": self.price,
            "stock": self.stock,
            "stockString" : self.stockString,
            "stockLimit" : self.stockLimit,
            "sku": self.sku ?? "",
            "optionIDS": self.optionIDS,
            "isEnabled": self.isEnabled,
            "name": self.name,
            "isBuyable": self.isBuyable,
            "isWishlist": self.isWishlist,
            "originalPicture": self.originalPicture,
            "thumbnailPicture": self.thumbnailPicture,
            "priceFormat": self.priceFormat,
            "url": self.url,
            "campaign": self.campaign.dictionary
        ]
    }
}

internal struct ProductChildrenVariant {
    internal let unitName: String?
    internal let optionsVariant: [ProductOptionVariant]
    internal let name: String
    internal let identifier: String
    internal let position: Int

    internal init(unitName: String?, optionsVariant: [ProductOptionVariant], name: String, identifier: String, position: Int) {
        self.unitName = unitName
        self.optionsVariant = optionsVariant
        self.name = name
        self.identifier = identifier
        self.position = position
    }

    internal init(json: JSON) {
        let unitName = json["unit_name"].string
        let name = json["name"].stringValue.lowercased().capitalized
        let identifier = json["identifier"].stringValue
        let position = json["position"].intValue
        let optionsVariant = json["option"].arrayValue.map { ProductOptionVariant(json: $0) }

        self.init(unitName: unitName, optionsVariant: optionsVariant, name: name, identifier: identifier, position: position)
    }

    internal var dictionary: [String : Any] {
        return [
            "unitName": self.unitName ?? "",
            "name": self.name,
            "identifier": self.identifier,
            "position": self.position,
            "optionsVariant": self.optionsVariant.map { $0.dictionary }
        ]
    }
}

internal struct ProductOptionVariant {
    internal let id: String
    internal let value: String
    internal let originalPicture: String
    internal let thumbnailPicture: String
    internal let hexColor: String
    internal let vuv: String

    internal init(id: String, value: String, originalPicture: String, thumbnailPicture: String, hexColor: String, vuv: String) {
        self.id = id
        self.value = value
        self.originalPicture = originalPicture
        self.thumbnailPicture = thumbnailPicture
        self.hexColor = hexColor
        self.vuv = vuv
    }

    internal init(json: JSON) {
        let id = json["id"].stringValue
        let value = json["value"].stringValue
        let originalPicture = json["picture"]["original"].stringValue
        let thumbnailPicture = json["picture"]["thumbnail"].stringValue
        let hexColor = json["hex"].stringValue
        let vuv = json["vuv"].stringValue

        self.init(id: id, value: value, originalPicture: originalPicture, thumbnailPicture: thumbnailPicture, hexColor: hexColor, vuv: vuv)
    }

    internal var dictionary: [String : Any] {
        return [
            "id": self.id,
            "value": self.value,
            "originalPicture": self.originalPicture,
            "thumbnailPicture": self.thumbnailPicture,
            "hexColor": self.hexColor,
            "vuv": self.vuv
        ]
    }
}

internal struct ProductVariantSelected {
    internal let variantIdentifier: String
    internal let variantID: String
    internal let variantValue: String

    internal init(variantIdentifier: String, variantID: String, variantValue: String) {
        self.variantIdentifier = variantIdentifier
        self.variantID = variantID
        self.variantValue = variantValue
    }

    internal init(json: JSON) {
        let variantIdentifier = json["identifier"].stringValue
        let variantID = json["id"].stringValue
        let variantValue = json["name"].stringValue

        self.init(variantIdentifier: variantIdentifier, variantID: variantID, variantValue: variantValue)
    }

    internal var dictionary: [String : Any] {
        return [
            "variantIdentifier": self.variantIdentifier,
            "variantID": self.variantID,
            "variantValue": self.variantValue
        ]
    }
}
