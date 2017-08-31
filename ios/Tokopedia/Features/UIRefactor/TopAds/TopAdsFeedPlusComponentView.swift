//
//  TopAdsComponentView.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 5/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit
import Render
import RxSwift
import ReSwift
import CFAlertViewController

struct TopAdsFeedPlusState: Render.StateType, ReSwift.StateType {
    var topAds: [PromoResult]?
    var isDoneFavoriteShop = false
    var isLoadingFavoriteShop = false
    var currentViewController = UIViewController()
}

class TopAdsFeedPlusComponentView: ComponentView<TopAdsFeedPlusState> {
    
    private var callback: (_ state: TopAdsFeedPlusState) -> ()
    
    override init() {
        callback = { _ in }
        super.init()
    }
    
    convenience init(favoriteCallback: @escaping (_ state: TopAdsFeedPlusState) -> ()) {
        self.init()
        callback = favoriteCallback
    }
    
    convenience init(ads: [PromoResult]) {
        self.init()
        var theState = TopAdsFeedPlusState()
        theState.topAds = ads
        state = theState
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: TopAdsFeedPlusState?, size: CGSize) -> NodeType {
        guard let theTopAds = state?.topAds, theTopAds.count > 0 else {
            return Node<UIView> {
                _, _, _ in
            }
        }
        
        if theTopAds.count > 0 && (theTopAds[0].product != nil) {
            // product
            return Node<UIView>().add(
                child:
                    TopAdsFeedPlusProductComponentView().construct(state: state, size: size)
            )
        } else {
            // shop
            return Node<UIView>().add(
                child:
                    TopAdsFeedPlusShopComponentView(favoriteCallback: callback).construct(state: state, size: size)
            )
        }
    }
    
}

// MARK: Product

class TopAdsFeedPlusProductComponentView: ComponentView<TopAdsFeedPlusState> {
    
    override func construct(state: TopAdsFeedPlusState?, size: CGSize) -> NodeType {
        guard let state = state, let theTopAds = state.topAds, theTopAds.count > 0 else {
            return Node<UIView> {
                _, _, _ in
            }
        }
        
        let divider: CGFloat = 2
        
        let mainWrapper = Node<UIView> {
            view, layout, size in
            view.backgroundColor = .tpBackground()
            layout.width = size.width
        }
        
        func promotedInfoView() -> NodeType {
            
            let outerView = Node<UIView> {
                view, _, _ in
                view.backgroundColor = .tpLine()
            }
            
            let promotedInfoView = Node<UIView>(create: {
                
                let view = UIView()
                view.isUserInteractionEnabled = true
                view.backgroundColor = .white
                view.bk_(whenTapped: {
                    let alertController = TopAdsInfoActionSheet()
                    alertController.show()
                })
                
                return view
            }) {
                _, layout, _ in
                layout.alignItems = .center
                layout.flexDirection = .row
                layout.flexGrow = 1
                layout.height = 50
                layout.marginVertical = 1
                layout.marginHorizontal = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0
            }
            
            let promotedLabel = Node<UILabel> {
                view, layout, _ in
                view.textColor = UIColor.black.withAlphaComponent(0.38)
                view.text = "Promoted"
                view.font = UIFont.microTheme()
                layout.marginLeft = 10
                layout.marginRight = 4
            }
            
            let infoButtonImageView = Node<UIImageView> {
                view, layout, _ in
                view.contentMode = .center
                view.image = UIImage(named: "icon_information")
                view.backgroundColor = .clear
                layout.width = 16
                layout.height = 16
            }
            
            promotedInfoView.add(children: [
                promotedLabel,
                infoButtonImageView
            ])
            
            return outerView.add(child: promotedInfoView)
        }
        
        let adsWrapper = Node<UIView> {
            view, layout, size in
            view.backgroundColor = .clear
            layout.width = size.width
            layout.flexDirection = .row
            layout.flexWrap = .wrap
        }
        
        func adView(topAdsResult: PromoResult, index: Int) -> NodeType {
            
            let product = topAdsResult.viewModel!
            
            let outerAdView = Node<UIView> {
                view, layout, _ in
                view.backgroundColor = .tpLine()
                layout.width = size.width / divider
            }
            
            let adView = Node<UIView>(
                create: {
                    
                    let view = UIView()
                    view.backgroundColor = .white
                    view.bk_(whenTapped: {
                        if let url = URL(string: topAdsResult.applinks) {
                            AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "TopAds Product")
                            TopAdsService.sendClickImpression(clickURLString: topAdsResult.product_click_url)
                            TPRoutes.routeURL(url)
                        }
                    })
                    
                    return view
                }
            ) {
                _, layout, _ in
                
                layout.flexDirection = .column
                layout.flexGrow = 1
                layout.marginBottom = 1
                if (index + 1) % 2 != 0 {
                    layout.marginRight = 1
                }
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    layout.marginRight = 1
                    if (index + 1) % 2 != 0 {
                        layout.marginLeft = 1
                    }
                }
            }
            
