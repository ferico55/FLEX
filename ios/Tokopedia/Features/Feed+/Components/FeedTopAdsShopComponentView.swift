//
//  FeedTopAdsShopComponentView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/30/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Render
import RxSwift
import UIKit

internal class FeedTopAdsShopComponentView: ComponentView<FeedTopAdsShopState> {
    
    private var onTapFavoriteButton: ((FeedTopAdsShopState) -> Void)
    
    internal init(onTapFavoriteButton: @escaping ((FeedTopAdsShopState) -> Void)) {
        self.onTapFavoriteButton = onTapFavoriteButton
        super.init()
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func construct(state: FeedTopAdsShopState?, size: CGSize) -> NodeType {
        if let state = state {
            return self.componentContainer(state: state, size: size)
        }
        
        return Node<UIView>() { _, _, _ in
            
        }
    }
    
    private func componentContainer(state: FeedTopAdsShopState, size: CGSize) -> NodeType {
        return Node<UIView>() { view, layout, size in
            view.backgroundColor = .tpBackground()
            view.isUserInteractionEnabled = true
            
            layout.flexDirection = .column
            layout.width = size.width
        }.add(children: [
            Node<UIView>() { view, layout, size in
                layout.flexDirection = .column
                layout.width = size.width
                
                view.borderWidth = 1
                view.borderColor = .fromHexString("#e0e0e0")
                view.backgroundColor = .white
                view.isUserInteractionEnabled = true
                
                view.bk_(whenTapped: {
                    if let url = URL(string: state.shopURL) {
                        TPRoutes.routeURL(url)
                        TopAdsService.sendClickImpression(clickURLString: state.topadsClickURL)
                    }
                })
            }.add(children: [
                self.shopHeaderView(state: state),
                self.productLayout(state: state),
                self.favoriteButtonView(state: state)
            ]),
            self.blankSpace()
        ])
    }
    
    private func shopHeaderView(state: FeedTopAdsShopState) -> NodeType {
        let shopImage = Node<UIImageView>() { view, layout, _ in
            guard let url = URL(string: state.shopImage) else {
                return
            }
            
            view.setImageWith(url, placeholderImage: #imageLiteral(resourceName: "grey-bg.png"))
            view.borderWidth = 1.0
            view.borderColor = .fromHexString("#e0e0e0")
            view.cornerRadius = 3
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFit
            
            layout.height = 52
            layout.width = 52
        }
        
        let shopInfo = Node<UIView>() { _, layout, _ in
            layout.flexDirection = .column
            layout.flexShrink = 1
            layout.marginLeft = 8
        }.add(children: [
            Node<UILabel>() { label, layout, _ in
                layout.flexShrink = 1
                layout.marginBottom = 3
                
                label.numberOfLines = 1
                label.attributedText = self.shopName(state: state)
            },
            Node<UILabel>() { label, _, _ in
                label.text = state.shopLocation
                label.font = .microTheme()
                label.textColor = .tpDisabledBlackText()
            }
        ])
        
        return Node<UIView>() { view, layout, _ in
            layout.flexDirection = .row
            layout.alignItems = .center
            layout.justifyContent = .spaceBetween
            layout.marginHorizontal = 10
            layout.marginVertical = 10
            
            view.isUserInteractionEnabled = true
        }.add(child: Node<UIView>() { _, layout, _ in
            layout.flexDirection = .row
            layout.alignItems = .center
            layout.flexShrink = 1
        }.add(children: [
            shopImage,
            shopInfo
        ]))
    }
    
    private func favoriteButton(state: FeedTopAdsShopState) -> NodeType {
        return Node<UIButton>() { button, layout, _ in
            if !state.buttonIsLoading {
                button.setTitle(state.isFavoritedShop ? " Favorit" : "Favoritkan", for: .normal)
                button.setImage(state.isFavoritedShop ? #imageLiteral(resourceName: "icon_check_favorited") : #imageLiteral(resourceName: "icon_follow_plus"), for: .normal)
            }
            button.imageView?.contentMode = .scaleAspectFit
            button.backgroundColor = state.isFavoritedShop ? .white : .tpGreen()
            button.borderColor = state.isFavoritedShop ? .tpBorder() : .tpGreen()
            button.borderWidth = 1
            button.titleLabel?.font = .microThemeSemibold()
            button.setTitleColor(state.isFavoritedShop ? .tpSecondaryBlackText() : .white, for: .normal)
            button.cornerRadius = 4
            button.isUserInteractionEnabled = true
            
            button.rx.tap
                .subscribe(onNext: {
                    self.onTapFavoriteButton(state)
                })
                .disposed(by: self.rx_disposeBag)
            
            layout.height = 32
            layout.justifyContent = .center
            layout.alignContent = .center
        }.add(child: state.buttonIsLoading ? Node<UIActivityIndicatorView>() { view, layout, _ in
            view.activityIndicatorViewStyle = state.isFavoritedShop ? .gray : .white
            view.startAnimating()
            
            layout.alignSelf = .center
        } : NilNode())
    }
    
    private func favoriteButtonView(state: FeedTopAdsShopState) -> NodeType {
        return Node<UIView>() { view, layout, _ in
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
            
            layout.padding = 10
        }.add(child: self.favoriteButton(state: state))
    }
    
    private func productLayout(state: FeedTopAdsShopState) -> NodeType {
        if state.productImages.count < 3 {
            return NilNode()
        }
        
        return Node<UIView>() { _, layout, size in
            layout.padding = 1
            layout.flexDirection = .row
            layout.width = size.width
        }.add(children: [
            self.productImage(urlString: state.productImages[0]),
            self.productImage(urlString: state.productImages[1]),
            self.productImage(urlString: state.productImages[2])
        ])
    }
    
    private func productImage(urlString: String) -> NodeType {
        return Node<UIView>() { view, layout, _ in
            view.backgroundColor = .white
            
            layout.flexGrow = 1
            layout.flexShrink = 1
            layout.padding = 1
        }.add(child: Node<UIImageView>() { imageView, layout, _ in
            imageView.setImageWith(URL(string: urlString), placeholderImage: #imageLiteral(resourceName: "grey-bg.png"))
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
            
            layout.aspectRatio = 1
            layout.flexGrow = 1
            layout.flexShrink = 1
        })
    }
    
    private func shopName(state: FeedTopAdsShopState) -> NSMutableAttributedString {
        let bold: [String: Any] = [
            NSFontAttributeName: UIFont.largeThemeMedium(),
            NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()
        ]
        
        let attachment = NSTextAttachment()
        attachment.image = #imageLiteral(resourceName: "Badges_gold_merchant")
        attachment.bounds = CGRect(x: 0, y: 0, width: 12, height: 12)
        
        let badge = NSAttributedString(attachment: attachment)
        
        let string = NSMutableAttributedString()
        
        if state.isGoldMerchant {
            string.append(badge)
            string.append(NSAttributedString(string: " ", attributes: bold))
        }
        
        string.append(NSAttributedString(string: "\(state.shopName) ", attributes: bold))
        
        let topAdsIconAttachment = NSTextAttachment()
        topAdsIconAttachment.image = #imageLiteral(resourceName: "icon_topads")
        topAdsIconAttachment.bounds = CGRect(x: 0, y: 0, width: 10, height: 8)
        
        let icon = NSAttributedString(attachment: topAdsIconAttachment)
        
        string.append(icon)
        
        return string
    }
    
    private func horizontalLine() -> NodeType {
        return Node<UIView>() { view, layout, _ in
            layout.height = 1
            
            view.backgroundColor = .fromHexString("#e0e0e0")
        }
    }
    
    private func verticalLine() -> NodeType {
        return Node<UIView>() { view, layout, _ in
            layout.width = 1
            
            view.backgroundColor = .fromHexString("#e0e0e0")
        }
    }
    
    private func blankSpace() -> NodeType {
        return Node<UIView>(identifier: "blank-space") { view, layout, size in
            layout.height = 15
            layout.width = size.width
            
            view.backgroundColor = .tpBackground()
        }
    }
}
