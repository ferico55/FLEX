//
//  DigitalOperator.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/19/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

internal enum DigitalOperatorSelectionStyle {
    case prefixChecking(DigitalTextInput)
    case choice
    case implicit
}

final class DigitalOperator: Unboxable {
    internal let operatorID: String
    internal let name: String
    internal let prefixes: [String]
    internal let imageUrl: String
    internal let products: [DigitalProduct]
    internal let textInputs: [DigitalTextInput]
    internal let defaultProductId: String
    internal let productSelectionTitle: String
    internal let shouldShowProductSelection: Bool
    internal let buttonText: String
    
    init(
        operatorID: String,
        name: String,
        prefixes: [String],
        imageUrl: String,
        products: [DigitalProduct] = [],
        textInputs: [DigitalTextInput] = [],
        defaultProductId: String = "",
        productSelectionTitle: String = "",
        shouldShowProductSelection: Bool = true,
        buttonText: String = "") {
        
        self.operatorID = operatorID
        self.name = name
        self.prefixes = prefixes
        self.imageUrl = imageUrl
        self.products = products
        self.textInputs = textInputs
        self.defaultProductId = defaultProductId
        self.productSelectionTitle = productSelectionTitle
        self.shouldShowProductSelection = shouldShowProductSelection
        self.buttonText = buttonText
    }
    
    func hasPrefix(for text: String) -> Bool {
        return self.prefixes.contains { text.hasPrefix($0) }
    }
    
    convenience init(unboxer: Unboxer) throws {
        let operatorID = try unboxer.unbox(keyPath: "id") as String
        let name = try unboxer.unbox(keyPath: "attributes.name") as String
        let prefixes = try unboxer.unbox(keyPath: "attributes.prefix") as [String]
        let imageUrl = try unboxer.unbox(keyPath: "attributes.image") as String
        let products = try unboxer.unbox(keyPath: "attributes.product") as [DigitalProduct]
        let textInputs = try unboxer.unbox(keyPath: "attributes.fields") as [DigitalTextInput]
        let defaultProductId = try unboxer.unbox(keyPath: "attributes.default_product_id") as String
        let productSelectionTitle = try unboxer.unbox(keyPath: "attributes.rule.product_text") as String
        let productSelectionStyle = try unboxer.unbox(keyPath: "attributes.rule.product_view_style") as String
        let buttonText = try unboxer.unbox(keyPath: "attributes.rule.button_text") as String
        
        self.init(
            operatorID: operatorID,
            name: name,
            prefixes: prefixes,
            imageUrl: imageUrl,
            products: products,
            textInputs: textInputs,
            defaultProductId: defaultProductId,
            productSelectionTitle: productSelectionTitle,
            shouldShowProductSelection: productSelectionStyle != "99",
            buttonText: buttonText
        )
    }
    
    internal var defaultProduct: DigitalProduct? {
        return products.first { $0.id == defaultProductId }
    }
}
