//
//  ShopViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 12/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import BlocksKit
import MXSegmentedPager
import NativeNavigation
import SwiftOverlays
import TTTAttributedLabel
import UIKit

private struct TabChild {
    let title: String
    let viewController: UIViewController
}

@objc public protocol ShopViewControllerDelegate: NSObjectProtocol {
    func didDisplayReviewPage()
}

internal class ShopViewController: UIViewController {
    internal var data: [AnyHashable: Any]?
    internal var initialEtalase: EtalaseList?
    
    fileprivate let authenticationService = AuthenticationService.shared
    fileprivate var tabChildren: [TabChild] = []
    fileprivate var segmentedPagerController: MXSegmentedPagerController!
    fileprivate var header: ShopHeaderView = ShopHeaderView.instanceFromNib()
    fileprivate var isOfficial: Bool = false
    fileprivate var headerHeight: CGFloat!
    fileprivate var updateOSTabOnce: Bool = true // os tab update must be done after view appears, but only once in it's lifetime
    
    internal weak var delegate: ShopViewControllerDelegate?
    internal var productFilter: ShopProductFilter?
    internal var productTracker: ProductTracker = ProductTracker()
    
    internal init() {
        super.init(nibName: nil, bundle: nil)
        
        self.hidesBottomBarWhenPushed = true
    }
    
    required internal init?(coder aDecoder: NSCoder) {
        fatalError("not implemented")
    }
    
    override internal func viewDidLoad() {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if self.isOfficial && self.updateOSTabOnce {
            self.segmentedPagerController.segmentedPager.segmentedControl.selectedSegmentIndex = 1
            self.segmentedPagerController.segmentedPager.pager.showPage(at: 1, animated: false)
            self.segmentedPagerController.segmentedPager.reloadData()
        }
        self.updateOSTabOnce = false
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
        let shopID = shop.result.info.shop_id as Any
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
    
    // update header content with model and sets the header height accordingly
    fileprivate func updateHeaderContent(_ viewModel: ShopHeaderViewModel) {
        DispatchQueue.main.async {
            self.header.viewModel = viewModel
            
            self.header.setNeedsLayout()
            self.header.layoutIfNeeded()
            // manually set header height here
            self.headerHeight = self.header.containerView.bounds.size.height // grab height from the stack view not the main view (stack view determines content height)
            self.segmentedPagerController.segmentedPager.parallaxHeader.height = self.headerHeight
            self.segmentedPagerController.segmentedPager.scrollToTop(animated: false) // reset scroll to top
        }
    }
    
    fileprivate func displayShop(_ shop: Shop) {
        guard self.segmentedPagerController == nil else { return }
        self.isOfficial = shop.result.info.isOfficial
        
        let viewController = MXSegmentedPagerController()
        segmentedPagerController = viewController
        
        // setup header callbacks
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
        
        // update header
        var viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShop(withShopId: shop.result.info.shop_id)
        self.updateHeaderContent(viewModel)
        
        viewController.segmentedPager.parallaxHeader.mode = .bottom
        viewController.segmentedPager.bounces = false
        viewController.segmentedPager.dataSource = self
        viewController.segmentedPager.delegate = self
        
        viewController.segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        viewController.segmentedPager.segmentedControl.borderType = [.top, .bottom]
        viewController.segmentedPager.segmentedControl.borderColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        viewController.segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        viewController.segmentedPager.segmentedControl.selectionIndicatorColor = #colorLiteral(red: 0.07058823529, green: 0.7803921569, blue: 0, alpha: 1)
        viewController.segmentedPager.segmentedControl.verticalDividerColor = #colorLiteral(red: 0.937254902, green: 0.937254902, blue: 0.937254902, alpha: 1)
        viewController.segmentedPager.segmentedControl.isVerticalDividerEnabled = true
        viewController.segmentedPager.segmentedControl.titleTextAttributes = [
            NSFontAttributeName: UIFont.largeTheme()
        ]
        
        let homeUrl = UserAuthentificationManager().webViewUrl(fromUrl: shop.result.info.shop_official_top)
        let homeViewController = ShopHomeViewController(url: homeUrl)
        homeViewController.data = data as [NSObject: AnyObject]?
        
        let productViewController = ShopProductPageViewController()
        productViewController.objectTracker = self.productTracker
        productViewController.data = data
        productViewController.shop = shop
        productViewController.initialEtalase = self.initialEtalase
        
        if self.productFilter != nil {
            productViewController.showProducts(with: self.productFilter)
        }
        
        let discussionViewController = ShopTalkPageViewController()
        discussionViewController.data = data
        
        let userManager = UserAuthentificationManager()
        let auth = userManager.getUserLoginData()
        let reviewViewController = ReactViewController(moduleName: "ShopReviewScreen", props: ["authInfo": auth as AnyObject, "shopDomain": shop.result.info.shop_domain! as AnyObject, "shopID": shop.result.info.shop_id! as AnyObject])
        
        let noteViewController = ShopNotesPageViewController()
        noteViewController.data = data
        
        homeViewController.onProductSelected = { [unowned self] productId in
            self.segmentedPagerController.segmentedPager.pager.showPage(at: 1, animated: true)
            
            NavigateViewController.navigateToProduct(
                from: self,
                withProductID: productId,
                andName: "",
                andPrice: "",
                andImageURL: "",
                andShopName: "",
                with: self.productTracker
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
            TabChild(title: "Ulasan", viewController: reviewViewController),
            TabChild(title: "Catatan", viewController: noteViewController)
        ]
        
        if !shop.result.info.isOfficial {
            self.tabChildren.removeFirst()
        }
        
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            viewController.view.topAnchor.constraint(equalTo: self.view.safeAreaTopAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaBottomAnchor),
            viewController.view.leftAnchor.constraint(equalTo: self.view.safeAreaLeftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: self.view.safeAreaRightAnchor)
            ])
        
        viewController.didMove(toParentViewController: self)
    }
    
