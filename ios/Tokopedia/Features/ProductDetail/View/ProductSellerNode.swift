//
//  ProductSellerNode.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 7/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render

class ProductSellerInfoNode: ContainerNode {
    fileprivate let state: ProductDetailState
    fileprivate let didTapShop: (ProductShop) -> Void
    fileprivate let didTapFavorite: (Bool) -> Void
    fileprivate let didTapMessage: () -> Void
    fileprivate let didTapReputation: (UIView, String) -> Void
    
    init(identifier: String, state: ProductDetailState, didTapShop: @escaping (ProductShop) -> Void, didTapFavorite: @escaping (Bool) -> Void, didTapMessage: @escaping () -> Void, didTapReputation: @escaping (UIView, String) -> Void) {
        self.state = state
        self.didTapShop = didTapShop
        self.didTapFavorite = didTapFavorite
        self.didTapMessage = didTapMessage
        self.didTapReputation = didTapReputation
        
        super.init(identifier: identifier)
        
        node.add(children: [
            container().add(children: [
                GlobalRenderComponent.horizontalLine(identifier: "Seller-Line-1", marginLeft: 0),
                titleLabel(),
                sellerInfoView(),
                sellerBottomView(),
                GlobalRenderComponent.horizontalLine(identifier: "Seller-Line-2", marginLeft: 0)
                ])
            ])
    }
    
