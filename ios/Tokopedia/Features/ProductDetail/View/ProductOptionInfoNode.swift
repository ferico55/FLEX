//
//  ProductOptionInfoNode.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 02/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Render
import UIKit

internal struct ProductOptionInfoNode {
    internal static func createNode(identifier: String,
                           state: ProductDetailState,
                           didTapWholesale: @escaping ([ProductWholesale]) -> Void,
                           didTapVariant: @escaping (ProductVariant, ProductUnbox) -> Void) -> NodeType {

        guard let productDetail = state.productDetail else { return NilNode() }

        var separatorView: NodeType

        if let productVariant = productDetail.variantProduct, !productVariant.variants.isEmpty {
            separatorView = GlobalRenderComponent.horizontalLine(identifier: "Option-Info-Line-2", marginLeft: 15)
        } else {
            separatorView = NilNode()
        }

        return Node<UIView>(identifier: identifier) { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            layout.marginTop = 10
            view.shadowColor = .black
            view.shadowOffset = CGSize(width: 0, height: 1)
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
            }.add(children: [
                ProductVariantNode(identifier: "Variant", state: state, didTapVariant: didTapVariant),
                separatorView,
                ProductPriceNode(identifier: "Price", state: state, didTapWholesale: didTapWholesale)
                ])
    }
}
