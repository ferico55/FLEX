//
//  ProductCellComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Render

enum ProductCellType {
    case small
    case medium
    case large
}

class ProductCellComponentView: ComponentView<FeedCardProductState> {
    override func construct(state: FeedCardProductState?, size: CGSize) -> NodeType {
        
        let productImage = Node<UIImageView> { view, layout, _ in
            layout.aspectRatio = 1.0
            layout.marginBottom = (state?.isLargeCell)! ? 0.0 : 8.0
            
            view.setImageWith(URL(string: ((state?.isLargeCell)! ? state?.productImageLarge : state?.productImageSmall)!), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
            view.cornerRadius = 3.0
        }
        
        let productName = Node<UIView>(identifier: "name-container") { _, layout, _ in
            if !(state?.isLargeCell)! {
                layout.height = 32
            }
            
            layout.flexShrink = 1
        }.add(child: Node<UILabel>(identifier: "product-name") { label, layout, _ in
            label.text = state?.productName
            label.font = .smallThemeSemibold()
            label.textColor = UIColor.black.withAlphaComponent(0.70)
            label.numberOfLines = 2
            
            layout.flexShrink = 1
        })
        
        let productPrice = Node<UILabel>(identifier: "product-price") { label, layout, _ in
            label.text = state?.productPrice
            label.font = .smallTheme()
            label.textColor = .tpOrange()
            
            layout.marginBottom = 0
        }
        
        let largeCell = Node<UIView>(identifier: "large-cell") { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexDirection = .column
            layout.flexGrow = 1
        }.add(children: [
            productImage,
            Node<UIView>() { _, layout, _ in
                layout.flexDirection = .column
                layout.padding = 5
                layout.flexShrink = 1
                layout.flexGrow = 1
            }.add(children: [
                productName,
                productPrice
            ])
        ])
        
        let smallCell = Node<UIView>(identifier: "small-cell") { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexDirection = .column
            layout.flexShrink = 1
            layout.flexGrow = 1
            layout.padding = 5
        }.add(children: [
            productImage,
            productName,
            productPrice
        ])
        
        let productCellLayout = (state?.isLargeCell)! ? largeCell : smallCell
        
        let productCell = Node<UIView>(identifier: "product-cell") { view, layout, size in
            layout.flexGrow = 1
            layout.flexShrink = 1
            
            layout.width = size.width
            
            if (state?.isMore)! {
                view.bk_(whenTapped: {
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Feed - Product List More Items")
                    NavigateViewController().navigateToFeedDetail(from: UIApplication.topViewController(), withFeedCardID: state?.cardID)
                })
            } else {
                view.bk_(whenTapped: {
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_VIEW, label: "Feed - PDP")
                    TPRoutes.routeURL(URL(string: (state?.productURL)!)!)
                })
            }
            
        }.add(children: [
            productCellLayout,
            (state?.isMore)! ? Node<UIView>(identifier: "more") { view, layout, _ in
                layout.top = 0
                layout.left = 0
                layout.bottom = 0
                layout.right = 0
                layout.position = .absolute
                layout.flexGrow = 1
                layout.alignItems = .center
                layout.justifyContent = .center
                
                view.backgroundColor = UIColor.black.withAlphaComponent(0.70)
            }.add(child: Node<UILabel>(identifier: "more-label") { label, layout, _ in
                layout.position = .absolute
                
                label.text = "+\((state!.remaining)!)"
                label.font = UIFont.systemFont(ofSize: 36.0)
                label.textColor = .white
            }) : NilNode()
        ])
        
        return productCell
    }
}
