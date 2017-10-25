//
//  ProductDetailViewComponent.swift
//  Tokopedia
//
//  Created by Setiady Wiguna on 4/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Render
import ReSwift
import RxSwift
import QuartzCore
import youtube_ios_player_helper
import EZYGradientView_ObjC
import UIAlertController_Blocks
import TTTAttributedLabel
import Lottie
import SwiftOverlays

enum ProductDetailActivity {
    case initial
    case normal
    case inactive
    case seller
    case sellerInactive
    case noResult
    case replacement
}

enum ProductDetailAction: Action {
    case begin([String: String])
    case receive(ProductUnbox, ProductDetailActivity?)
    case tapVideo(ProductVideo?, Bool)
    case updateActivity(ProductDetailActivity)
    case updateWishlist(Bool)
    case updateFavorite(Bool, Bool)
}

struct ProductDetailReducer: Reducer {
    
    func handleAction(action: Action, state: ProductDetailState?) -> ProductDetailState {
        guard let state = state else {
            fatalError("state must be set by default")
        }
        
        let action = action as! ProductDetailAction
        
        switch action {
        case let .begin(data):
            return state.begin(data: data)
            
        case let .receive(product, activity):
            return state.receive(productDetail: product, activity: activity)
            
        case let .tapVideo(video, isPlay):
            return state.tapVideo(productVideo: video, isPlaying: isPlay)
            
        case let .updateActivity(activity):
            return state.updateActivity(activity: activity)
            
        case let .updateWishlist(isWishlist):
            return state.updateWishlist(isWishlist: isWishlist)
            
        case let .updateFavorite(isFavorite, isLoading):
            return state.updateFavorite(isFavorite: isFavorite, isLoading: isLoading)
        }
    }
}

struct ProductDetailState: Render.StateType, ReSwift.StateType {
    var currentPage: Int? = 0
    
    var productDetail: ProductUnbox?
    var initialData: [String: String]?
    var nowPlayingVideo: ProductVideo?
    var isVideoLoading: Bool = false
    var isFavoriteLoading: Bool = false
    var isWishlist: Bool = false
    var productDetailActivity: ProductDetailActivity = .initial
    
    func begin(data: [String: String]) -> ProductDetailState {
        var newState = self
        newState.initialData = data
        
        return newState
    }
    
    func receive(productDetail: ProductUnbox, activity: ProductDetailActivity?) -> ProductDetailState {
        var newState = self
        newState.productDetail = productDetail
        if let activity = activity {
            newState.productDetailActivity = activity
        }
        
        return newState
    }
    
    func tapVideo(productVideo: ProductVideo?, isPlaying: Bool) -> ProductDetailState {
        var newState = self
        newState.nowPlayingVideo = productVideo
        newState.isVideoLoading = isPlaying
        
        return newState
    }
    
    func updateActivity(activity: ProductDetailActivity) -> ProductDetailState {
        var newState = self
        newState.productDetailActivity = activity
        
        return newState
    }
    
    func updateWishlist(isWishlist: Bool) -> ProductDetailState {
        var newState = self
        newState.isWishlist = isWishlist
        
        return newState
    }
    
    func updateFavorite(isFavorite: Bool, isLoading: Bool) -> ProductDetailState {
        var newState = self
        if !isLoading {
            newState.productDetail?.isShopFavorited = isFavorite
        }
        
        newState.isFavoriteLoading = isLoading
        
        return newState
    }
}

// MARK: - Main View Component

class ProductDetailViewComponent: ComponentView<ProductDetailState>, StoreSubscriber, UIScrollViewDelegate, YTPlayerViewDelegate {
    
    fileprivate var disposeBag = DisposeBag()
    fileprivate let store: Store<ProductDetailState>
    fileprivate let viewController: ProductDetailViewController
    fileprivate var scrollView = UIScrollView()
    fileprivate var fullNavigationView = UIView()
    fileprivate var navigationView = UIView()
    fileprivate var wishlistNotificationView = UIView()
    fileprivate var unwishlistNotificationView = UIView()
    
    fileprivate var youtubePlayerBackgroundView = UIView()
    fileprivate var youtubePlayerView: YTPlayerView!
    
    final let buyViewHeight: CGFloat = 52.0
    
    func newState(state: ProductDetailState) {
        self.state = state
        self.render(in: self.bounds.size)
    }
    
