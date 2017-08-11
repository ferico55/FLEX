//
//  FeedDetailProductCellComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 4/17/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render

class FeedDetailProductCellComponentView: ComponentView<FeedDetailProductState> {
    override func construct(state: FeedDetailProductState?, size: CGSize) -> NodeType {
        
        return Node<UIView>() { view, layout, size in
            layout.width = size.width
            layout.flexDirection = .column
            
            view.bk_(whenTapped: {
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_VIEW, label: "Product List - PDP")
                TPRoutes.routeURL(URL(string: (state?.productURL)!)!)
            })
        }.add(children: [
            Node<UIView>() { _, layout, size in
                layout.flexDirection = .row
                layout.width = size.width
            }.add(children: [
                Node<UIView>(identifier: "product-cell-feed-detail") { view, layout, _ in
                    layout.flexDirection = .row
                    
                    view.backgroundColor = .white
                }.add(children: [
                    Node<UIView>(identifier: "product-image-container") { _, layout, _ in
                        layout.padding = 10
                    }.add(child: Node<UIImageView>(identifier: "product-image") { imageView, layout, _ in
                        layout.height = 100
                        layout.width = 100
                        
                        imageView.setImageWith(URL(string: (state?.productImage)!), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
                        imageView.borderWidth = 1.0
                        imageView.borderColor = .tpLine()
                    }),
                    Node<UIView>(identifier: "product-info") { _, layout, _ in
                        layout.flexDirection = .column
                        layout.flexShrink = 1
                        layout.justifyContent = .flexStart
                        layout.marginTop = 10
                    }.add(children: [
                        Node<UILabel>(identifier: "product-name") { label, layout, size in
                            label.text = state?.productName
                            label.font = .smallThemeSemibold()
                            label.textColor = UIColor.tpPrimaryBlackText()
                            label.numberOfLines = 2
                            
                            layout.marginBottom = 3.0
                            layout.flexShrink = 1
                            layout.maxWidth = size.width - 130
                        },
                        Node<UILabel>(identifier: "product-price") { label, layout, _ in
                            layout.marginBottom = 3.0
                            
                            label.text = state?.productPrice
                            label.font = .smallThemeSemibold()
                            label.textColor = .tpOrange()
                        },
                        self.starsComponent(withRate: (state?.productRating)!),
                        self.productStatus(getCashback: (state?.productCashback)!, isWholesale: (state?.productWholesale)!, isPreorder: (state?.productPreorder)!, isFreeReturns: (state?.productFreeReturns)!)
                    ])
                ])
            ]),
            Node<UIView>(identifier: "horizontal-line") { view, layout, _ in
                layout.height = 1
                
                view.backgroundColor = .tpBackground()
            }
        ])
    }
    
    private func starsComponent(withRate rate: Int) -> NodeType {
        let score = Double(rate) / 20.0
        let rating = Int(score.rounded())
        let starsArray = NSMutableArray(capacity: 5)
        
        for index in 1...5 {
            let image = index <= rating ? #imageLiteral(resourceName: "icon_star_active") : #imageLiteral(resourceName: "icon_star")
            
            starsArray.add(Node<UIImageView> { imageView, layout, _ in
                layout.height = 11
                layout.width = 11
                layout.marginRight = 3
                
                imageView.image = image
            })
        }
        
        return (rate == 0) ? NilNode() : Node<UIView>(identifier: "stars") { _, layout, _ in
            layout.flexDirection = .row
            layout.marginBottom = 3
        }.add(children: starsArray as! [NodeType])
    }
    
    private func productStatus(getCashback cashbackAmount: String, isWholesale: Bool, isPreorder: Bool, isFreeReturns: Bool) -> NodeType {
        let productCashback = Node<UILabel>(identifier: "cashback") { label, layout, _ in
            layout.marginRight = 3
            layout.padding = 5
            
            label.text = "Cashback \(cashbackAmount)"
            label.textColor = .white
            label.backgroundColor = .tpGreen()
            label.font = .systemFont(ofSize: 10)
            label.layer.borderColor = UIColor.white.cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 2
            label.clipsToBounds = true
            label.textAlignment = .center
        }
        
        let productWholesale = Node<UILabel>(identifier: "wholesale") { label, layout, _ in
            layout.marginRight = 3
            layout.padding = 5
            
            label.text = "Grosir"
            label.textColor = UIColor.tpSecondaryBlackText()
            label.font = .systemFont(ofSize: 10)
            label.layer.borderColor = UIColor.fromHexString("e0e0e0").cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 2
            label.textAlignment = .center
        }
        
        let productPreorder = Node<UILabel>(identifier: "preorder") { label, layout, _ in
            layout.marginRight = 3
            layout.padding = 5
            
            label.text = "PO"
            label.textColor = UIColor.tpSecondaryBlackText()
            label.font = .systemFont(ofSize: 10)
            label.layer.borderColor = UIColor.fromHexString("e0e0e0").cgColor
            label.layer.borderWidth = 1
            label.layer.cornerRadius = 2
            label.textAlignment = .center
        }
        
        let productFreeReturns = Node<UIImageView>(identifier: "freereturns") { imageView, layout, _ in
            layout.height = 22
            layout.width = 22
            
            imageView.image = #imageLiteral(resourceName: "icon_free")
        }
        
        var productStatusArray: [NodeType] = []
        
        if cashbackAmount != "" {
            productStatusArray += [productCashback]
        }
        
        if isWholesale {
            productStatusArray += [productWholesale]
        }
        
        if isPreorder {
            productStatusArray += [productPreorder]
        }
        
        if isFreeReturns {
            productStatusArray += [productFreeReturns]
        }
        
        return (productStatusArray.count == 0) ? NilNode() : Node<UIView>(identifier: "product-status-container") { _, layout, _ in
            layout.flexDirection = .row
        }.add(children: productStatusArray)
    }
}