    private func container() -> NodeType {
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
            view.text = "Penjual"
            view.textColor = .tpPrimaryBlackText()
            view.font = .largeThemeMedium()
        }
    }
    
    private func sellerBadge(shouldShowBadge: Bool) -> NodeType {
        guard let shop = state.productDetail?.shop,
            shouldShowBadge else {
                return NilNode()
        }
        
        return Node<UIImageView>() { view, layout, _ in
            layout.marginRight = 4
            layout.width = 18
            layout.height = 18
            view.image = shop.badgeImage
        }
    }
    
    private func sellerInfoName(shouldShowBadge: Bool) -> NodeType {
        guard let productDetail = state.productDetail else { return NilNode() }
        
        return Node<UIView>() { view, layout, _ in
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = true
            
            layout.flexDirection = .row
            }.add(children: [
                sellerBadge(shouldShowBadge: shouldShowBadge),
                Node<UILabel>() { view, layout, size in
                    let shopName = productDetail.shop.name.kv_decodeHTMLCharacterEntities()
                    layout.marginRight = 15
                    layout.width = size.width - 120
                    view.text = shopName
                    view.textColor = .tpPrimaryBlackText()
                    view.font = .title1Theme()
                    view.numberOfLines = 2
                    view.isUserInteractionEnabled = true
                    
                    let tapGestureRecognizer = UITapGestureRecognizer()
                    _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                        self.didTapShop(productDetail.shop)
                    })
                    
                    view.addGestureRecognizer(tapGestureRecognizer)
                }
                ])
    }
    
    private func sellerInfoPicture() -> NodeType {
        guard let shop = state.productDetail?.shop else { return NilNode() }
        
        return Node<UIImageView>() { view, layout, _ in
            layout.width = 48
            layout.height = 48
            layout.marginLeft = 15
            view.backgroundColor = .tpBackground()
            view.contentMode = .scaleAspectFill
            view.clipsToBounds = true
            view.setImageWith(URL(string: shop.avatarURL))
            view.isUserInteractionEnabled = true
            
            let tapGestureRecognizer = UITapGestureRecognizer()
            _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                self.didTapShop(shop)
            })
            
            view.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    private func sellerInfoView() -> NodeType {
        guard let productDetail = state.productDetail else { return NilNode() }
        
        let shop = productDetail.shop
        return Node<UIView>(identifier: "image-shop-\(shop.avatarURL)") { view, layout, _ in
            layout.flexDirection = .row
            layout.marginBottom = 12
            
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = true
            
            }.add(children: [
                sellerInfoPicture(),
                Node<UIView>() { view, layout, _ in
                    layout.flexDirection = .column
                    layout.marginLeft = 15
                    view.isUserInteractionEnabled = true
                    view.backgroundColor = .clear
                    
                    let tapGestureRecognizer = UITapGestureRecognizer()
                    _ = tapGestureRecognizer.rx.event.subscribe(onNext: { [unowned self] _ in
                        self.didTapReputation(view, productDetail.shop.reputationScore)
                    })
                    
                    view.addGestureRecognizer(tapGestureRecognizer)
                    
                    }.add(children: [
                        sellerInfoName(shouldShowBadge: (shop.isOfficial || shop.isGoldMerchant)),
                        Node<UIView>() { _, layout, _ in
                            layout.width = 90
                            layout.height = 18
                            layout.flexDirection = .row
                            layout.justifyContent = .flexStart
                            layout.marginTop = 6
                            layout.marginBottom = 5
                            layout.alignSelf = .flexStart
                            }.add(children: reputationBadges())
                        ])
                ])
    }
    
    private func reputationBadgeView(image: UIImage) -> NodeType {
        return Node<UIImageView> { view, layout, _ in
            layout.width = 18
            layout.height = 18
            
            view.image = image
        }
    }
    
    private func reputationBadges() -> [NodeType] {
        var badges = [NodeType]()
        
        guard let level = state.productDetail?.shop.badgeLevel, let set = state.productDetail?.shop.badgeSet else { return badges }
        
        let images = SmileyAndMedal.medal(withLevel: level, andSet: set)
        
        for image: UIImage in images! {
            badges.append(reputationBadgeView(image: image))
        }
        
        return badges
    }
    
    private func favoriteButton() -> NodeType {
        guard let isFavorited = state.productDetail?.isShopFavorited else { return NilNode() }
        
        if state.productDetailActivity != .normal && state.productDetailActivity != .inactive && state.productDetailActivity != .replacement {
            return NilNode()
        }
        
        if self.state.isFavoriteLoading {
            return Node<UIActivityIndicatorView>() { view, layout, _ in
                layout.width = 84
                layout.height = 32
                layout.marginTop = 2
                layout.marginRight = 20
                view.activityIndicatorViewStyle = .gray
                view.startAnimating()
            }
        } else if isFavorited {
            return Node<UIButton>() { view, layout, _ in
                layout.width = 84
                layout.height = 32
                layout.marginTop = 2
                layout.marginRight = 15
                view.layer.cornerRadius = 4
                view.layer.masksToBounds = true
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.tpLine().cgColor
                view.backgroundColor = .clear
                view.titleLabel?.font = .microTheme()
                view.setTitle("Favorit", for: .normal)
                view.setTitleColor(.tpPrimaryBlackText(), for: .normal)
                view.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0)
                _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                    self.didTapFavorite(false)
                })
                }.add(child: Node<UIImageView>() { view, layout, _ in
                    layout.width = 12
                    layout.height = 10
                    layout.marginTop = 11
                    layout.marginLeft = 12
                    view.image = UIImage(named: "icon_check_favorited")
                    view.backgroundColor = .clear
                })
        }
        
        return Node<UIButton>() { view, layout, _ in
            layout.width = 84
            layout.height = 32
            layout.marginTop = 2
            layout.marginRight = 15
            view.layer.cornerRadius = 4
            view.layer.masksToBounds = true
            view.layer.borderWidth = 1
            view.layer.borderColor = UIColor.tpLine().cgColor
            view.backgroundColor = .tpGreen()
            view.titleLabel?.font = .microTheme()
            view.setTitle("Favoritkan", for: .normal)
            view.setTitleColor(.white, for: .normal)
            view.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 0)
            _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                self.didTapFavorite(true)
            })
            }.add(child: Node<UIImageView>() { view, layout, _ in
                layout.width = 14
                layout.height = 14
                layout.marginTop = 9
                layout.marginLeft = 6
                view.image = UIImage(named: "icon_plus_white")
                view.backgroundColor = .clear
            })
    }
    
    private func messageButton() -> NodeType {
        if state.productDetailActivity == .normal || state.productDetailActivity == .inactive || state.productDetailActivity == .replacement {
            return Node<UIButton>() { view, layout, _ in
                layout.width = 84
                layout.height = 32
                layout.marginTop = 2
                layout.marginRight = 10
                view.layer.cornerRadius = 4
                view.layer.masksToBounds = true
                view.layer.borderWidth = 1
                view.layer.borderColor = UIColor.tpLine().cgColor
                view.titleLabel?.font = .microTheme()
                view.setTitle("Kirim Pesan", for: .normal)
                view.setTitleColor(.tpPrimaryBlackText(), for: .normal)
                _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                    self.didTapMessage()
                })
            }
        }
        return NilNode()
    }
    
    private func sellerInfoDescription(iconImage: UIImage?, title: String) -> NodeType {
        return Node { _, layout, _ in
            layout.flexDirection = .row
            layout.marginBottom = 5
            }.add(children: [
                Node<UIImageView>() { view, layout, _ in
                    layout.marginTop = 2
                    layout.marginRight = 5
                    layout.width = 12
                    layout.height = 12
                    view.image = iconImage ?? UIImage(named: "")
                },
                Node<UILabel>() { view, layout, size in
                    layout.width = size.width - 240
                    view.text = title
                    view.textColor = .tpDisabledBlackText()
                    view.font = .microTheme()
                    view.numberOfLines = 2
                }
                ])
    }
    
    private func sellerBottomView() -> NodeType {
        guard let productShop = state.productDetail?.shop else { return NilNode() }
        
        return Node(identifier: "wrapper-\(productShop.location)") { _, layout, _ in
            layout.marginBottom = 22
            layout.flexDirection = .row
            
            }.add(children: [
                Node(identifier: "wrapper-\(productShop.lastLogin)") { _, layout, _ in
                    layout.flexDirection = .column
                    layout.marginLeft = 15
                    layout.flexShrink = 1
                    }.add(children: [
                        sellerInfoDescription(iconImage: UIImage(named: "icon_location_grey"), title: productShop.location),
                        sellerInfoDescription(iconImage: UIImage(named: "icon_clock"), title: productShop.lastLogin)
                        ]),
                Node { _, layout, _ in
                    layout.justifyContent = .spaceBetween
                    layout.flexGrow = 1
                },
                messageButton(),
                favoriteButton()
                
                ])
    }
}