            let productImageView = Node<TopAdsCustomImageView> {
                view, layout, _ in
                view.clipsToBounds = true
                view.cornerRadius = 2
                view.ad = topAdsResult
                view.setImageWith(URL(string: product.productThumbEcs), placeholderImage: UIImage(named: "grey-bg.png"))
                layout.aspectRatio = 1
                layout.margin = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5
            }
            
            let productNameWrapper = Node<UIView> {
                _, layout, _ in
                layout.height = 34
                layout.marginHorizontal = 8
                layout.paddingTop = 0
            }
            
            let productNameLabel = Node<UILabel> {
                view, _, _ in
                view.text = product.productName
                view.textColor = UIColor.tpPrimaryBlackText().withAlphaComponent(0.70)
                view.font = .smallThemeSemibold()
                view.numberOfLines = 2
            }
            
            productNameWrapper.add(child: productNameLabel)
            
            let productPriceLabel = Node<UILabel> {
                view, layout, _ in
                view.textColor = UIColor.tpOrange()
                view.font = .smallThemeSemibold()
                view.text = product.productPrice
                layout.marginHorizontal = 8
                layout.marginBottom = 9
                layout.height = 14
            }
            
            adView.add(children: [
                productImageView,
                productNameWrapper,
                productPriceLabel
            ])
            
            return outerAdView.add(child: adView)
        }
        
        var count = theTopAds.count
        if theTopAds.count > 4 {
            count = 4
        }
        
        adsWrapper.add(children: (0..<count).map { index in
            adView(topAdsResult: theTopAds[index], index: index)
        })
        
        let space = Node<UIView> {
            view, layout, _ in
            view.backgroundColor = .tpBackground()
            layout.marginTop = 0
            layout.height = 15
        }
        
        return mainWrapper.add(children: [
            promotedInfoView(),
            adsWrapper,
            space
        ])
    }
    
}

// MARK: Shop

class TopAdsFeedPlusShopComponentView: ComponentView<TopAdsFeedPlusState> {
    
    private var callback: (_ state: TopAdsFeedPlusState) -> ()
    
    override init() {
        callback = { _ in }
        super.init()
    }
    
