//
//  ProductVariantNode.swift
//  Tokopedia
//
//  Created by Digital Khrisna on 02/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Render
import UIKit

internal class ProductVariantNode: ContainerNode {
    private let state: ProductDetailState
    private let didTapVariant: (ProductVariant, ProductUnbox) -> Void

    internal init(identifier: String, state: ProductDetailState, didTapVariant: @escaping (ProductVariant, ProductUnbox) -> Void) {
        self.state = state
        self.didTapVariant = didTapVariant

        super.init(identifier: identifier)

        guard let productDetail = self.state.productDetail, let productVariant = productDetail.variantProduct else {
            return
        }

        if productVariant.variants.isEmpty {
            return
        }

        node.add(children: [
            container().add(children: [
                variantView()
                ])
            ])
    }

    private func container() -> NodeType {
        return Node<UIView> { (view, layout, size) in
            layout.width = size.width
            layout.flexDirection = .column
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
        }
    }

    private func variantView() -> NodeType {
        guard let productDetail = state.productDetail, let productVariant = productDetail.variantProduct, let _ = productVariant.variants.first else {
            return NilNode()
        }

        return Node<UIButton> { (view, layout, _) in
            layout.paddingTop = 15
            layout.paddingBottom = 15
            view.accessibilityLabel = "variantbutton"
            view.backgroundColor = .white
            _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                self.didTapVariant(productVariant, productDetail)
            })
            }.add(children: [
                Node<UILabel>(identifier: "Title-Label") { view, layout, _ in
                    layout.marginLeft = 15
                    layout.marginBottom = 4
                    view.font = .title1Theme()
                    view.text = "Varian"
                    view.textColor = .tpSecondaryBlackText()
                },
                Node<UILabel>(identifier: "Subtitle-Label") { view, layout, _ in
                    layout.marginLeft = 15
                    view.font = .microTheme()

                    if let selectedVariant = productVariant.productVariantSelected {
                        view.text = selectedVariant.map { $0.variantValue }.joined(separator: ", ")
                    } else {
                        view.text = "Pilih warna & ukuran"
                    }

                    view.textColor = .tpDisabledBlackText()
                },
                Node<UIImageView>(identifier: "Arrow-ImageView") { view, layout, _ in
                    layout.top = 24
                    layout.right = 15
                    layout.position = .absolute
                    layout.width = 18
                    layout.height = 18
                    view.image = #imageLiteral(resourceName: "icon_carret_next")
                }
                ])
    }
}
