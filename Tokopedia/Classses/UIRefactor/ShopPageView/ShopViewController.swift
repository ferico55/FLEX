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

private struct TabChild {
    let title: String
    let viewController: UIViewController
}

class ShopViewController: UIViewController, MXSegmentedPagerDataSource {
    var data: [NSObject: AnyObject]?
    var initialEtalase: EtalaseList?
    
    private let authenticationService = AuthenticationService()
    private var tabChildren: [TabChild] = []
    private var segmentedPagerController: MXSegmentedPagerController!
    private var header: ShopHeaderView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        self.hidesBottomBarWhenPushed = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .whiteColor()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(shopSettingsDidChange),
            name: "tokopedia.kTKPD_EDITSHOPPOSTNOTIFICATIONNAMEKEY",
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(favoriteStatusChanged),
            name: "updateFavoriteShop",
            object: nil)
        
        self.requestShopInfo()
    }
    
    @objc
    private func favoriteStatusChanged(notification: NSNotification) {
        if notification.object !== self {
            self.requestShopInfo()
        }
    }
    
    @objc
    private func shopSettingsDidChange(notification: NSNotification) {
        self.requestShopInfo()
    }
    
    private func requestShopInfo() {
        SwiftOverlays.showCenteredWaitOverlay(self.view)
        
        let shopId = data?["shop_id"] as? String ?? ""
        let shopDomain = data?["shop_domain"] as? String ?? ""
        let request = ShopPageRequest()
        
        request.requestForShopPageContainerWithShopId(
            shopId,
            shopDomain: shopDomain,
            
            onSuccess: { [weak self] shop in
                guard let `self` = self else { return }
                
                SwiftOverlays.removeAllOverlaysFromView(self.view)
                
                self.displayShop(shop)
                self.renderShopHeaderWithShop(shop)
                self.renderBarButtonsWithShop(shop)
                
                self.segmentedPagerController.segmentedPager.scrollToTopAnimated(false)
            },
            
            onFailure: { [weak self] error in
                guard let `self` = self else { return }
                
                SwiftOverlays.removeAllOverlaysFromView(self.view)
                self.showShopFailedToLoad()
            }
        )
    }
    
    private func showShopFailedToLoad() {
        let noResultView = NoResultReusableView(frame: self.view.bounds)
        noResultView.setNoResultImage("icon_retry_grey")
        noResultView.setNoResultTitle("Kendala koneksi internet")
        noResultView.setNoResultDesc("Silakan mencoba kembali")
        noResultView.setNoResultButtonTitle("Coba kembali")
        
        noResultView.onButtonTap = { [weak self] noResultView in
            noResultView.removeFromSuperview()
            self?.requestShopInfo()
        }
        
        self.view.addSubview(noResultView)
    }
    
    private func renderShopHeaderWithShop(shop: Shop) {
        let viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShopWithShopId(shop.result.info.shop_id)
        
        self.header.viewModel = viewModel
        self.segmentedPagerController.segmentedPager.parallaxHeader.height = self.header.sizeThatFits(self.view.bounds.size).height
    }
    
    private func displayShop(shop: Shop) {
        guard segmentedPagerController == nil else { return }
        
        let viewController = MXSegmentedPagerController()
        segmentedPagerController = viewController
        
        header = ShopHeaderView(shop: shop.result)
        
        let viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShopWithShopId(shop.result.info.shop_id)
        
        header.viewModel = viewModel
        
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
        
        viewController.segmentedPager.parallaxHeader.view = header
        viewController.segmentedPager.parallaxHeader.mode = .Bottom
        viewController.segmentedPager.bounces = false
        viewController.segmentedPager.dataSource = self
        
        viewController.segmentedPager.segmentedControl.selectionStyle = .FullWidthStripe
        viewController.segmentedPager.segmentedControl.borderType = [.Top, .Bottom]
        viewController.segmentedPager.segmentedControl.borderColor = UIColor(white: 0.937, alpha: 1)
        viewController.segmentedPager.segmentedControl.selectionIndicatorLocation = .Down
        viewController.segmentedPager.segmentedControl.selectionIndicatorColor = UIColor(red:0.071, green:0.780, blue:0, alpha:1)
        viewController.segmentedPager.segmentedControl.verticalDividerColor = UIColor(white: 0.937, alpha: 1)
        viewController.segmentedPager.segmentedControl.verticalDividerEnabled = true
        viewController.segmentedPager.segmentedControl.titleTextAttributes = [
            NSFontAttributeName: UIFont.largeTheme()
        ]
        
        let homeViewController = ShopHomeViewController(url: shop.result.info.shop_official_top)
        homeViewController.data = data
        
        let productViewController = ShopProductPageViewController()
        productViewController.data = data
        productViewController.shop = shop
        productViewController.initialEtalase = self.initialEtalase
        
        let discussionViewController = ShopTalkPageViewController()
        discussionViewController.data = data
        
        let reviewViewController = ShopReviewPageViewController(shop: shop)
        reviewViewController.data = data
        
        let noteViewController = ShopNotesPageViewController()
        noteViewController.data = data
        
        homeViewController.onProductSelected = { [unowned self] productId in
            self.segmentedPagerController.segmentedPager.pager.showPageAtIndex(1, animated: true)
            
            NavigateViewController.navigateToProductFromViewController(self,
                                                                       withName: "",
                                                                       withPrice: "",
                                                                       withId: productId,
                                                                       withImageurl: "",
                                                                       withShopName: "")
        }
        
        homeViewController.onFilterSelected = { [unowned self] filter in
            self.segmentedPagerController.segmentedPager.pager.showPageAtIndex(1, animated: true)
            
            productViewController.showProductsWithFilter(filter)
        };
        
        tabChildren = [
            TabChild(title: "Home", viewController: homeViewController),
            TabChild(title: "Produk", viewController: productViewController),
            TabChild(title: "Diskusi", viewController: discussionViewController),
            TabChild(title: "Ulasan", viewController: reviewViewController),
            TabChild(title: "Catatan", viewController: noteViewController)
        ]
        
        if !shop.result.info.official {
            tabChildren.removeFirst()
        }
        
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        
        viewController.view.mas_makeConstraints { make in
            make.edges.equalTo()(self.view)
        }
        
        viewController.didMoveToParentViewController(self)
    }
    
    // used by product detail review
    // TODO move all label configurations into the view controller
    func setPropertyLabelDesc(label: TTTAttributedLabel) {
        label.backgroundColor = .clearColor()
        label.textAlignment = .Left
        label.font = UIFont.smallTheme()
        label.textColor = UIColor(red: 117.0/255, green: 117.0/255, blue: 117.0/255, alpha: 1)
        label.lineBreakMode = .ByWordWrapping
        label.numberOfLines = 0
    }
    
    private func renderBarButtonsWithShop(shop: Shop, favoriteRequestInProgress: Bool = false) {
        let infoBarButton = UIBarButtonItem().bk_initWithImage(
            UIImage(named: "icon_shop_info"),
            style: UIBarButtonItemStyle.Plain,
            handler: { [unowned self] button in
                self.openShopInfo(shop)
            }) as! UIBarButtonItem
        
        let refreshBarButton = UIBarButtonItem().bk_initWithBarButtonSystemItem(.Refresh) { [weak self] (sender) in
            self?.refreshCurrentViewController()
        } as! UIBarButtonItem
        
        self.navigationItem.rightBarButtonItems = [refreshBarButton, infoBarButton]
        
        let viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShopWithShopId(shop.result.info.shop_id)
        viewModel.favoriteRequestInProgress = favoriteRequestInProgress
        
        header.viewModel = viewModel
    }
    
    private func refreshCurrentViewController() {
        if let currentViewController = tabChildren[segmentedPagerController.segmentedPager.pager.indexForSelectedPage].viewController
            as? ShopTabChild {
            currentViewController.refreshContent()
        }
    }
    
    private func messageButtonDidTappedWithShop(shop: Shop) {
        self.authenticationService.ensureLoggedInFromViewController(self) { [weak self] in
            guard let `self` = self else { return }
            
            self.renderBarButtonsWithShop(shop)
            
            if !UserAuthentificationManager().isMyShopWithShopId(shop.result.info.shop_id) {
                self.messageShopOwnerWithShop(shop)
            }
        }
    }
    
    private func toggleFavoriteForShop(shop: Shop) {
        authenticationService.ensureLoggedInFromViewController(self) { [weak self] in
            guard let `self` = self else { return }
            
            self.renderBarButtonsWithShop(shop)
            
            guard !UserAuthentificationManager().isMyShopWithShopId(shop.result.info.shop_id) else { return }
            
            self.renderBarButtonsWithShop(shop, favoriteRequestInProgress: true)
            
            let adKey = self.data!["ad_ref_key"] as? String ?? ""
            
            FavoriteShopRequest.requestActionButtonFavoriteShop(
                shop.result.info.shop_id,
                withAdKey: adKey,
                onSuccess: { (result) in
                    let favorite = !(shop.result.info.favorite)
                    shop.result.info.favorite = favorite
                    
                    let message = favorite ? "Anda berhasil memfavoritkan toko ini!" : "Anda berhenti memfavoritkan toko ini!"
                    
                    StickyAlertView(successMessages: [message], delegate: self).show()
                    self.renderBarButtonsWithShop(shop)
                    
                    self.notifyShopFavoriteChanged()
                }, onFailure: {
                    self.renderBarButtonsWithShop(shop)
            })

        }
    }
    
    private func notifyShopFavoriteChanged() {
        NSNotificationCenter.defaultCenter().postNotificationName("notifyFav", object: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("updateFavoriteShop", object: self)
    }
    
    private func openSettingsForShop(shop: Shop) {
        AnalyticsManager.trackEventName(
            "clickShopHome",
            category: GA_EVENT_CATEGORY_SHOP_HOME,
            action: GA_EVENT_ACTION_CLICK,
            label: "Setting")
        
        let viewController = ShopSettingViewController()
        viewController.data = [
            "auth": data!["auth"] as? [NSObject: AnyObject] ?? [:],
            "infoshop": shop.result
        ]
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func addShopProduct() {
        AnalyticsManager.trackEventName(
            "clickShopHome",
            category: GA_EVENT_CATEGORY_SHOP_HOME,
            action: GA_EVENT_ACTION_CLICK,
            label: "Add Product")
        
        let viewController = ProductAddEditViewController()
        viewController.type = .ADD
        
        let navigationController = UINavigationController(rootViewController: viewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
        
    }
    
    private func messageShopOwnerWithShop(shop: Shop) {
        let viewController = SendMessageViewController(toShop: shop)
        viewController.displayFromViewController(self)
    }
    
    private func openShopInfo(shop: Shop) {
        AnalyticsManager.trackEventName(
            "clickShopHome",
            category: GA_EVENT_CATEGORY_SHOP_HOME,
            action: GA_EVENT_ACTION_CLICK,
            label: "Shop Info"
        )
        
        let viewController = ShopInfoViewController()
        viewController.data = [
            "infoshop": shop,
            "auth": data!["auth"] as? [NSObject: AnyObject] ?? [:]
        ]
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func numberOfPagesInSegmentedPager(segmentedPager: MXSegmentedPager) -> Int {
        return tabChildren.count
    }
    
    func segmentedPager(segmentedPager: MXSegmentedPager, titleForSectionAtIndex index: Int) -> String {
        return tabChildren[index].title
    }
    
    func segmentedPager(segmentedPager: MXSegmentedPager, viewForPageAtIndex index: Int) -> UIView {
        let viewController = tabChildren[index].viewController
        let view = viewController.view
        
        guard viewController.parentViewController == nil else { return view }
        
        segmentedPagerController.addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
        
        return view
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

