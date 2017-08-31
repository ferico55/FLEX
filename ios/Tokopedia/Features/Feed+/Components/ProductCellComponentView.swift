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
        guard let state = state else { return NilNode() }
        
        if state.isCampaign {
            return self.campaignCell(state: state)
        }
        
        return self.defaultCell(state: state)
    }
    
    private func productImage(state: FeedCardProductState) -> NodeType {
        return Node<UIImageView> { view, layout, _ in
            layout.aspectRatio = 1.0
            layout.marginBottom = state.isLargeCell ? 0.0 : 8.0
            
            view.setImageWith(URL(string: (state.isLargeCell ? state.productImageLarge : state.productImageSmall)), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
            view.cornerRadius = 3.0
            view.contentMode = .scaleAspectFit
        }
    }
    
    private func productName(state: FeedCardProductState) -> NodeType {
        return Node<UIView>(identifier: "name-container") { _, layout, _ in
            if !(state.isLargeCell) {
                layout.height = 32
            }
            
            layout.flexShrink = 1
        }.add(child: Node<UILabel>(identifier: "product-name") { label, _, _ in
            label.text = state.productName
            label.font = .smallThemeSemibold()
            label.textColor = UIColor.tpPrimaryBlackText()
            label.numberOfLines = 2
        })
    }
    
    private func productPrice(state: FeedCardProductState) -> NodeType {
        let originalPriceNode: NodeType = (state.originalPrice == "Rp 0") ? NilNode() : Node<UILabel>() { label, layout, _ in
            let price = NSMutableAttributedString(string: state.originalPrice)
            price.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, state.originalPrice.characters.count))
            label.attributedText = price
            label.font = UIFont.microThemeSemibold()
            label.textColor = .tpDisabledBlackText()
            
            layout.marginBottom = 3
        }
        
        let priceNode = Node<UILabel>(identifier: "product-price") { label, layout, _ in
            label.text = state.productPrice
            label.font = .smallThemeSemibold()
            label.textColor = .tpOrange()
            
            layout.marginRight = 8
        }
        
        let priceContainer = Node<UIView>(identifier: "price-container") { _, layout, _ in
            layout.flexShrink = 1
            layout.flexDirection = .column
            layout.marginBottom = 6
            layout.height = 50
        }.add(children: [
            originalPriceNode,
            Node<UIView>() { _, layout, _ in
                layout.flexDirection = .row
                layout.flexWrap = .wrap
                layout.alignItems = .center
                layout.alignContent = .center
            }.add(children: [
                priceNode,
                (state.discountPercentage != 0) ? Node<UILabel>() { label, layout, _ in
                    layout.padding = 5
                    layout.height = 16
                    
                    label.text = "\(state.discountPercentage)% Off"
                    label.textColor = .white
                    label.backgroundColor = .tpRed()
                    label.font = .semiboldSystemFont(ofSize: 10)
                    label.layer.borderColor = UIColor.white.cgColor
                    label.layer.borderWidth = 1
                    label.layer.cornerRadius = 3
                    label.clipsToBounds = true
                    label.textAlignment = .center
                } : NilNode()
            ])
        ])
        
        return state.isCampaign ? priceContainer : priceNode
    }
    
    private func productLabel(state: FeedCardProductState) -> NodeType {
        let labelNodes: [NodeType] = state.labels.map { labelState in
            let node = Node<UILabel>() { label, layout, _ in
                layout.marginRight = 3
                layout.padding = 5
                layout.height = 18
                layout.marginBottom = 3
                
                label.text = labelState.text
                label.textColor = labelState.textColor
                label.backgroundColor = UIColor.fromHexString(labelState.backgroundColor)
                label.font = .semiboldSystemFont(ofSize: 10)
                label.layer.borderColor = labelState.textColor.cgColor
                label.layer.borderWidth = 1
                label.layer.cornerRadius = 3
                label.clipsToBounds = true
                label.textAlignment = .center
            }
            
            return node
        }
        
        return Node<UIView>() { _, layout, _ in
            layout.flexShrink = 1
            layout.flexWrap = .wrap
            layout.flexDirection = .row
            layout.height = 36
            layout.marginBottom = 10
        }.add(children: labelNodes)
    }
    
    private func officialStoreInfo(state: FeedCardProductState) -> NodeType {
        let shopImage = Node<UIImageView>() { imageView, layout, _ in
            imageView.setImageWith(URL(string: state.shopImageURL), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
            imageView.borderColor = UIColor.fromHexString("#e0e0e0")
            imageView.borderWidth = 1
            imageView.cornerRadius = 2
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            layout.width = 30
            layout.height = 30
            layout.marginRight = 8
        }
        
        let shopName = Node<UILabel>() { label, layout, _ in
            label.text = state.shopName
            label.font = .microTheme()
            label.textColor = .tpPrimaryBlackText()
            
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.marginRight = 8
        }
        
        let freeReturns: NodeType = state.isFreeReturns ? Node<UIImageView>() { imageView, layout, _ in
            imageView.image = #imageLiteral(resourceName: "icon_free")
            
            layout.width = 16
            layout.height = 16
            
        } : NilNode()
        
        let container = Node<UIView>() { view, layout, _ in
            view.backgroundColor = .white
            
            layout.height = 45
            layout.flexDirection = .row
            layout.padding = 5
            layout.alignItems = .center
            
            view.bk_(whenTapped: {
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Official Store Campaign - Shop")
                TPRoutes.routeURL(URL(string: state.shopURL)!)
            })
        }.add(children: [
            shopImage,
            shopName,
            freeReturns
        ])
        
        return container
    }
    
    private func defaultCell(state: FeedCardProductState) -> NodeType {
        let largeCell = Node<UIView>(identifier: "large-cell") { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexDirection = .column
            layout.flexGrow = 1
        }.add(children: [
            self.productImage(state: state),
            Node<UIView>() { _, layout, _ in
                layout.flexDirection = .column
                layout.padding = 5
                layout.flexShrink = 1
                layout.flexGrow = 1
            }.add(children: [
                self.productName(state: state),
                self.productPrice(state: state)
            ])
        ])
        
        let smallCell = Node<UIView>(identifier: "small-cell") { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexDirection = .column
            layout.flexShrink = 1
            layout.flexGrow = 1
            layout.padding = 5
        }.add(children: [
            self.productImage(state: state),
            self.productName(state: state),
            self.productPrice(state: state)
        ])
        
        let productCellLayout = state.isLargeCell ? largeCell : smallCell
        
        let productCell = Node<UIView>(identifier: "product-cell") { view, layout, size in
            layout.flexGrow = 1
            layout.flexShrink = 1
            
            layout.width = size.width
            
            if state.isMore {
                view.bk_(whenTapped: {
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Feed - Product List More Items")
                    NavigateViewController().navigateToFeedDetail(from: UIApplication.topViewController(), withFeedCardID: state.cardID)
                })
            } else {
                view.bk_(whenTapped: {
                    if state.isRecommendationProduct {
                        AnalyticsManager.trackEventName("r3", category: "r3User", action: GA_EVENT_ACTION_CLICK, label: "feed - \(state.recommendationProductSource)")
                    } else {
                        AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_VIEW, label: "Feed - PDP")
                    }
                    
                    TPRoutes.routeURL(URL(string: state.productURL)!)
                })
            }
            
        }.add(children: [
            productCellLayout,
            state.isMore ? Node<UIView>(identifier: "more") { view, layout, _ in
                layout.top = 0
                layout.left = 0
                layout.bottom = 0
                layout.right = 0
                layout.position = .absolute
                layout.flexGrow = 1
                layout.alignItems = .center
                layout.justifyContent = .center
                
                view.backgroundColor = UIColor.tpPrimaryBlackText()
            }.add(child: Node<UILabel>(identifier: "more-label") { label, layout, _ in
                layout.position = .absolute
                
                label.text = "+\(state.remaining!)"
                label.font = UIFont.systemFont(ofSize: 36.0)
                label.textColor = .white
            }) : NilNode()
        ])
        
        return productCell
    }
    
    private func campaignCell(state: FeedCardProductState) -> NodeType {
        let cellLayout = Node<UIView>() { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexDirection = .column
            layout.padding = 5
            
            view.bk_(whenTapped: {
                AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "Official Store Campaign - PDP")
                TPRoutes.routeURL(URL(string: state.productURL)!)
            })
        }.add(children: [
            self.productImage(state: state),
            self.productName(state: state),
            self.productPrice(state: state),
            self.productLabel(state: state)
        ])
        
        return Node<UIView>() { _, layout, _ in
            layout.flexDirection = .column
            layout.alignItems = .stretch
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.flexBasis = 1
        }.add(children: [
            cellLayout,
            GlobalRenderComponent.horizontalLine(identifier: "", marginLeft: 0),
            self.officialStoreInfo(state: state)
        ])
    }
}