    init(store: Store<ProductDetailState>, viewController: ProductDetailViewController) {
        self.store = store
        self.viewController = viewController
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.viewController.navigationController?.navigationBar.shadowImage = nil
        
        // TODO: change hardcoded 264 height, with scrollview's height later to get proper animation while scrolling
        
        if self.scrollView.contentOffset.y < 20 {
            self.navigationView.isHidden = false
        } else {
            self.navigationView.isHidden = true
        }
        
        self.fullNavigationView.alpha = 0 + (self.scrollView.contentOffset.y / 264)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
    }
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.youtubePlayerView.playVideo()
    }
    
    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        switch state {
        case .ended, .paused, .unknown:
            self.youtubePlayerBackgroundView.isHidden = true
            self.youtubePlayerView.isHidden = true
            self.store.dispatch(ProductDetailAction.tapVideo(nil, false))
        default:
            break
        }
    }
    
    func playerView(_ playerView: YTPlayerView, receivedError error: YTPlayerError) {
        self.store.dispatch(ProductDetailAction.tapVideo(nil, false))
    }
    
    override func construct(state: ProductDetailState?, size: CGSize = CGSize.undefined) -> NodeType {
        
        func container(state: ProductDetailState?, size: CGSize) -> NodeType {
            return Node<UIView>(identifier: String(describing: ProductDetailViewComponent.self)) { view, layout, size in
                layout.width = size.width
                layout.height = size.height
                layout.flexDirection = .column
                view.backgroundColor = .tpBackground()
                view.isUserInteractionEnabled = true
            }
        }
        
        func actionButton(state: ProductDetailState?, size: CGSize) -> NodeType {
            func promoteButton() -> NodeType {
                return Node<UIButton>(identifier: "Promote-Button") { view, layout, size in
                    layout.width = size.width
                    layout.height = self.buyViewHeight
                    view.backgroundColor = .tpGreen()
                    view.titleLabel?.font = .title2ThemeSemibold()
                    view.setTitle("Promosi", for: .normal)
                    view.addTarget(self, action: #selector(self.promoteButtonDidTap(_:)), for: .touchUpInside)
                }
            }
            
            func preorderButton() -> NodeType {
                return Node<UIButton>(identifier: "Preorder-Button") { view, layout, size in
                    layout.width = size.width
                    layout.height = self.buyViewHeight
                    view.backgroundColor = .tpOrange()
                    view.titleLabel?.font = .title2ThemeSemibold()
                    view.setTitle("Preorder", for: .normal)
                    view.addTarget(self, action: #selector(self.buyButtonDidTap(_:)), for: .touchUpInside)
                }
            }
            
            func buyButton() -> NodeType {
                return Node<UIButton>(identifier: "Buy-Button") { view, layout, size in
                    layout.width = size.width
                    layout.height = self.buyViewHeight
                    view.backgroundColor = .tpOrange()
                    view.titleLabel?.font = .title2ThemeSemibold()
                    view.setTitle("Beli", for: .normal)
                    view.addTarget(self, action: #selector(self.buyButtonDidTap(_:)), for: .touchUpInside)
                }
            }
            
            guard let productDetailActivity = self.state?.productDetailActivity,
                productDetailActivity == .normal || productDetailActivity == .seller else {
                return NilNode()
            }
            
            guard let productStatus = self.state?.productDetail?.info.status,
                productStatus == .active else {
                return NilNode()
            }
            
            if productDetailActivity == .seller {
                return promoteButton()
            } else if let preorder = self.state?.productDetail?.preorderDetail,
                preorder.isPreorder {
                return preorderButton()
            }
            return buyButton()
        }
        
        func fullNavigationView(state: ProductDetailState?, size: CGSize) -> NodeType {
            return Node<UIView>(identifier: "Full-Navigation-View") { view, layout, size in
                
                view.backgroundColor = .white
                if self.scrollView.contentOffset.y > 264 {
                    view.alpha = 1.0
                    
                } else if self.scrollView.contentOffset.y == 0 {
                    view.alpha = 0.0
                }
                self.fullNavigationView = view
                self.accessibilityLabel = "productDetailView"
                layout.position = .absolute
                layout.top = 0
                layout.width = size.width
                layout.height = 64
                layout.justifyContent = .center
                layout.flexDirection = .row
                
            }.add(children: [
                Node<UIButton>() { view, layout, _ in
                    layout.width = 40
                    layout.height = 40
                    layout.marginLeft = 7
                    layout.marginTop = 21
                    
                    let backButtonImage = UIImage(named: "icon_arrow_white")?.withRenderingMode(.alwaysTemplate)
                    view.setImage(backButtonImage, for: .normal)
                    view.addTarget(self, action: #selector(self.backButtonDidTap(_:)), for: .touchUpInside)
                    view.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                    view.imageView?.tintColor = .black
                },
                Node { _, layout, _ in
                    layout.justifyContent = .spaceBetween
                    layout.flexGrow = 1
                },
                Node<UIButton>() { view, layout, _ in
                    layout.width = 40
                    layout.height = 40
                    layout.marginTop = 20
                    
                    let shareButtonImage = UIImage(named: "icon_share_white")?.withRenderingMode(.alwaysTemplate)
                    view.setImage(shareButtonImage, for: .normal)
                    view.addTarget(self, action: #selector(self.shareButtonDidTap(_:)), for: .touchUpInside)
                    view.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                    view.imageView?.tintColor = .black
                },
                cartButton(isFullNavigation: true),
                Node<UIButton>() { view, layout, _ in
                    layout.width = 40
                    layout.height = 40
                    layout.marginRight = 16
                    layout.marginTop = 20
                    
                    let moreButtonImage = UIImage(named: "icon_more_plain")?.withRenderingMode(.alwaysTemplate)
                    view.setImage(moreButtonImage, for: .normal)
                    view.addTarget(self, action: #selector(self.moreButtonDidTap(_:)), for: .touchUpInside)
                    view.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                    view.imageView?.tintColor = .black
                },
                Node<UIView>() { view, layout, size in
                    layout.position = .absolute
                    layout.top = 63
                    layout.height = 1
                    layout.width = size.width
                    view.backgroundColor = .tpLine()
                }
            ])
        }
        
        func cartButton(isFullNavigation: Bool) -> NodeType {
            return Node<UIButton>() { view, layout, _ in
                layout.width = 40
                layout.height = 40
                layout.marginLeft = 8
                layout.marginRight = 8
                layout.marginTop = 20
                
                let cartButtonImage = UIImage(named: "icon_cart_white")?.withRenderingMode(.alwaysTemplate)
                view.setImage(cartButtonImage, for: .normal)
                view.addTarget(self, action: #selector(self.cartButtonDidTap(_:)), for: .touchUpInside)
                view.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                view.imageView?.tintColor = isFullNavigation ? .black : .white
            }.add(child: badgeView())
        }
        
        func badgeView() -> NodeType {
            guard let totalCart = UserDefaults.standard.string(forKey: "total_cart"),
                totalCart != "0" else {
                return NilNode()
            }
            
            return Node<UILabel>() { view, layout, _ in
                layout.height = 17
                layout.marginLeft = 24
                layout.marginTop = 0
                layout.position = .absolute
                
                view.font = .microTheme()
                view.backgroundColor = .red
                view.textColor = .white
                view.textAlignment = .center
                view.layer.cornerRadius = 9
                view.clipsToBounds = true
                view.text = totalCart
                let badgeSize = view.font.sizeOfString(string: view.text!, constrainedToWidth: 100)
                layout.width = badgeSize.width + 10
            }
        }
        
        func lastUpdateInfoView() -> NodeType {
            guard let productDetail = self.state?.productDetail else {
                return NilNode()
            }
            
            return Node<UIView>() { view, layout, size in
                layout.width = size.width
                layout.height = self.buyViewHeight
                layout.justifyContent = .center
                view.backgroundColor = .tpBackground()
            }.add(children: [
                Node<UILabel>() { view, layout, _ in
                    layout.alignSelf = .center
                    view.font = .microTheme()
                    view.textColor = .tpDisabledBlackText()
                    view.text = "Perubahan Terakhir : \(productDetail.lastUpdated)"
                }
            ])
        }
        
        func navigationView() -> NodeType {
            return Node<EZYGradientView>() { view, layout, size in
                
                view.firstColor = .clear
                if let initialData = self.state?.initialData,
                    let imageURL = initialData["imageURL"],
                    imageURL != "" {
                    view.firstColor = .lightGray
                }
                
                if let _ = self.state?.productDetail {
                    view.firstColor = .lightGray
                }
                
                view.secondColor = .clear
                view.colorRatio = 0.5
                view.fadeIntensity = 0.9
                view.isBlur = false
                self.navigationView = view
                
                layout.position = .absolute
                layout.top = 0
                layout.width = size.width
                layout.height = 64
                layout.justifyContent = .center
                layout.flexDirection = .row
                
            }.add(children: [
                Node<UIButton>() { view, layout, _ in
                    layout.width = 40
                    layout.height = 40
                    layout.marginLeft = 7
                    layout.marginTop = 21
                    view.setImage(UIImage(named: "icon_arrow_white"), for: .normal)
                    view.addTarget(self, action: #selector(self.backButtonDidTap(_:)), for: .touchUpInside)
                    view.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                    view.imageView?.tintColor = .white
                    view.accessibilityLabel = "backButton"
                },
                Node { _, layout, _ in
                    layout.justifyContent = .spaceBetween
                    layout.flexGrow = 1
                },
                Node<UIButton>() { view, layout, _ in
                    layout.width = 40
                    layout.height = 40
                    layout.marginTop = 20
                    view.setImage(UIImage(named: "icon_share_white"), for: .normal)
                    view.addTarget(self, action: #selector(self.shareButtonDidTap(_:)), for: .touchUpInside)
                    view.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                    view.imageView?.tintColor = .white
                },
                cartButton(isFullNavigation: false),
                Node<UIButton>() { view, layout, _ in
                    layout.width = 40
                    layout.height = 40
                    layout.marginRight = 16
                    layout.marginTop = 20
                    view.setImage(UIImage(named: "icon_more_plain"), for: .normal)
                    view.addTarget(self, action: #selector(self.moreButtonDidTap(_:)), for: .touchUpInside)
                    view.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
                    view.imageView?.tintColor = .white
                }
            ])
        }
        
        func loadingScreenView() -> NodeType {
            return Node<UIView>() { view, layout, size in
                layout.width = size.width
                layout.height = size.height
                layout.justifyContent = .center
                view.backgroundColor = .tpBackground()
            }.add(children: [
                Node<UIActivityIndicatorView>() { view, layout, _ in
                    layout.alignSelf = .center
                    view.activityIndicatorViewStyle = .gray
                    view.startAnimating()
                }
            ])
        }
        
        func noResultView(canAskSeller: Bool) -> NodeType {
            return Node<NoResultReusableView>() { view, layout, size in
                layout.marginTop = 64
                layout.width = size.width
                layout.height = size.height
                view.generateAllElements("icon_no_data_grey.png",
                                         title: "Produk tidak ditemukan",
                                         desc: "",
                                         btnTitle: "Hubungi Penjual")
                if !canAskSeller {
                    view.hideButton(true)
                } else if let productDetail = self.state?.productDetail {
                    view.delegate = self.viewController
                    view.onButtonTap = { [unowned self] _ in
                        let vc = SendMessageViewController()
                        vc.data = [
                            "shop_id": productDetail.shop.id,
                            "shop_name": productDetail.shop.name
                        ]
                        vc.subject = "Konfirmasi produk tidak ditemukan"
                        vc.source = "product"
                        vc.display(from: self.viewController)
                    }
                }
            }
        }
        
        func youtubePlayerNodeView(state: ProductDetailState?, size: CGSize) -> NodeType {
            guard let state = state else { return NilNode() }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                return Node<YTPlayerView>(identifier: "Youtube-Player-View") { view, layout, size in
                    layout.width = size.width
                    layout.height = size.height
                    layout.position = .absolute
                    layout.top = 0
                    layout.left = 0
                    
                    view.isHidden = !state.isVideoLoading
                    view.webView?.allowsInlineMediaPlayback = false
                    view.delegate = self
                    view.backgroundColor = .black
                    self.youtubePlayerView = view
                }
            }
            
            return Node<UIView>() { view, layout, size in
                layout.width = size.width
                layout.height = size.height
                layout.position = .absolute
                layout.top = 0
                layout.right = 0
                view.backgroundColor = .black
                view.isHidden = !state.isVideoLoading
                
                self.youtubePlayerBackgroundView = view
            }.add(children: [
                Node<UIButton>(identifier: "Youtube-Done-Button") { view, layout, _ in
                    layout.width = 84
                    layout.height = 32
                    layout.position = .absolute
                    layout.top = 34
                    layout.right = 24
                    
                    view.layer.cornerRadius = 4
                    view.layer.masksToBounds = true
                    view.layer.borderWidth = 1
                    view.layer.borderColor = UIColor.white.cgColor
                    view.titleLabel?.font = .microTheme()
                    view.setTitle("Done", for: .normal)
                    view.setTitleColor(.white, for: .normal)
                    _ = view.rx.tap.subscribe(onNext: { [unowned self] _ in
                        self.youtubePlayerBackgroundView.isHidden = true
                        self.youtubePlayerView.isHidden = true
                        self.youtubePlayerView.stopVideo()
                        self.store.dispatch(ProductDetailAction.tapVideo(nil, false))
                    })
                },
                Node<YTPlayerView>(identifier: "Youtube-Player-View") { view, layout, size in
                    layout.width = size.width
                    layout.height = size.height - 70
                    layout.position = .absolute
                    layout.top = 70
                    
                    view.isHidden = !state.isVideoLoading
                    view.webView?.allowsInlineMediaPlayback = false
                    view.delegate = self
                    view.backgroundColor = .black
                    self.youtubePlayerView = view
                }
            ])
        }
        
        func moengageAttributes(product: ProductUnbox) -> [String: Any] {
            var attributes = [
                "product_name": product.name,
                "product_url": product.url,
                "product_id": product.id,
                "product_price": product.info.priceUnformatted,
                "shop_id": product.shop.id,
                "is_official_store": product.shop.isOfficial,
                "shop_name": product.shop.name
            ] as [String: Any]
            
            if product.images.count > 0 {
                attributes["product_image_url"] = product.images[0].normalURL
            }
            
            if product.categories.count > 0 {
                attributes["category"] = product.categories[0].name
                attributes["category_id"] = product.categories[0].id
            }
            
            if product.categories.count > 1 {
                attributes["subcategory"] = product.categories[1].name
                attributes["subcategory_id"] = product.categories[1].id
            }
            
            return attributes
        }
        
        func contentScrollView(state: ProductDetailState?, size: CGSize) -> NodeType {
            guard let state = state else { return NilNode() }
            
            return Node<UIScrollView>(identifier: "Content-Scroll-View") { view, layout, size in
                layout.width = size.width
                layout.height = size.height
                if state.productDetailActivity == .normal || state.productDetailActivity == .seller {
                    layout.height = size.height - self.buyViewHeight
                }
                
                if let productStatus = self.state?.productDetail?.info.status,
                    productStatus != .active {
                    layout.height = size.height
                }
                
                view.backgroundColor = UIColor.tpBackground()
                view.showsVerticalScrollIndicator = true
                view.bounces = true
                view.delegate = self
                self.scrollView = view
            }.add(children: [
                ProductHeaderNode(identifier: "header",
                                  state: state,
                                  didTapReview: { [unowned self] productDetail in
                                      AnalyticsManager.trackEventName("clickPDP", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Review")
                                      
                                      AnalyticsManager.moEngageTrackEvent(withName: "Clicked_Ulasan_Pdp", attributes: moengageAttributes(product: productDetail))
                                      
                                      let vc = ProductReputationViewController()
                                      vc.strShopDomain = productDetail.shop.domain
                                      vc.strProductID = productDetail.id
                                      
                                      self.viewController.navigationController?.pushViewController(vc, animated: true)
                                  },
                                  didTapDiscussion: { [unowned self] productDetail in
                                      AnalyticsManager.trackEventName("clickPDP", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Talk")
                                      
                                      AnalyticsManager.moEngageTrackEvent(withName: "Clicked_Diskusi_Pdp", attributes: moengageAttributes(product: productDetail))
                                      
                                      let vc = ProductTalkViewController()
                                      let images = productDetail.images
                                      let dataTalk: [AnyHashable: Any] =
                                          [
                                              kTKPDDETAILPRODUCT_APIIMAGESRCKEY: (images.count > 0) ? images[0].normalURL : "",
                                              kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY: productDetail.soldCount,
                                              kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY: productDetail.viewCount,
                                              API_PRODUCT_NAME_KEY: productDetail.name,
                                              API_PRODUCT_PRICE_KEY: productDetail.info.price,
                                              "talk_shop_id": productDetail.shop.id,
                                              "talk_product_status": productDetail.info.status.rawValue,
                                              "product_id": productDetail.id,
                                              "auth_key": UserAuthentificationManager().getUserLoginData() ?? NSNull(),
                                              "talk_product_image": (images.count > 0) ? images[0].normalURL : ""
                                          ]
                                      
                                      vc.data = dataTalk
                                      self.viewController.navigationController?.pushViewController(vc, animated: true)
                                      
                                  },
                                  didTapCourier: { [unowned self] _ in
                                      guard let shipments = self.state?.productDetail?.shipments else {
                                          return
                                      }
                                      
                                      let vc = ProductShipmentViewController(shipments: shipments)
                                      self.viewController.navigationController?.pushViewController(vc, animated: true)
                                  },
                                  didTapWishlist: { [unowned self] isWishlist in
                                      if isWishlist {
                                          AnalyticsManager.trackEventName("clickWishlist", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Add to Wishlist")
                                      }
                                      self.updateWishlist(isWishlist)
                                  },
                                  updateWishlistState: { [unowned self] isWishlist in
                                      self.store.dispatch(ProductDetailAction.updateWishlist(isWishlist))
                                  },
                                  didTapProductEdit: { [unowned self] productDetail in
                                      let vc = ProductAddEditViewController()
                                      vc.forceProductEditType()
                                      vc.productID = productDetail.id
                                      
                                      let nav = UINavigationController(rootViewController: vc)
                                      self.viewController.navigationController?.present(nav, animated: true, completion: nil)
                                  },
                                  didTapProductImage: { [unowned self] index in
                                      let vc = GalleryViewController(photoSource: self.viewController, withStarting: Int32(index), usingNetwork: true, canDownload: true)
                                      
                                      self.viewController.navigationController?.present(vc!, animated: true, completion: nil)
                }),
                navigationView(),
                ProductPriceNode(identifier: "price",
                                 state: state,
                                 didTapWholesale: { [unowned self] wholesales in
                                     let vc = ProductWholesaleViewController(wholesales: wholesales)
                                     self.viewController.navigationController?.pushViewController(vc, animated: true)
                }),
                ProductInfoNode(identifier: "info",
                                state: state,
                                didTapCategory: { [unowned self] category in
                                    let navigateVC = NavigateViewController()
                                    navigateVC.navigateToIntermediaryCategory(from: self.viewController, withCategoryId: category.id, categoryName: "", isIntermediary: true)
                                },
                                didTapStorefront: { [unowned self] productDetail in
                                    let vc = ShopViewController()
                                    var data: [AnyHashable: Any] = [
                                        kTKPDDETAIL_APISHOPIDKEY: productDetail.shop.id,
                                        "product_etalase_name": productDetail.info.etalaseName,
                                        "product_etalase_id": productDetail.info.etalaseId
                                    ]
                                    if let authData = UserAuthentificationManager().getUserLoginData() {
                                        data = [
                                            kTKPDDETAIL_APISHOPIDKEY: productDetail.shop.id,
                                            kTKPD_AUTHKEY: authData,
                                            "product_etalase_name": productDetail.info.etalaseName,
                                            "product_etalase_id": productDetail.info.etalaseId
                                        ]
                                    }
                                    if productDetail.info.etalaseId != "" {
                                        let etalase = EtalaseList()
                                        etalase.etalase_id = productDetail.info.etalaseId
                                        etalase.etalase_name = productDetail.info.etalaseName
                                        vc.initialEtalase = etalase
                                    }
                                    vc.data = data
                                    self.viewController.navigationController?.pushViewController(vc, animated: true)
                                },
                                didTapReturnInfo: { [unowned self] url in
                                    let vc = WebViewController()
                                    vc.strTitle = "Keterangan Pengembalian Barang"
                                    vc.strURL = url
                                    self.viewController.navigationController?.pushViewController(vc, animated: true)
                }),
                ProductDescriptionNode(identifier: "description",
                                       viewController: self.viewController,
                                       state: state,
                                       didTapDescription: { [unowned self] productInfo in
                                           AnalyticsManager.trackEventName("clickPDP", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Product Description")
                                           let vc = ProductDescriptionViewController(productInfo: productInfo)
                                           self.viewController.navigationController?.pushViewController(vc, animated: true)
                                       },
                                       didTapVideo: { [unowned self] video in
                                           let playerVars = [
                                               "origin": "https://www.tokopedia.com",
                                               "playsinline": "0"
                                           ]
                                           
                                           if !state.isVideoLoading {
                                               self.store.dispatch(ProductDetailAction.tapVideo(video, true))
                                               self.youtubePlayerBackgroundView.isHidden = false
                                               self.youtubePlayerView.isHidden = false
                                               self.youtubePlayerView.load(withVideoId: video.url, playerVars: playerVars)
                                           }
                                       },
                                       didLongPressDescription: { view in
                                           view.becomeFirstResponder()
                                           let menuController = UIMenuController.shared
                                           menuController.setTargetRect(view.frame, in: view)
                                           menuController.setMenuVisible(true, animated: true)
                }),
                ProductSellerInfoNode(identifier: "seller",
                                      state: state,
                                      didTapShop: { [unowned self] shop in
                                          let vc = ShopViewController()
                                          var data: [AnyHashable: Any] = [
                                              kTKPDDETAIL_APISHOPIDKEY: shop.id,
                                              kTKPDDETAIL_APISHOPNAMEKEY: shop.name
                                          ]
                                          if let authData = UserAuthentificationManager().getUserLoginData() {
                                              data = [
                                                  kTKPDDETAIL_APISHOPIDKEY: shop.id,
                                                  kTKPDDETAIL_APISHOPNAMEKEY: shop.name,
                                                  kTKPD_AUTHKEY: authData
                                              ]
                                          }
                                          vc.data = data
                                          self.viewController.navigationController?.pushViewController(vc, animated: true)
                                          
                                      },
                                      didTapFavorite: { [unowned self] isFavorite in
                                          self.updateFavorite(isFavorite)
                                      },
                                      didTapMessage: { [unowned self] in
                                          self.sendMessage()
                                      },
                                      didTapReputation: { [unowned self] view, reputationScore in
                                          
                                          let popView = CMPopTipView(message: "\(reputationScore) Poin")
                                          popView?.backgroundColor = .black
                                          popView?.textColor = .white
                                          popView?.textFont = UIFont.smallTheme()
                                          popView?.dismissTapAnywhere = true
                                          popView?.leftPopUp = true
                                          popView?.preferredPointDirection = .up
                                          popView?.presentPointing(at: view, in: self.viewController.view, animated: true)
                }),
                ProductDetailReviewNode(identifier: "review",
                                        state: state,
                                        didTapAllReview: { [unowned self] productDetail in
                                            AnalyticsManager.trackEventName("Click", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "All Reviews")
                                            
                                            AnalyticsManager.moEngageTrackEvent(withName: "Clicked_Ulasan_Pdp", attributes: moengageAttributes(product: productDetail))
                                            
                                            let vc = ProductReputationViewController()
                                            vc.strShopDomain = productDetail.shop.domain
                                            vc.strProductID = productDetail.id
                                            
                                            self.viewController.navigationController?.pushViewController(vc, animated: true)
                }),
                ProductDetailDiscussionNode(identifier: "discussion",
                                            state: state,
                                            didTapAllDiscussion: { [unowned self] productDetail in
                                                AnalyticsManager.trackEventName("Click", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "All Discussions")
                                                
                                                AnalyticsManager.moEngageTrackEvent(withName: "Clicked_Diskusi_Pdp", attributes: moengageAttributes(product: productDetail))
                                                
                                                let vc = ProductTalkViewController()
                                                let images = productDetail.images
                                                let dataTalk: [AnyHashable: Any] =
                                                    [
                                                        kTKPDDETAILPRODUCT_APIIMAGESRCKEY: (images.count > 0) ? images[0].normalURL : "",
                                                        kTKPDDETAILPRODUCT_APIPRODUCTSOLDKEY: productDetail.soldCount,
                                                        kTKPDDETAILPRODUCT_APIPRODUCTVIEWKEY: productDetail.viewCount,
                                                        API_PRODUCT_NAME_KEY: productDetail.name,
                                                        API_PRODUCT_PRICE_KEY: productDetail.info.price,
                                                        "talk_shop_id": productDetail.shop.id,
                                                        "talk_product_status": productDetail.info.status.rawValue,
                                                        "product_id": productDetail.id,
                                                        "auth_key": UserAuthentificationManager().getUserLoginData() ?? NSNull(),
                                                        "talk_product_image": (images.count > 0) ? images[0].normalURL : ""
                                                    ]
                                                
                                                vc.data = dataTalk
                                                self.viewController.navigationController?.pushViewController(vc, animated: true)
                                                
                }),
                ProductRecommendationNode(identifier: "recommendation",
                                          state: state,
                                          didTapProduct: { [unowned self] productID in
                                              let vc = ProductDetailViewController(productID: productID)
                                              self.viewController.navigationController?.pushViewController(vc, animated: true)
                                              
                }),
                lastUpdateInfoView()
            ])
        }
        
        if state?.productDetailActivity == .noResult {
            var canAskSeller = false
            if let _ = state?.productDetail?.shop {
                canAskSeller = true
            }
            return container(state: state, size: size).add(children: [
                noResultView(canAskSeller: canAskSeller),
                navigationView()
            ])
        }
        return container(state: state, size: size).add(children: [
            contentScrollView(state: state, size: size),
            fullNavigationView(state: state, size: size),
            actionButton(state: state, size: size),
            youtubePlayerNodeView(state: state, size: size)
        ])
    }
    
    override func didRender() {
        super.didRender()
        
        var maxHeight: CGFloat = 0
        
        for child in self.scrollView.subviews {
            maxHeight = max(maxHeight, child.frame.maxY)
        }
        
        self.scrollView.contentSize.height = maxHeight
    }
    
    @objc
    func backButtonDidTap(_ sender: Any) {
        self.viewController.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func shareButtonDidTap(_ sender: Any) {
        guard let productDetail = self.state?.productDetail,
            productDetail.url != "" else {
            return
        }
        let anchor = sender as? UIView
        if let viewController = UIApplication.topViewController() {
            ReferralManager().share(object: productDetail, from: viewController, anchor: anchor)
        }
        let eventLabel = "Share - \(productDetail.name)"
        AnalyticsManager.trackEventName("clickPDP", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: eventLabel)
    }
    
    @objc
    func cartButtonDidTap(_ sender: Any) {
        guard let productDetail = state?.productDetail else {
            return
        }
        
        let userAuthManager = UserAuthentificationManager()
        if !userAuthManager.isLogin {
            AuthenticationService.shared.ensureLoggedInFromViewController(self.viewController) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_PRODUCT_POST_NOTIFICATION_NAME), object: productDetail.id)
            }
            return
        }
        
        let navigateViewController = NavigateViewController()
        navigateViewController.navigateToCart(from: self.viewController)
    }
    
    @objc
    func moreButtonDidTap(_ sender: Any) {
        guard var productDetail = state?.productDetail else {
            return
        }
        
        if state?.productDetailActivity == .seller || state?.productDetailActivity == .sellerInactive {
            var title = "Apakah stok produk ini tersedia?"
            if productDetail.info.status == .active {
                title = "Apakah stok produk ini kosong?"
            }
            
            UIAlertController.showAlert(in: self.viewController,
                                        withTitle: title,
                                        message: nil,
                                        cancelButtonTitle: "Tidak",
                                        destructiveButtonTitle: nil,
                                        otherButtonTitles: ["Ya"],
                                        tap: { controller, _, buttonIndex in
                                            if buttonIndex != controller.firstOtherButtonIndex {
                                                return
                                            }
                                            
                                            if productDetail.info.status == .active {
                                                let provider = NetworkProvider<V4Target>()
                                                provider.request(.moveToWarehouse(withProductId: productDetail.id))
                                                    .subscribe(onNext: { _ in
                                                        productDetail.info.status = .warehouse
                                                        self.store.dispatch(ProductDetailAction.receive(productDetail, .sellerInactive))
                                                    },
                                                               onError: { _ in
                                                        print("error")
                                                    })
                                                    .disposed(by: self.rx_disposeBag)
                                            } else {
                                                let selectedEtalase = EtalaseList()
                                                selectedEtalase.etalase_id = productDetail.info.etalaseId
                                                selectedEtalase.etalase_name = productDetail.info.etalaseName
                                                
                                                let vc = EtalaseViewController()
                                                vc.delegate = self.viewController
                                                vc.shopId = productDetail.shop.id
                                                vc.isEditable = false
                                                vc.showOtherEtalase = false
                                                vc.enableAddEtalase = true
                                                vc.initialSelectedEtalase = selectedEtalase
                                                self.viewController.navigationController?.pushViewController(vc, animated: true)
                                            }
            })
            
            return
        }
        
        if state?.productDetailActivity == .normal {
            UIAlertController.showActionSheet(in: self.viewController,
                                              withTitle: nil,
                                              message: productDetail.name,
                                              cancelButtonTitle: "Cancel",
                                              destructiveButtonTitle: nil,
                                              otherButtonTitles: ["Laporkan Produk"],
                                              popoverPresentationControllerBlock: { popover in
                                                  popover.sourceView = self.viewController.view
                                                  popover.sourceRect = CGRect(x: self.scrollView.bounds.size.width - 60, y: 20, width: 44, height: 44)
            }) { controller, _, buttonIndex in
                if buttonIndex >= controller.firstOtherButtonIndex {
                    
                    let userAuthManager = UserAuthentificationManager()
                    if !userAuthManager.isLogin {
                        AuthenticationService.shared.ensureLoggedInFromViewController(self.viewController) {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_PRODUCT_POST_NOTIFICATION_NAME), object: productDetail.id)
                        }
                        return
                    }
                    
                    AnalyticsManager.trackEventName("clickReport", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Report")
                    let vc = ReportProductViewController()
                    vc.productId = productDetail.id
                    self.viewController.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @objc
    func buyButtonDidTap(_ sender: Any) {
        guard let productDetail = state?.productDetail else {
            return
        }
        
        AnalyticsManager.trackEventName("clickBuy", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Buy")
        
        let userAuthManager = UserAuthentificationManager()
        if !userAuthManager.isLogin {
            AuthenticationService.shared.ensureLoggedInFromViewController(self.viewController) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_PRODUCT_POST_NOTIFICATION_NAME), object: productDetail.id)
            }
            return
        }
        
        let vc = TransactionATCViewController()
        if productDetail.preorderDetail.isPreorder {
            let detailProduct = DetailProductResult()
            let preorderDetail = PreorderDetail()
            preorderDetail.preorder_status = productDetail.preorderDetail.isPreorder
            preorderDetail.preorder_process_time = Int(productDetail.preorderDetail.preorderTime)!
            preorderDetail.preorder_process_time_type_string = productDetail.preorderDetail.preorderTimeType
            detailProduct.preorder = preorderDetail
            vc.data = ["product": detailProduct]
        }
        vc.productPrice = productDetail.info.price
        vc.productID = productDetail.id
        self.viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func promoteButtonDidTap(_ sender: Any) {
        guard let productDetail = state?.productDetail else {
            return
        }
        
        AnalyticsManager.trackEventName("clickProduct", category: GA_EVENT_CATEGORY_SHOP_PRODUCT, action: GA_EVENT_ACTION_CLICK, label: "Promote")
        
        DetailProductRequest.fetchPromoteProduct(productDetail.id, onSuccess: { [weak self] data in
            let productName = data.product_name ?? ""
            let message = "Promo pada produk \"\(productName)\" telah berhasil! Fitur Promo berlaku setiap 60 menit sekali untuk masing-masing toko."
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelButton)
            
            self?.viewController.present(alertController, animated: true, completion: nil)
            
        }) { [weak self] data in
            let productName = data.product_name ?? ""
            let timeExpired = data.time_expired ?? ""
            let message = "Anda belum dapat menggunakan Fitur Promo pada saat ini. Fitur Promo berlaku setiap 60 menit sekali untuk masing-masing toko. Promo masih aktif untuk produk \"\(productName)\" berlaku sampai \(timeExpired)"
            let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let cancelButton = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(cancelButton)
            
            self?.viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func updateWishlist(_ isWishlist: Bool) {
        guard let productDetail = state?.productDetail else {
            return
        }
        
        let userAuthManager = UserAuthentificationManager()
        guard let userId = userAuthManager.getUserId(),
            userAuthManager.isLogin else {
            AuthenticationService.shared.ensureLoggedInFromViewController(self.viewController) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_PRODUCT_POST_NOTIFICATION_NAME), object: productDetail.id)
            }
            return
        }
        
        let tabManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as! ReactEventManager
        
        if isWishlist {
            if let category = productDetail.categories.first {
                let attributes = [
                    "subcategory": productDetail.categories.count > 1 ? productDetail.categories[1].name : "",
                    "subcategory_id": productDetail.categories.count > 1 ? productDetail.categories[1].id : "",
                    "category": category.name,
                    "category_id": category.id,
                    "product_name": productDetail.name,
                    "product_id": productDetail.id,
                    "product_url": productDetail.url,
                    "product_price": productDetail.info.priceUnformatted,
                    "is_official_store": productDetail.shop.isOfficial
                ] as [String: Any]
                AnalyticsManager.moEngageTrackEvent(withName: "Product_Added_To_Wishlist_Marketplace", attributes: attributes)
            }
            
            AnalyticsManager.trackEventName("clickWishlist", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Add to Wishlist")
            
            let networkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            let path = "/users/\(userId)/wishlist/\(productDetail.id)/v1.1"
            networkManager.request(withBaseUrl: NSString.mojitoUrl(),
                                   path: path,
                                   method: .POST,
                                   header: ["X-User-ID": userId],
                                   parameter: nil,
                                   mapping: GeneralAction.mapping(),
                                   onSuccess: { _, _ in
                                       self.wishlistNotificationView.isHidden = true
                                       self.wishlistNotificationView = UIView()
                                       NSObject.cancelPreviousPerformRequests(withTarget: SwiftOverlays.self)
                                       
                                       self.wishlistNotificationView = UIViewController.showNotificationWithMessage("Anda berhasil menambah wishlist", type: NotificationType.success.rawValue, duration: 2.0, buttonTitle: nil, dismissable: true, action: nil)
                                       NotificationCenter.default.post(name: Notification.Name(rawValue: "didAddedProductToWishList"), object: productDetail.id)
                                       tabManager.didWishlistProduct(productDetail.id)
                                   },
                                   onFailure: { _ in
                                       self.store.dispatch(ProductDetailAction.updateWishlist(!isWishlist))
            })
            
        } else {
            if let category = productDetail.categories.first {
                let attributes = [
                    "subcategory": productDetail.categories.count > 1 ? productDetail.categories[1].name : "",
                    "subcategory_id": productDetail.categories.count > 1 ? productDetail.categories[1].id : "",
                    "category": category.name,
                    "category_id": category.id,
                    "product_name": productDetail.name,
                    "product_id": productDetail.id,
                    "product_url": productDetail.url,
                    "product_deeplink_url": "tokopedia://product/\(productDetail.id)",
                    "product_price": productDetail.info.priceUnformatted,
                    "product_image_url": productDetail.images[0].normalURL,
                    "shop_id": productDetail.shop.id
                ] as [String: Any]
                AnalyticsManager.moEngageTrackEvent(withName: "Product_Removed_From_Wishlist_Marketplace", attributes: attributes)
            }
            
            let networkManager = TokopediaNetworkManager()
            networkManager.isUsingHmac = true
            let path = "/users/\(userId)/wishlist/\(productDetail.id)/v1.1"
            networkManager.request(withBaseUrl: NSString.mojitoUrl(),
                                   path: path,
                                   method: .DELETE,
                                   header: ["X-User-ID": userId],
                                   parameter: nil,
                                   mapping: GeneralAction.mapping(),
                                   onSuccess: { _, _ in
                                       self.unwishlistNotificationView.isHidden = true
                                       self.unwishlistNotificationView = UIView()
                                       NSObject.cancelPreviousPerformRequests(withTarget: SwiftOverlays.self)
                                       
                                       self.unwishlistNotificationView = UIViewController.showNotificationWithMessage("Anda berhasil menghapus wishlist", type: NotificationType.success.rawValue, duration: 2.0, buttonTitle: nil, dismissable: true, action: nil)
                                       NotificationCenter.default.post(name: Notification.Name(rawValue: "didRemovedProductFromWishList"), object: productDetail.id)
                                       tabManager.didRemoveWishlistProduct(productDetail.id)
                                   },
                                   onFailure: { _ in
                                       self.store.dispatch(ProductDetailAction.updateWishlist(!isWishlist))
            })
        }
        
    }
    
    func sendMessage() {
        guard let productDetail = state?.productDetail else {
            return
        }
        
        let userAuthManager = UserAuthentificationManager()
        if !userAuthManager.isLogin {
            AuthenticationService.shared.ensureLoggedInFromViewController(self.viewController) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_PRODUCT_POST_NOTIFICATION_NAME), object: productDetail.id)
            }
            return
        }
        
        AnalyticsManager.trackEventName("clickShopHome", category: GA_EVENT_CATEGORY_SHOP_HOME, action: GA_EVENT_ACTION_CLICK, label: "Send Message")
        
        let data = [
            "shop_id": productDetail.shop.id,
            "shop_name": productDetail.shop.name
        ]
        let vc = SendMessageViewController(data: data)!
        vc.source = "product"
        self.viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateFavorite(_ isFavorite: Bool) {
        guard let productDetail = state?.productDetail else {
            return
        }
        
        AnalyticsManager.trackEventName("clickFavoriteShop", category: GA_EVENT_CATEGORY_PRODUCT_DETAIL_PAGE, action: GA_EVENT_ACTION_CLICK, label: "Favorite Shop")
        
        let userAuthManager = UserAuthentificationManager()
        if !userAuthManager.isLogin {
            AuthenticationService.shared.ensureLoggedInFromViewController(self.viewController) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_PRODUCT_POST_NOTIFICATION_NAME), object: productDetail.id)
            }
            return
        }
        
        self.store.dispatch(ProductDetailAction.updateFavorite(isFavorite, true))
        
        let provider = NetworkProvider<V4Target>()
        provider.request(.setFavorite(forShopId: productDetail.shop.id, adKey: nil))
            .subscribe(onNext: { _ in
                self.store.dispatch(ProductDetailAction.updateFavorite(isFavorite, false))
                let message = isFavorite ? "Anda berhasil memfavoritkan Toko ini!" : "Anda berhenti memfavoritkan toko ini!"
                let eventName = isFavorite ? "Seller_Added_To_Favourite" : "Seller_Removed_From_Favourite"
                
                AnalyticsManager.moEngageTrackEvent(withName: eventName,
                                                    attributes: [
                                                        "shop_name": productDetail.shop.name,
                                                        "shop_id": productDetail.shop.id,
                                                        "shop_location": productDetail.shop.location,
                                                        "is_official_store": productDetail.shop.isOfficial
                ])
                
                _ = UIViewController.showNotificationWithMessage(message, type: NotificationType.success.rawValue, duration: 2.0, buttonTitle: nil, dismissable: true, action: nil)
            },
                       onError: { _ in
                self.store.dispatch(ProductDetailAction.updateFavorite(!isFavorite, false))
            })
            .disposed(by: self.rx_disposeBag)
    }
}

// MARK: - Custom Node
class ContainerNode: NodeType {
    
    let node: NodeType
    
    init(identifier: String) {
        self.node = Node(identifier: identifier)
    }
    
    var renderedView: UIView? {
        return self.node.renderedView
    }
    
    /** The unique identifier for this node is its hierarchy. */
    var identifier: String {
        return self.node.identifier
    }
    
    /** The subnodes of this node. */
    var children: [NodeType] {
        set(value) {
            self.node.children = value
        }
        
        get {
            return self.node.children
        }
    }
    
    /** Adds the nodes passed as argument as subnodes. */
    func add(children: [NodeType]) -> NodeType {
        return node.add(children: children)
    }
    
    /** This component is the n-th children. */
    var index: Int {
        get {
            return node.index
        }
        
        set(value) {
            node.index = value
        }
    }
    
    /** Re-applies the configuration closures recursively and compute the new layout for the
     *  derived associated view hierarchy.
     */
    func render(in bounds: CGSize) {
        node.render(in: bounds)
    }
    
    func internalConfigure(in bounds: CGSize) {
        node.internalConfigure(in: bounds)
    }
    
    /** Pre-render callback. */
    func willRender() {
        node.willRender()
    }
    
    /** Post-render callback. */
    func didRender() {
        node.didRender()
    }
    
    /** Force the component to construct the view. */
    func build(with reusable: UIView?) {
        node.build(with: reusable)
    }
}
