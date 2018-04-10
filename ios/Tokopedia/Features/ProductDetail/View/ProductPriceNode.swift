//
//  ProductPriceNode.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 7/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Render
import UIKit

internal class ProductPriceNode: ContainerNode {
    fileprivate let state: ProductDetailState
    fileprivate let didTapWholesale: ([ProductWholesale]) -> Void
    
    internal init(identifier: String, state: ProductDetailState, didTapWholesale: @escaping ([ProductWholesale]) -> Void) {
        self.state = state
        self.didTapWholesale = didTapWholesale
        
        super.init(identifier: identifier)
        
        guard let productDetail = self.state.productDetail else {
            return
        }
        
        if productDetail.wholesale.isEmpty {
            return
        }
        
        node.add(children: [
            container().add(children: [
                // TODO : for future update -> cicilan feature
//                priceListview(title: "Cicilan", subtitle: "Bunga 0% mulai dari Rp 12.000"),
//                GlobalRenderComponent.horizontalLine(identifier: "Price-Line-2", marginLeft: 15),
                wholesaleView()
                ])
            ])
    }
    
    private func container() -> NodeType {
        return Node<UIView>() { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
        }
    }
    
    private func wholesaleView() -> NodeType {
        guard let wholesales = state.productDetail?.wholesale,
            let minWholesalePrice = wholesales.last?.price else {
                return NilNode()
        }
        
        return Node<UIButton>() { view, layout, _ in
            layout.paddingTop = 15
            layout.paddingBottom = 15
            view.accessibilityLabel = "wholesaleButton"
            view.backgroundColor = .white
            _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                self.didTapWholesale(wholesales)
            })
            
            }.add(children: [
                Node<UILabel>(identifier: "Title-Label") { view, layout, _ in
                    layout.marginLeft = 15
                    layout.marginBottom = 4
                    view.font = .title1Theme()
                    view.text = "Harga Grosir"
                    view.textColor = .tpSecondaryBlackText()
                },
                Node<UILabel>(identifier: "Subtitle-Label") { view, layout, _ in
                    layout.marginLeft = 15
                    view.font = .microTheme()
                    view.text = "Mulai dari Rp \(minWholesalePrice)"
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