    internal func getCurrentPageIndex() -> Int {
        return self.segmentedPagerController.segmentedPager.pager.indexForSelectedPage
    }
    
    internal func isDisplayingReviewPage() -> Bool {
        let currentIndex = self.segmentedPagerController.segmentedPager.pager.indexForSelectedPage
        if self.isOfficial {
            return currentIndex == 3
        } else {
            return currentIndex == 2
        }
    }
    
    internal func minimizeHeader() {
        self.segmentedPagerController.segmentedPager.parallaxHeader.height = 0
        self.segmentedPagerController.segmentedPager.parallaxHeader.height = self.headerHeight
    }
    
    internal func setPropertyLabelDesc(_ label: TTTAttributedLabel) {
        label.backgroundColor = .clear
        label.textAlignment = .left
        label.font = UIFont.smallTheme()
        label.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
    }
    
    fileprivate func renderBarButtonsWithShop(_ shop: Shop, favoriteRequestInProgress: Bool = false) {
        let infoBarButton = UIBarButtonItem().bk_init(
            with: #imageLiteral(resourceName: "icon_shop_info"),
            style: UIBarButtonItemStyle.plain,
            handler: { [unowned self] _ in
                self.openShopInfo(shop)
            }
        ) as! UIBarButtonItem // this looks safe to be forced
        
        let refreshBarButton = UIBarButtonItem().bk_init(with: .refresh) { [weak self] _ in
            self?.refreshCurrentViewController()
        } as! UIBarButtonItem // this looks safe to be forced
        
        self.navigationItem.rightBarButtonItems = [refreshBarButton, infoBarButton]
        
        var viewModel = ShopHeaderViewModel()
        viewModel.shop = shop.result
        viewModel.ownShop = UserAuthentificationManager().isMyShop(withShopId: shop.result.info.shop_id)
        viewModel.favoriteRequestInProgress = favoriteRequestInProgress
        
        self.updateHeaderContent(viewModel)
    }
    
    fileprivate func refreshCurrentViewController() {
        if let currentViewController = tabChildren[segmentedPagerController.segmentedPager.pager.indexForSelectedPage].viewController
            as? ShopTabChild {
            currentViewController.refreshContent()
        } else if let _ = tabChildren[segmentedPagerController.segmentedPager.pager.indexForSelectedPage].viewController as? ReactViewController {
            if let tabManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager {
                tabManager.sendRefreshEvent()
            }
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
                    
                    if let manager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager {
                        manager.sendFavoriteShopEvent()
                    }
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
        
        let userAuthManager = UserAuthentificationManager()
        let vc = ReactViewController(moduleName: "AddProductScreen", props: [
            "authInfo": userAuthManager.getUserLoginData() as AnyObject
            ])
        
        let navigation = UINavigationController(rootViewController: vc)
        navigation.navigationBar.isTranslucent = false
        self.present(navigation, animated: true, completion: nil)
    }
    
    fileprivate func messageShopOwnerWithShop(_ shop: Shop) {
        AnalyticsManager.trackEventName(
            "ClickShopPage",
            category: "shop page",
            action: "click on kirim pesan",
            label: ""
        )
        
        let vc = SendChatViewController(userID: nil, shopID: shop.result.info.shop_id, name: shop.result.info.shop_name, imageURL: shop.result.info.shop_avatar, invoiceURL: nil, productURL: nil, source: "shop")
        
        self.navigationController?.pushViewController(vc, animated: true)
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
    internal func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        return tabChildren.count
    }
    
    internal func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        return tabChildren[index].title
    }
    
    internal func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        let viewController = tabChildren[index].viewController
        let view = viewController.view
        
        guard viewController.parent == nil else { return view! }
        
        segmentedPagerController.addChildViewController(viewController)
        viewController.didMove(toParentViewController: self)
        
        return view!
    }
}

extension ShopViewController: MXSegmentedPagerDelegate {
    internal func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWith index: Int) {
        
        tabChildren.forEach { child in
            let tabChild = child.viewController as? ShopTabChild
            tabChild?.tabWillChange?(to: tabChildren[index].viewController)
        }
        
        if self.isDisplayingReviewPage() {
            let userManager = UserAuthentificationManager()
            if let onboardingStatus = UserDefaults.standard.dictionary(forKey: "shop_onboarding") {
                guard let status = onboardingStatus[userManager.getUserId()] as? Bool else {
                    self.minimizeHeader()
                    self.delegate?.didDisplayReviewPage()
                    return
                }
                if !status {
                    self.minimizeHeader()
                }
            } else {
                self.minimizeHeader()
            }
            self.delegate?.didDisplayReviewPage()
        }
    }
}

extension ShopViewController: CustomTopMostViewController {
    internal func customTopMostViewController() -> UIViewController? {
        if self.segmentedPagerController == nil {
            return nil
        }
        if tabChildren.count > 3 {
            if self.isOfficial {
                return tabChildren[3].viewController
            }
            return tabChildren[2].viewController
        }
        return nil
    }
}
