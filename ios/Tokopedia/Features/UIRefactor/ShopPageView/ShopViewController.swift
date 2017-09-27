//
//  ShopViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 12/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import MXSegmentedPager
import BlocksKit
import TTTAttributedLabel
import SwiftOverlays

private struct TabChild {
    let title: String
    let viewController: UIViewController
}

class ShopViewController: UIViewController {
    var data: [AnyHashable: Any]?
    var initialEtalase: EtalaseList?
    
    fileprivate let authenticationService = AuthenticationService()
    fileprivate var tabChildren: [TabChild] = []
    fileprivate var segmentedPagerController: MXSegmentedPagerController!
    fileprivate var header: ShopHeaderView!
    
    var productFilter: ShopProductFilter?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.shopSettingsDidChange),
            name: NSNotification.Name(rawValue: "tokopedia.kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.favoriteStatusChanged),
            name: NSNotification.Name(rawValue: "updateFavoriteShop"),
            object: nil
        )
        
        self.requestShopInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setWhite()
    }
    
    @objc
    fileprivate func favoriteStatusChanged(_ notification: Notification) {
        if notification.object as? ShopViewController !== self {
            self.requestShopInfo()
        }
    }
    
    @objc
    fileprivate func shopSettingsDidChange(_ notification: Notification) {
        self.requestShopInfo()
    }
    
    fileprivate func requestShopInfo() {
        SwiftOverlays.showCenteredWaitOverlay(self.view)
        
        let shopId = data?["shop_id"] as? String ?? ""
        let shopDomain = data?["shop_domain"] as? String ?? ""
        let request = ShopPageRequest()
        
        request.requestForShopPageContainer(
            withShopId: shopId,
            shopDomain: shopDomain,
            
            onSuccess: { [weak self] shop in
                guard let `self` = self, let shop = shop else { return }
                
                self.trackScreenWithShop(shop)
                
                SwiftOverlays.removeAllOverlaysFromView(self.view)
                
                self.displayShop(shop)
                self.renderShopHeaderWithShop(shop)
                self.renderBarButtonsWithShop(shop)
                
                self.segmentedPagerController.segmentedPager.scrollToTop(animated: false)
            },
            
            onFailure: { [weak self] _ in
                guard let `self` = self else { return }
                
                SwiftOverlays.removeAllOverlaysFromView(self.view)
                self.showShopFailedToLoad()
            }
        )
    }
    
    private func trackScreenWithShop(_ shop: Shop) {
        let shopID = shop.result.info.shop_id
        var shopType = "regular"
        
        if shop.result.info.shop_is_gold == 1 {
            shopType = "gold_merchant"
        }
        
        if shop.result.info.isOfficial {
            shopType = "official_store"
        }
        
        let customLayer = [
            "shopId": shopID,
            "shopType": shopType
        ]
        
        AnalyticsManager.trackScreenName("Shop Page", customDataLayer: customLayer)
    }
    
    fileprivate func showShopFailedToLoad() {
        let noResultView = NoResultReusableView(frame: self.view.bounds)
        noResultView.setNoResultImage("icon_retry_grey")
        noResultView.setNoResultTitle("Kendala koneksi internet")
        noResultView.setNoResultDesc("Silakan mencoba kembali")
        noResultView.setNoResultButtonTitle("Coba kembali")
        
        noResultView.onButtonTap = { [weak self] noResultView in
            noResultView?.removeFromSuperview()
            self?.requestShopInfo()
        }
        
        self.view.addSubview(noResultView)
    }
    
    fileprivate func renderShopHeaderWithShop(_ shop: Shop) {
        let viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShop(withShopId: shop.result.info.shop_id)
        
        self.header.viewModel = viewModel
        header.onTapMessageButton = { [unowned self] in
            self.messageShopOwnerWithShop(shop)
        }
        
        header.onTapSettingsButton = { [unowned self] in
            self.openSettingsForShop(shop)
        }
        
        header.onTapAddProductButton = { [unowned self] in
            self.addShopProduct()
        }
        
        header.onTapFavoriteButton = { [unowned self] in
            self.toggleFavoriteForShop(shop)
        }
        
        self.segmentedPagerController.segmentedPager.parallaxHeader.height = self.header.sizeThatFits(self.view.bounds.size).height
    }
    
    fileprivate func displayShop(_ shop: Shop) {
        guard self.segmentedPagerController == nil else { return }
        
        let viewController = MXSegmentedPagerController()
        segmentedPagerController = viewController
        
        header = ShopHeaderView(shop: shop.result)
        
        let viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShop(withShopId: shop.result.info.shop_id)
        
        header.viewModel = viewModel
        
        renderShopHeaderWithShop(shop)
        
        viewController.segmentedPager.parallaxHeader.view = header
        viewController.segmentedPager.parallaxHeader.mode = .bottom
        viewController.segmentedPager.bounces = false
        viewController.segmentedPager.dataSource = self
        viewController.segmentedPager.delegate = self
        
        viewController.segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        viewController.segmentedPager.segmentedControl.borderType = [.top, .bottom]
        viewController.segmentedPager.segmentedControl.borderColor = UIColor(white: 0.937, alpha: 1)
        viewController.segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        viewController.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor(red: 0.071, green: 0.780, blue: 0, alpha: 1)
        viewController.segmentedPager.segmentedControl.verticalDividerColor = UIColor(white: 0.937, alpha: 1)
        viewController.segmentedPager.segmentedControl.isVerticalDividerEnabled = true
        viewController.segmentedPager.segmentedControl.titleTextAttributes = [
            NSFontAttributeName: UIFont.largeTheme()
        ]
        
        let homeViewController = ShopHomeViewController(url: shop.result.info.shop_official_top)
        homeViewController.data = data as [NSObject: AnyObject]?
        
        let productViewController = ShopProductPageViewController()
        productViewController.data = data
        productViewController.shop = shop
        productViewController.initialEtalase = self.initialEtalase
        if self.productFilter != nil {
            productViewController.showProducts(with: self.productFilter)
        }
        
        let discussionViewController = ShopTalkPageViewController()
        discussionViewController.data = data
        
        let reviewViewController = ShopReviewPageViewController(shop: shop)
        reviewViewController?.data = data
        
        let noteViewController = ShopNotesPageViewController()
        noteViewController.data = data
        
        homeViewController.onProductSelected = { [unowned self] productId in
            self.segmentedPagerController.segmentedPager.pager.showPage(at: 1, animated: true)
            
            NavigateViewController.navigateToProduct(
                from: self,
                withName: "",
                withPrice: "",
                withId: productId,
                withImageurl: "",
                withShopName: ""
            )
        }
        
        homeViewController.onFilterSelected = { [unowned self] filter in
            self.segmentedPagerController.segmentedPager.pager.showPage(at: 1, animated: true)
            
            productViewController.showProducts(with: filter)
        }
        
        tabChildren = [
            TabChild(title: "Home", viewController: homeViewController),
            TabChild(title: "Produk", viewController: productViewController),
            TabChild(title: "Diskusi", viewController: discussionViewController),
            TabChild(title: "Ulasan", viewController: reviewViewController!),
            TabChild(title: "Catatan", viewController: noteViewController)
        ]
        
        if !shop.result.info.isOfficial {
            self.tabChildren.removeFirst()
        }
        
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        
        viewController.view.mas_makeConstraints { make in
            make?.edges.equalTo()(self.view)
        }
        
        viewController.didMove(toParentViewController: self)
    }
    
    // used by product detail review
    // TODO: move all label configurations into the view controller
    func setPropertyLabelDesc(_ label: TTTAttributedLabel) {
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont.smallTheme()
        label.textColor = UIColor(red: 117.0 / 255, green: 117.0 / 255, blue: 117.0 / 255, alpha: 1)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
    }
    
    fileprivate func renderBarButtonsWithShop(_ shop: Shop, favoriteRequestInProgress: Bool = false) {
        let infoBarButton = UIBarButtonItem().bk_init(
            with: UIImage(named: "icon_shop_info"),
            style: UIBarButtonItemStyle.plain,
            handler: { [unowned self] _ in
                self.openShopInfo(shop)
            }
        ) as! UIBarButtonItem
        
        let refreshBarButton = UIBarButtonItem().bk_init(with: .refresh) { [weak self] _ in
            self?.refreshCurrentViewController()
        } as! UIBarButtonItem
        
        self.navigationItem.rightBarButtonItems = [refreshBarButton, infoBarButton]
        
        let viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShop(withShopId: shop.result.info.shop_id)
        viewModel.favoriteRequestInProgress = favoriteRequestInProgress
        
        header.viewModel = viewModel
    }
    
    fileprivate func refreshCurrentViewController() {
        if let currentViewController = tabChildren[segmentedPagerController.segmentedPager.pager.indexForSelectedPage].viewController
            as? ShopTabChild {
            currentViewController.refreshContent()
        }
    }
    
    fileprivate func messageButtonDidTappedWithShop(_ shop: Shop) {
        self.authenticationService.ensureLoggedInFromViewController(self) { [weak self] _ in
            guard let `self` = self else { return }
            
            self.renderBarButtonsWithShop(shop)
            
            if !UserAuthentificationManager().isMyShop(withShopId: shop.result.info.shop_id) {
                self.messageShopOwnerWithShop(shop)
            }
        }
    }
    
    fileprivate func toggleFavoriteForShop(_ shop: Shop) {
        self.authenticationService.ensureLoggedInFromViewController(self) { [weak self] _ in
            guard let `self` = self else { return }
            
            self.renderBarButtonsWithShop(shop)
            
            guard !UserAuthentificationManager().isMyShop(withShopId: shop.result.info.shop_id) else { return }
            
            self.renderBarButtonsWithShop(shop, favoriteRequestInProgress: true)
            
            AnalyticsManager.trackEventName(
                "clickShopHome",
                category: GA_EVENT_CATEGORY_SHOP_HOME,
                action: GA_EVENT_ACTION_CLICK,
                label: "Add to Favorite - \(shop.result.info.shop_name)"
            )
            
            FavoriteShopRequest.requestActionButtonFavoriteShop(
                shop.result.info.shop_id,
                withAdKey: "",
                onSuccess: { _ in
                    
                    let favorite = !(shop.result.info.isFavorite)
                    shop.result.info.isFavorite = favorite
                    
                    let eventName = favorite ? "Seller_Added_To_Favourite" : "Seller_Removed_From_Favourite"
                    
                    AnalyticsManager.moEngageTrackEvent(
                        withName: eventName,
                        attributes: [
                            "shop_name": shop.result.info.shop_name,
                            "shop_id": shop.result.info.shop_id,
                            "shop_location": shop.result.info.shop_location,
                            "is_official_store": shop.result.info.isOfficial
                        ]
                    )
                    
                    let message = favorite ? "Anda berhasil memfavoritkan toko ini!" : "Anda berhenti memfavoritkan toko ini!"
                    
                    StickyAlertView(successMessages: [message], delegate: self).show()
                    self.renderBarButtonsWithShop(shop)
                    
                    self.notifyShopFavoriteChanged()
                },
                onFailure: {
                    self.renderBarButtonsWithShop(shop)
                }
            )
            
        }
    }
    
    fileprivate func notifyShopFavoriteChanged() {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "notifyFav"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateFavoriteShop"), object: self)
    }
    
    fileprivate func openSettingsForShop(_ shop: Shop) {
        AnalyticsManager.trackEventName(
            "clickShopHome",
            category: GA_EVENT_CATEGORY_SHOP_HOME,
            action: GA_EVENT_ACTION_CLICK,
            label: "Setting"
        )
        
        let viewController = ShopSettingViewController()
        viewController.data = [
            "auth": data!["auth"] as? [AnyHashable: Any] ?? [:],
            "infoshop": shop.result
        ]
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func addShopProduct() {
        AnalyticsManager.trackEventName(
            "clickShopHome",
            category: GA_EVENT_CATEGORY_SHOP_HOME,
            action: GA_EVENT_ACTION_CLICK,
            label: "Add Product"
        )
        
        let viewController = ProductAddEditViewController()
        viewController.type = .ADD
        
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    fileprivate func messageShopOwnerWithShop(_ shop: Shop) {
        AnalyticsManager.trackEventName(
            "clickShopHome",
            category: GA_EVENT_CATEGORY_SHOP_HOME,
            action: GA_EVENT_ACTION_CLICK,
            label: "Send Message"
        )
        let viewController = SendMessageViewController(to: shop)
        viewController?.source = "shop"
        viewController?.display(from: self)
    }
    
    fileprivate func openShopInfo(_ shop: Shop) {
        AnalyticsManager.trackEventName(
            "clickShopHome",
            category: GA_EVENT_CATEGORY_SHOP_HOME,
            action: GA_EVENT_ACTION_CLICK,
            label: "Shop Info"
        )
        
        let viewController = ShopInfoViewController()
        viewController.data = [
            "infoshop": shop,
            "auth": data!["auth"] as? [AnyHashable: Any] ?? [:]
        ]
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ShopViewController: MXSegmentedPagerDataSource {
    func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return tabChildren.count
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return tabChildren[index].title
    }
    
    func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        let viewController = tabChildren[index].viewController
        let view = viewController.view
        
        guard viewController.parent == nil else { return view! }
        
        segmentedPagerController.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        
        return view!
    }
}

extension ShopViewController: MXSegmentedPagerDelegate {
    func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWith index: Int) {
        
        tabChildren.forEach { child in
            let tabChild = child.viewController as? ShopTabChild
            tabChild?.tabWillChange?(to: tabChildren[index].viewController)
        }
    }
}
