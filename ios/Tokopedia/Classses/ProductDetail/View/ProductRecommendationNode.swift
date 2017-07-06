//
//  ProductRecommendationNode.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 7/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render

class ProductRecommendationNode: ContainerNode {
    fileprivate let state: ProductDetailState
    fileprivate let didTapProduct: (String) -> Void
    var scrollView: UIScrollView?
    
    init(identifier: String, state: ProductDetailState, didTapProduct: @escaping (String) -> Void) {
        self.state = state
        self.didTapProduct = didTapProduct
        
        super.init(identifier: identifier)
        
        guard let products = state.productDetail?.otherProducts else { return }
        if products.count == 0 {
            return
        }
        
        node.add(children: [
            container().add(children: [
                GlobalRenderComponent.horizontalLine(identifier: "Recommendation-Line-1", marginLeft: 0),
                titleLabel(),
                GlobalRenderComponent.horizontalLine(identifier: "Recommendation-Line-2", marginLeft: 0),
                productRecommendListView(),
                GlobalRenderComponent.horizontalLine(identifier: "Recommendation-Line-3", marginLeft: 0)
                ])
            ])
    }
    
    func container() -> NodeType {
        return Node<UIView>() { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            layout.marginTop = 10
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
        }
    }
    
    func titleLabel() -> NodeType {
        return Node<UILabel>() { view, layout, _ in
            layout.marginLeft = 15
            layout.marginTop = 22
            layout.marginBottom = 22
            view.text = "Produk Lainnya dari Toko ini"
            view.textColor = .tpPrimaryBlackText()
            view.font = .largeThemeMedium()
        }
    }
    
    func productRecommendListView() -> NodeType {
        guard let products = state.productDetail?.otherProducts.map({ (product) -> NodeType in
            productRecommendFrameView(product: product)
        }) else { return NilNode() }
        
        return Node<UIScrollView>(identifier: "Product-Scroll-View") { view, layout, size in
            layout.width = size.width
            layout.height = 213
            layout.flexDirection = .row
            layout.alignItems = .stretch
            view.showsHorizontalScrollIndicator = true
            view.isPagingEnabled = false
            view.bounces = true
            view.contentSize.width = 154.0 * CGFloat(products.count)
            }.add(children: products)
        
    }
    
    func productRecommendFrameView(product: OtherProduct) -> NodeType {
        return Node { view, layout, _ in
            layout.flexDirection = .row
            view.isUserInteractionEnabled = true
            }.add(children: [
                productRecommendView(product: product),
                GlobalRenderComponent.verticalLine(identifier: "Recommendation-Vertical-Line")
                ])
    }
    
    func productRecommendView(product: OtherProduct) -> NodeType {
        return Node { view, layout, _ in
            layout.margin = 10
            layout.flexDirection = .column
            view.isUserInteractionEnabled = true
            
            let tapGestureRecognizer = UITapGestureRecognizer()
            _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                self.didTapProduct(product.id)
            })
            
            view.addGestureRecognizer(tapGestureRecognizer)
            
            }.add(children: [
                Node<UIImageView>() { view, layout, _ in
                    layout.width = 133
                    layout.height = 133
                    view.contentMode = .scaleAspectFill
                    view.clipsToBounds = true
                    view.layer.cornerRadius = 4
                    view.layer.masksToBounds = true
                    view.backgroundColor = .tpBackground()
                    view.setImageWith(URL(string: product.image))
                },
                Node<UILabel>() { view, layout, _ in
                    layout.marginTop = 10
                    layout.marginBottom = 4
                    layout.width = 133
                    view.text = product.name
                    view.font = .smallThemeSemibold()
                    view.textColor = .tpPrimaryBlackText()
                    view.numberOfLines = 2
                },
                Node<UILabel>() { view, layout, _ in
                    layout.width = 133
                    view.text = product.price
                    view.font = .smallThemeSemibold()
                    view.textColor = .tpOrange()
                }
                ])
    }
}