    convenience init(favoriteCallback: @escaping (_ state: TopAdsFeedPlusState) -> ()) {
        self.init()
        callback = favoriteCallback
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func construct(state: TopAdsFeedPlusState?, size: CGSize) -> NodeType {
        guard let state = state, let theTopAds = state.topAds, theTopAds.count > 0 else {
            return NilNode()
        }
        
        let mainWrapper = Node<UIView> {
            view, layout, size in
            view.backgroundColor = .clear
            layout.width = size.width
        }
        
        func adView(ad: PromoResult) -> NodeType {
            let shop = ad.shop!
            let isShopFavorited = state.isDoneFavoriteShop || !shop.enable_fav
            let smallPhotoDivider: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 4.3 : 10 / 3
            
            let adView = Node<UIView>(
                create: {
                    
                    let view = UIView()
                    view.bk_(whenTapped: {
                        if let url = URL(string: theTopAds[0].applinks) {
                            AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "TopAds Shop")
                            TopAdsService.sendClickImpression(clickURLString: ad.shop_click_url)
                            TPRoutes.routeURL(url)
                        }
                    })
                    
                    return view
                }
            ) {
                view, layout, size in
                view.backgroundColor = UIColor.tpLine()
                layout.width = size.width
                layout.paddingVertical = 1
                layout.paddingHorizontal = UIDevice.current.userInterfaceIdiom == .pad ? 1 : 0
            }
            
            func promotedInfoView() -> NodeType {
                
                let promotedInfoView = Node<UIView>(create: {
                    
                    let view = UIView()
                    view.isUserInteractionEnabled = true
                    view.backgroundColor = .white
                    view.bk_(whenTapped: {
                        let alertController = TopAdsInfoActionSheet()
                        alertController.show()
                    })
                    
                    return view
                }) {
                    view, layout, _ in
                    view.backgroundColor = .white
                    layout.alignItems = .center
                    layout.flexDirection = .row
                    layout.flexGrow = 1
                    layout.paddingTop = UIDevice.current.userInterfaceIdiom == .pad ? 11 : 18
                    layout.paddingBottom = UIDevice.current.userInterfaceIdiom == .pad ? 11 : 10
                }
                
                let promotedLabel = Node<UILabel> {
                    view, layout, _ in
                    view.textColor = UIColor.black.withAlphaComponent(0.38)
                    view.text = "Promoted"
                    view.font = .microTheme()
                    layout.marginLeft = 10
                    layout.marginRight = 4
                }
                
                let infoButtonImageView = Node<UIImageView> {
                    view, layout, _ in
                    view.contentMode = .center
                    view.image = UIImage(named: "icon_info_grey")
                    view.backgroundColor = .clear
                    layout.width = 14
                    layout.height = 14
                }
                
                return promotedInfoView.add(children: [
                    promotedLabel,
                    infoButtonImageView
                ])
            }
            
            func requestFavorite() {
                callback(TopAdsFeedPlusState(topAds: theTopAds, isDoneFavoriteShop: isShopFavorited, isLoadingFavoriteShop: true, currentViewController: state.currentViewController))
                
                FavoriteShopRequest.requestActionButtonFavoriteShop(shop.shop_id, withAdKey: ad.ad_ref_key, onSuccess: { [weak self] _ in
                    AnalyticsManager.trackEventName("clickFeed", category: GA_EVENT_CATEGORY_FEED, action: GA_EVENT_ACTION_CLICK, label: "TopAds Favorite")
                    var messageString = CStringSuccessFavoriteShop
                    if isShopFavorited {
                        messageString = CStringSuccessUnFavoriteShop
                    }
                    
                    let eventName = !isShopFavorited ? "Seller_Added_To_Favourite" : "Seller_Removed_From_Favourite"
                    
                    AnalyticsManager.moEngageTrackEvent(
                        withName: eventName,
                        attributes: [
                            "shop_name": shop.name,
                            "shop_id": shop.shop_id,
                            "shop_location": shop.location,
                            "is_official_store": false
                        ]
                    )
                    
                    let stickyAlertView = StickyAlertView(successMessages: [messageString], delegate: state.currentViewController)
                    stickyAlertView?.show()
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateFavoriteShop"), object: nil)
                    self?.callback(TopAdsFeedPlusState(topAds: theTopAds, isDoneFavoriteShop: !isShopFavorited, isLoadingFavoriteShop: false, currentViewController: state.currentViewController))
                }, onFailure: { [weak self] _ in
                    self?.callback(TopAdsFeedPlusState(topAds: theTopAds, isDoneFavoriteShop: isShopFavorited, isLoadingFavoriteShop: false, currentViewController: state.currentViewController))
                })
            }
            
            let favButton = Node<UIButton> {
                view, layout, _ in
                
                view.bk_(whenTapped: {
                    requestFavorite()
                })
                view.backgroundColor = isShopFavorited ? UIColor.white : UIColor.tpGreen()
                view.borderColor = isShopFavorited ? UIColor.tpLine() : UIColor.tpGreen()
                view.borderWidth = 1
                view.cornerRadius = 3
                layout.height = 40
                layout.flexDirection = .row
                layout.alignItems = .center
                layout.justifyContent = .center
                if UIDevice.current.userInterfaceIdiom == .pad {
                    layout.width = 100
                    layout.marginRight = 10
                } else {
                    layout.flexGrow = 1
                    layout.margin = 7
                }
            }
            
            let favButtonLabel = Node<UILabel> {
                view, _, _ in
                view.text = isShopFavorited ? "Favorit" : "Favoritkan"
                view.textColor = isShopFavorited ? UIColor.black : UIColor.white
                view.font = UIDevice.current.userInterfaceIdiom == .pad ? UIFont.microThemeMedium() : UIFont.smallThemeMedium()
            }
            
            let plusIcon = Node<UIImageView> {
                view, layout, _ in
                view.contentMode = .scaleAspectFit
                view.image = isShopFavorited ? UIImage(named: "icon_check_favorited") : UIImage(named: "icon_follow_plus")
                var iconSize = UIDevice.current.userInterfaceIdiom == .pad ? 20 : 25
                if isShopFavorited {
                    layout.marginRight = 5
                    iconSize = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 15
                }
                layout.height = CGFloat(iconSize)
                layout.width = CGFloat(iconSize)
            }
            
            favButton.add(children: [
                plusIcon,
                favButtonLabel
            ])
            
            let loadingIndicatorWrapper = Node<UIView> {
                view, layout, _ in
                view.backgroundColor = .clear
                layout.height = 40
                layout.flexDirection = .row
                layout.alignItems = .center
                layout.justifyContent = .center
                if UIDevice.current.userInterfaceIdiom == .pad {
                    layout.width = 100
                    layout.marginRight = 10
                } else {
                    layout.flexGrow = 1
                    layout.margin = 7
                }
            }.add(
                child:
                    Node<UIActivityIndicatorView> {
                        view, _, _ in
                        view.color = .gray
                        view.startAnimating()
                    }
            )
            
            func shopInfoWrapper() -> NodeType {
                let shopInfoWrapper = Node<UIView> {
                    view, layout, _ in
                    view.backgroundColor = .white
                    layout.height = 52
                    layout.paddingTop = 0
                    layout.flexDirection = .row
                    layout.alignItems = .center
                }
                
                let shopImageView = Node<UIImageView> {
                    view, layout, _ in
                    view.borderWidth = 1
                    view.borderColor = UIColor.tpLine()
                    view.contentMode = .scaleAspectFit
                    view.setImageWith(URL(string: shop.image_shop.s_ecs))
                    view.cornerRadius = 3
                    view.clipsToBounds = true
                    layout.height = 52
                    layout.width = 52
                    layout.marginLeft = 10
                }
                
                func shopNameAndLocationWrapper() -> NodeType {
                    let shopNameAndLocationWrapper = Node<UIView> {
                        _, layout, _ in
                        layout.marginHorizontal = 8
                        layout.flexShrink = 1
                        layout.flexGrow = 1
                    }
                    
                    let locationLabel = Node<UILabel> {
                        view, layout, _ in
                        view.text = shop.location
                        view.textColor = UIColor.black.withAlphaComponent(0.38)
                        view.font = .microTheme()
                        layout.marginTop = 4.2
                        layout.height = 13
                    }
                    
                    return shopNameAndLocationWrapper.add(children: [
                        shopNameWrapper(),
                        locationLabel
                    ])
                }
                
                func shopNameWrapper() -> NodeType {
                    let shopNameWrapper = Node<UIView> {
                        _, layout, _ in
                        layout.flexDirection = .row
                        layout.height = 15
                        layout.flexShrink = 1
                        layout.alignContent = .stretch
                    }
                    
                    let goldBadgeView = Node<UIImageView> {
                        view, layout, _ in
                        view.image = UIImage(named: "Badges_gold_merchant")
                        layout.height = 15
                        layout.width = 15
                        layout.marginRight = 5
                    }
                    
                    let shopNameLabel = Node<UILabel> {
                        view, layout, _ in
                        view.text = NSAttributedString(fromHTML: shop.name).string
                        view.font = .largeThemeMedium()
                        layout.height = 15
                        layout.flexShrink = 1
                    }
                    
                    if shop.gold_shop {
                        shopNameWrapper.add(child: goldBadgeView)
                    }
                    
                    return shopNameWrapper.add(child: shopNameLabel)
                }
                
                shopInfoWrapper.add(children: [
                    shopImageView,
                    shopNameAndLocationWrapper()
                ])
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    if state.isLoadingFavoriteShop {
                        shopInfoWrapper.add(child: loadingIndicatorWrapper)
                    } else {
                        shopInfoWrapper.add(child: favButton)
                    }
                }
                
                return shopInfoWrapper
            }
            
            func photoWrapper() -> NodeType {
                let photoWrapper = Node<UIView> {
                    view, layout, _ in
                    view.backgroundColor = .white
                    layout.paddingTop = 15
                    layout.paddingLeft = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5
                    layout.paddingRight = UIDevice.current.userInterfaceIdiom == .pad ? 0 : 5
                    layout.paddingBottom = UIDevice.current.userInterfaceIdiom == .pad ? 10 : 8
                    layout.flexDirection = .rowReverse
                }
                
                let bigPhotoImageView = Node<TopAdsCustomImageView> {
                    view, layout, _ in
                    view.borderWidth = 1
                    view.borderColor = UIColor.tpLine()
                    view.ad = ad
                    if shop.productPhotoUrls.count > 0 {
                        view.setImageWith(URL(string: shop.productPhotoUrls[0] as! String), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
                    }
                    view.contentMode = .scaleAspectFill
                    view.clipsToBounds = true
                    view.cornerRadius = 2
                    layout.flexGrow = 1
                    layout.flexShrink = 1
                    layout.marginRight = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5
                    layout.height = (size.width / smallPhotoDivider) * 2 + (UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5)
                    
                }
                
                func smallPhotoImageView(index: Int) -> NodeType {
                    let smallPhotoImageView = Node<UIImageView> {
                        view, layout, _ in
                        if index <= shop.productPhotoUrls.count {
                            view.setImageWith(URL(string: shop.productPhotoUrls[index] as! String), placeholderImage: #imageLiteral(resourceName: "grey-bg"))
                        }
                        view.borderWidth = 1
                        view.borderColor = UIColor.tpLine()
                        view.contentMode = .scaleAspectFill
                        view.clipsToBounds = true
                        view.cornerRadius = 2
                        layout.width = size.width / smallPhotoDivider
                        layout.height = layout.width
                        layout.marginRight = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 0
                    }
                    
                    return smallPhotoImageView
                }
                
                func smallPhotoWrapper() -> NodeType {
                    let smallPhotoWrapper = Node<UIView> {
                        _, layout, _ in
                        layout.flexDirection = .column
                        layout.justifyContent = .spaceBetween
                        layout.height = (size.width / smallPhotoDivider) * 2 + (UIDevice.current.userInterfaceIdiom == .pad ? 8 : 5)
                        layout.flexWrap = .wrap
                    }
                    
                    let smallPhotoCount = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
                    
                    return smallPhotoWrapper.add(children: (1..<smallPhotoCount + 1).map { index in
                        smallPhotoImageView(index: index)
                    })
                }
                
                return photoWrapper.add(children: [
                    smallPhotoWrapper(),
                    bigPhotoImageView
                ])
            }
            
            let favoriteButtonWrapper = Node<UIView> {
                view, layout, _ in
                view.backgroundColor = .white
                layout.marginTop = 1
                layout.flexDirection = .row
                layout.height = 54
                layout.alignItems = .center
            }
            
            adView.add(children: [
                promotedInfoView(),
                shopInfoWrapper(),
                photoWrapper()
            ])
            
            if UIDevice.current.userInterfaceIdiom != .pad {
                if state.isLoadingFavoriteShop {
                    adView.add(child: favoriteButtonWrapper.add(child: loadingIndicatorWrapper))
                } else {
                    adView.add(child: favoriteButtonWrapper.add(child: favButton))
                }
            }
            
            return adView
            
        }
        
        func space() -> NodeType {
            let space = Node<UIView> {
                view, layout, _ in
                view.backgroundColor = .tpBackground()
                layout.marginTop = 0
                layout.height = 15
            }
            return space
        }
        
        for ad in theTopAds {
            mainWrapper.add(children: [
                adView(ad: ad),
                space()
            ])
        }
        
        return mainWrapper
    }
    
}
