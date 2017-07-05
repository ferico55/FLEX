//
//  HomePageViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation
import OAStackView
import RestKit
import JLPermissions

@IBDesignable
@objc

class HomePageViewController: UIViewController {
    
    private var digitalGoodsDataSource: DigitalGoodsDataSource!
    
    private var tickerRequest: AnnouncementTickerRequest!
    private var tickerView: AnnouncementTickerView!
    
    private var pulsaView: PulsaView!
    private var prefixes = Dictionary<String, Dictionary<String, String>>()
    private var requestManager: PulsaRequest!
    private var navigator: PulsaNavigator!
    
    private var sliderPlaceholder: UIView!
    private var pulsaPlaceholder: UIView!
    private var tickerPlaceholder: UIView!
    private var tokocashPlaceholder: UIView!
    private var categoryPlaceholder: OAStackView!
    private var homePageCategoryData: HomePageCategoryData?
    private var pulsaActiveCategories: [PulsaCategory]?
    
    private var topPicksPlaceholder = UIView()
    private var isTopPicksDataEmpty = true
    
    private var storeManager = TKPStoreManager()
    
    @IBOutlet private var homePageScrollView: UIScrollView!
    private var outerStackView: OAStackView!
    private lazy var categoryVerticalView: OAStackView = OAStackView()
    
    private let sliderHeight: CGFloat = (UI_USER_INTERFACE_IDIOM() == .pad) ? 275.0 : 225.0
    private let screenWidth = UIScreen.main.bounds.size.width
    private let backgroundColor = UIColor(red: 242 / 255.0, green: 242 / 255.0, blue: 242 / 255.0, alpha: 1.0)
    private let imageCategoryWidth: CGFloat = 25.0
    private let iconSeparatorGrayColor: UIColor = UIColor(red: 241.0 / 255.0, green: 241.0 / 255.0, blue: 241.0 / 255.0, alpha: 1)
    private let horizontalStackViewSpacing: CGFloat = 30.0
    
    private var isRequestingCategory: Bool = false
    private var canRequestTicker: Bool = true
    private var isRequestingBanner: Bool = false
    private var isRequestingPulsaWidget: Bool = false
    private var isRequestingOfficialStore: Bool = false
    private var officialStoreRequestSuccess: Bool = false
    private var isShowTokoCash: Bool = false
    //    private var categoryId = ""
    
    private let officialStorePlaceholder = UIView()
    fileprivate let authenticationService = AuthenticationService()
    fileprivate let userManager = UserAuthentificationManager()
    
    init() {
        super.init(nibName: "HomePageViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.homePageScrollView.keyboardDismissMode = .onDrag
        self.initOuterStackView()
        self.initViewLayout()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogin(notification:)), name: NSNotification.Name(rawValue: TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogout(notification:)), name: NSNotification.Name(rawValue: TKPDUserDidLogoutNotification), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.userManager.isLogin {
            self.requestTokocash()
        } else {
            self.tokocashPlaceholder.isHidden = true
        }
        
        if self.isRequestingBanner == false {
            self.requestBanner()
        }
        if self.canRequestTicker == true {
            self.requestTicker()
        }
        if self.pulsaActiveCategories == nil && self.isRequestingPulsaWidget == false {
            self.requestPulsaWidget()
        }
        if self.homePageCategoryData == nil && self.isRequestingCategory == false {
            self.requestCategory()
        }
        
        if !self.officialStoreRequestSuccess && !self.isRequestingOfficialStore {
            self.requestOfficialStore()
        }
        
        if self.isTopPicksDataEmpty {
            let topPicksWidgetViewController = TopPicksWidgetViewController()
            topPicksWidgetViewController.didGetTopPicksData = { [unowned self] in
                self.isTopPicksDataEmpty = false
            }
            self.addChildViewController(topPicksWidgetViewController)
            self.topPicksPlaceholder.addSubview(topPicksWidgetViewController.view)
            topPicksWidgetViewController.view.mas_makeConstraints { make in
                make?.edges.mas_equalTo()(self.topPicksPlaceholder)
            }
        }
        AnalyticsManager.moEngageTrackEvent(withName: "Beranda_Screen_Launched", attributes: ["logged_in_status": UserAuthentificationManager().isLogin])
        AnalyticsManager.trackScreenName("Top Category")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let bannersStore = self.storeManager.homeBannerStore
        bannersStore?.stopBannerRequest()
    }
    
    func userDidLogin(notification: NSNotification) {
        self.requestPulsaWidget()
    }
    
    func userDidLogout(notification: NSNotification) {
        self.requestPulsaWidget()
    }
    
    // MARK: Setup StackView
    
    private func initOuterStackView() {
        self.outerStackView = OAStackView()
        self.setStackViewAttribute(self.outerStackView, axis: .vertical, alignment: .fill, distribution: .fill, spacing: 0.0)
        self.homePageScrollView.addSubview(self.outerStackView)
        self.setupOuterStackViewConstraint()
    }
    
    private func setStackViewAttribute(_ stackView: OAStackView, axis: UILayoutConstraintAxis, alignment: OAStackViewAlignment, distribution: OAStackViewDistribution, spacing: CGFloat) {
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
    }
    
    private func setupOuterStackViewConstraint() {
        self.outerStackView.mas_makeConstraints { make in
            make?.top.mas_equalTo()(self.homePageScrollView.mas_top)
            make?.bottom.mas_equalTo()(self.homePageScrollView.mas_bottom)
            make?.left.mas_equalTo()(self.homePageScrollView.mas_left)
            make?.right.mas_equalTo()(self.homePageScrollView.mas_right)
            make?.width.mas_equalTo()(self.view.mas_width)
        }
    }
    
    private func setCategoryTitleLabel(_ title: String) {
        HomePageHeaderSectionStyle.setHeaderTitle(forStackView: self.categoryVerticalView, title: title)
    }
    
    private func setIconImageContainerToIconStackView(_ iconStackView: OAStackView, withLayoutRow layoutRow: HomePageCategoryLayoutRow) {
        let url: NSURL? = NSURL(string: layoutRow.image_url)
        let iconImageView: UIImageView = UIImageView()
        if let url = url {
            iconImageView.setImageWith(url as URL!)
        }
        let imageViewContainer = UIView()
        imageViewContainer.addSubview(iconImageView)
        iconImageView.mas_makeConstraints({ make in
            make?.left.equalTo()(imageViewContainer)
            make?.centerY.equalTo()(imageViewContainer)
            make?.height.width().mas_equalTo()(self.imageCategoryWidth)
        })
        iconImageView.contentMode = .scaleAspectFit
        iconStackView.addArrangedSubview(imageViewContainer)
        imageViewContainer.mas_makeConstraints({ make in
            make?.width.mas_equalTo()(self.imageCategoryWidth)
        })
    }
    
    private func setCategoryNameLabelContainerToIconStackView(_ iconStackView: OAStackView, withLayoutRow layoutRow: HomePageCategoryLayoutRow) -> UIView {
        let categoryNameContainer = UIView()
        let categoryNameLabel = UILabel()
        categoryNameLabel.text = layoutRow.name
        categoryNameLabel.font = UIFont.microTheme()
        categoryNameLabel.textColor = UIColor(red: 102.0 / 255, green: 102.0 / 255, blue: 102.0 / 255, alpha: 1.0)
        categoryNameLabel.textAlignment = .left
        categoryNameLabel.numberOfLines = 2
        categoryNameContainer.addSubview(categoryNameLabel)
        categoryNameLabel.mas_makeConstraints({ make in
            make?.left.right().mas_equalTo()(categoryNameContainer)
            make?.centerY.mas_equalTo()(categoryNameContainer)
        })
        iconStackView.addArrangedSubview(categoryNameContainer)
        
        return categoryNameContainer
    }
    
    private func setTapGestureRecognizerToIconStackView(_ iconStackView: OAStackView, withLayoutRow layoutRow: HomePageCategoryLayoutRow) {
        let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizer(handler: { _, _, _ in
            self.didTapCategory(layoutRow: layoutRow)
        }) as! UITapGestureRecognizer
        
        iconStackView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setHorizontalCategoryLayoutWithLayoutSections(_ layoutRows: [HomePageCategoryLayoutRow]) {
        var horizontalStackView = refreshHorizontalStackView()
        for (index, layoutRow) in layoutRows.enumerated() {
            let iconStackView = OAStackView()
            self.setStackViewAttribute(iconStackView, axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 8.0)
            self.setIconImageContainerToIconStackView(iconStackView, withLayoutRow: layoutRow)
            let categoryNameContainer = self.setCategoryNameLabelContainerToIconStackView(iconStackView, withLayoutRow: layoutRow)
            horizontalStackView.addArrangedSubview(iconStackView)
            self.setTapGestureRecognizerToIconStackView(iconStackView, withLayoutRow: layoutRow)
            
            if index % self.totalColumnInOneRow() == self.numberNeededToChangeRow() {
                self.categoryVerticalView.addArrangedSubview(horizontalStackView)
                horizontalStackView = self.refreshHorizontalStackView()
                if index != layoutRows.count - 1 {
                    self.drawHorizontalIconSeparator()
                }
            } else if index == layoutRows.count - 1 {
                let verticalIconSeparator = UIView()
                verticalIconSeparator.backgroundColor = iconSeparatorGrayColor
                categoryNameContainer.addSubview(verticalIconSeparator)
                verticalIconSeparator.mas_makeConstraints({ make in
                    make?.width.mas_equalTo()(1)
                    make?.right.mas_equalTo()(categoryNameContainer)?.with().offset()(self.horizontalStackViewSpacing / 2)
                    make?.top.mas_equalTo()(categoryNameContainer)?.with().offset()(5)
                    make?.bottom.mas_equalTo()(categoryNameContainer)?.with().offset()(-5)
                })
                
                for _ in 1...self.totalColumnInOneRow() - (index % self.totalColumnInOneRow() + 1) {
                    let emptyIconView = UIView()
                    horizontalStackView.addArrangedSubview(emptyIconView)
                }
                self.categoryVerticalView.addArrangedSubview(horizontalStackView)
            } else {
                let verticalIconSeparator = UIView()
                verticalIconSeparator.backgroundColor = iconSeparatorGrayColor
                categoryNameContainer.addSubview(verticalIconSeparator)
                verticalIconSeparator.mas_makeConstraints({ make in
                    make?.width.mas_equalTo()(1)
                    make?.right.mas_equalTo()(categoryNameContainer)?.with().offset()(self.horizontalStackViewSpacing / 2)
                    make?.top.mas_equalTo()(categoryNameContainer)?.with().offset()(5)
                    make?.bottom.mas_equalTo()(categoryNameContainer)?.with().offset()(-5)
                })
            }
        }
    }
    
    private func totalColumnInOneRow() -> Int {
        return UI_USER_INTERFACE_IDIOM() == .pad ? 4 : 2
    }
    
    private func numberNeededToChangeRow() -> Int {
        return self.totalColumnInOneRow() - 1
    }
    
    private func setCategoryUpperSeparator() {
        HomePageHeaderSectionStyle.setHeaderUpperSeparator(forStackView: self.categoryVerticalView)
    }
    
    private func setOuterCategorySeparatorView() {
        let outerCategorySeparatorView = UIView()
        outerCategorySeparatorView.mas_makeConstraints({ make in
            make?.height.mas_equalTo()(10)
        })
        outerCategorySeparatorView.backgroundColor = UIColor(red: 241.0 / 255, green: 241.0 / 255, blue: 241.0 / 255, alpha: 1.0)
        categoryPlaceholder.addArrangedSubview(outerCategorySeparatorView)
    }
    
    private func setupOuterStackCategoryWithData(_ homePageCategoryData: HomePageCategoryData) {
        
        for (index, layout_section) in homePageCategoryData.layout_sections.enumerated() {
            
            self.setOuterCategorySeparatorView()
            self.categoryVerticalView = OAStackView()
            self.categoryVerticalView.isLayoutMarginsRelativeArrangement = true
            self.categoryVerticalView.layoutMargins = UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20)
            self.setStackViewAttribute(self.categoryVerticalView, axis: .vertical, alignment: .fill, distribution: .fill, spacing: 0.0)
            
            self.setCategoryTitleLabel(layout_section.title)
            
            self.setCategoryUpperSeparator()
            
            self.setHorizontalCategoryLayoutWithLayoutSections(layout_section.layout_rows)
            
            self.categoryPlaceholder.addArrangedSubview(self.categoryVerticalView)
        }
        self.setOuterCategorySeparatorView()
    }
    
    private func initViewLayout() {
        self.tokocashPlaceholder = UIView()
        self.sliderPlaceholder = UIView()
        self.sliderPlaceholder.backgroundColor = self.backgroundColor
        self.tickerPlaceholder = UIView(frame: .zero)
        self.pulsaPlaceholder = UIView()
        self.categoryPlaceholder = OAStackView()
        self.setStackViewAttribute(self.categoryPlaceholder, axis: .vertical, alignment: .fill, distribution: .fill, spacing: 0.0)
        
        // init slider
        self.sliderPlaceholder.mas_makeConstraints { make in
            make?.height.mas_equalTo()(self.sliderHeight)
        }
        
        self.outerStackView.addArrangedSubview(self.tokocashPlaceholder)
        
        self.outerStackView.addArrangedSubview(self.sliderPlaceholder)
        
        // init pulsa widget
        self.outerStackView.addArrangedSubview(self.pulsaPlaceholder)
        
        self.outerStackView.addArrangedSubview(self.officialStorePlaceholder)
        
        // init category
        self.outerStackView.addArrangedSubview(self.categoryPlaceholder)
        
        // init top picks
        self.outerStackView.addArrangedSubview(self.topPicksPlaceholder)
        
    }
    
    private func refreshHorizontalStackView() -> OAStackView {
        let horizontalStackView = OAStackView()
        self.setStackViewAttribute(horizontalStackView, axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: horizontalStackViewSpacing)
        horizontalStackView.mas_makeConstraints({ make in
            make?.height.mas_equalTo()(50)
        })
        return horizontalStackView
    }
    
    private func drawHorizontalIconSeparator() {
        let horizontalIconSeparator = UIView()
        horizontalIconSeparator.backgroundColor = iconSeparatorGrayColor
        self.categoryVerticalView.addArrangedSubview(horizontalIconSeparator)
        horizontalIconSeparator.mas_makeConstraints({ make in
            make?.height.mas_equalTo()(1)
        })
    }
    
    // MARK: Request Method
    
    private func requestCategory() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        isRequestingCategory = true
        networkManager.request(withBaseUrl: NSString.mojitoUrl(), path: "/api/v1/layout/category", method: .GET, parameter: nil, mapping: HomePageCategoryResponse.mapping(), onSuccess: { [unowned self] mappingResult, _ in
            self.isRequestingCategory = false
            let result: NSDictionary = (mappingResult as RKMappingResult).dictionary() as NSDictionary
            let homePageCategoryResponse: HomePageCategoryResponse = result[""] as! HomePageCategoryResponse
            self.homePageCategoryData = homePageCategoryResponse.data
            self.setupOuterStackCategoryWithData(self.homePageCategoryData!)
        }) { [unowned self] error in
            self.isRequestingCategory = false
            let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
            stickyAlertView?.show()
        }
    }
    
    private func requestBanner() {
        let bannersStore = self.storeManager.homeBannerStore
        
        let backgroundColor = self.backgroundColor
        isRequestingBanner = true
        bannersStore?.fetchBanner(completion: { [unowned self] banner, _ in
            self.isRequestingBanner = false
            guard banner != nil else {
                return
            }
            let homeSliderView = UINib(nibName: "HomeSliderView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! HomeSliderView
            homeSliderView.generateSliderView(withBanner: banner!, withNavigationController: self.navigationController!)
            
            self.sliderPlaceholder.addSubview(homeSliderView)
            
            homeSliderView.mas_makeConstraints { make in
                make?.edges.mas_equalTo()(self.sliderPlaceholder)
            }
            
        })
    }
    
    private func requestPulsaWidget() {
        self.requestManager = PulsaRequest()
        self.requestManager.requestCategory()
        self.isRequestingPulsaWidget = true
        self.requestManager.didReceiveCategory = { [unowned self] categories in
            self.isRequestingPulsaWidget = false
            self.pulsaActiveCategories = categories.filter({ (pulsaCategory) -> Bool in
                pulsaCategory.attributes.status == 1
            })
            
            var sortedCategories = self.pulsaActiveCategories!
            sortedCategories.sort(by: {
                $0.attributes.weight < $1.attributes.weight
            })
            
            self.pulsaView = PulsaView(categories: sortedCategories)
            
            self.pulsaPlaceholder.removeAllSubviews()
            self.pulsaPlaceholder.backgroundColor = self.iconSeparatorGrayColor
            self.pulsaPlaceholder.addSubview(self.pulsaView)
            self.pulsaView.mas_makeConstraints({ make in
                make?.top.bottom().equalTo()(self.pulsaPlaceholder)
                make?.left.mas_equalTo()(self.pulsaPlaceholder)?.offset()(7)
                make?.right.mas_equalTo()(self.pulsaPlaceholder)?.offset()(-7)
            })
            
            self.navigator = PulsaNavigator()
            self.navigator.pulsaView = self.pulsaView
            self.navigator.controller = self
            
            self.pulsaView.navigator = self.navigator
            
            self.pulsaView.didAskedForLogin = { [unowned self] in
                self.navigator.navigateToLoginIfRequired()
            }
            
            self.pulsaView.didTapProduct = { [unowned self] products in
                self.navigator.navigateToPulsaProduct(products, selectedOperator: self.pulsaView.selectedOperator)
            }
            
            self.pulsaView.didTapOperator = { [unowned self] operators in
                self.navigator.navigateToPulsaOperator(operators)
            }
            
            self.pulsaView.didSuccessPressBuy = { [unowned self] url in
                self.navigator.navigateToWKWebView(url)
            }
            
            //            self.pulsaView.didSuccessPressBuy = { [unowned self] (category) in
            //                self.navigator.navigateToCart(category)
            //            }
            
            self.pulsaView.didTapAddressbook = { [unowned self] in
                AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Click Phonebook Icon")
                self.navigator.navigateToAddressBook()
            }
            
            self.pulsaView.didShowAlertPermission = { [unowned self] in
                let alert = UIAlertController(title: "", message: "Aplikasi Tokopedia tidak dapat mengakses kontak kamu. Aktifkan terlebih dahulu di menu : Settings -> Privacy -> Contacts", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aktifkan", style: .default, handler: { action in
                    switch action.style {
                    case .default:
                        JLContactsPermission.sharedInstance().displayAppSystemSettings()
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        self.requestManager.didNotSuccessReceiveCategory = {
            self.isRequestingPulsaWidget = false
        }
    }
    
    private func requestOfficialStore() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        _ = NetworkProvider<MojitoTarget>()
            .request(.requestOfficialStoreHomePage)
            .map(to: [OfficialStoreHomeItem.self], fromKey: "data")
            .subscribe(onNext: { [weak self] result in
                guard let `self` = self else { return }
                
                self.isRequestingOfficialStore = false
                self.officialStoreRequestSuccess = true
                let shops = result
                
                guard !shops.isEmpty else { return }
                
                let officialStoreSection = OfficialStoreSectionViewController(shops: shops)
                
                self.addChildViewController(officialStoreSection)
                self.officialStorePlaceholder.addSubview(officialStoreSection.view)
                
                officialStoreSection.view.mas_makeConstraints { make in
                    make?.edges.equalTo()(self.officialStorePlaceholder)
                }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    self.isRequestingOfficialStore = false
            })
    }
    
    private func requestTicker() {
        self.tickerRequest = AnnouncementTickerRequest()
        self.canRequestTicker = false
        self.tickerRequest.fetchTicker({ [unowned self] ticker in
            self.canRequestTicker = true
            if ticker.tickers.count > 0 {
                
                let randomIndex = Int(arc4random_uniform(UInt32(ticker.tickers.count)))
                let tick = ticker.tickers[randomIndex]
                self.tickerPlaceholder.isHidden = false
                
                if self.tickerView == nil {
                    
                    self.tickerView = AnnouncementTickerView(message: tick.message, colorHexString: tick.color)
                    self.tickerPlaceholder.addSubview((self.tickerView)!)
                    
                    self.tickerView.onTapMessageWithUrl = { [weak self] url in
                        self!.navigator.navigateToWebTicker(url!)
                    }
                    
                    self.tickerView.onTapCloseButton = { [unowned self] in
                        self.canRequestTicker = false
                        self.tickerPlaceholder.isHidden = true
                    }
                    
                    self.outerStackView.insertArrangedSubview(self.tickerPlaceholder, at: 1)
                    
                    self.tickerPlaceholder.mas_makeConstraints { make in
                        make?.left.right().equalTo()(self.view)
                    }
                    
                    self.tickerView.mas_makeConstraints { make in
                        make?.left.right().equalTo()(self.view)
                        make?.top.bottom().equalTo()(self.tickerPlaceholder)
                    }
                    
                    self.tickerPlaceholder.addSubview(self.tickerView)
                }
                
                self.tickerView.setMessage(tick.message, withContentColorHexString: tick.color)
                
            } else {
                
                self.tickerPlaceholder.isHidden = true
            }
            
        }) { _ in
            self.canRequestTicker = true
        }
    }
    
    private func requestTokocash() {
        
        guard let phoneNumber = self.userManager.getUserPhoneNumber(),
            !phoneNumber.isEmpty else {
            return
        }
        
        WalletService.getTokoCash(userId: self.userManager.getUserId(), phoneNumber: phoneNumber)
            .subscribe(onNext: { [weak self] wallet in
                if wallet.isExpired() {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_FORCE_LOGOUT"), object: nil)
                } else {
                    let tokocash = TokoCashSectionViewController(wallet: wallet)
                    self?.addChildViewController(tokocash)
                    self?.tokocashPlaceholder.addSubview(tokocash.view)
                    tokocash.view.mas_makeConstraints { make in
                        make?.edges.equalTo()(self?.tokocashPlaceholder)
                    }
                    
                    self?.tokocashPlaceholder.mas_makeConstraints { make in
                        make?.left.right().equalTo()(self?.view)
                        make?.height.mas_equalTo()(tokocash.view.frame.height)
                    }
                    
                    self?.tokocashPlaceholder.isHidden = false
                }
            }, onError: { [weak self] _ in
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_FORCE_LOGOUT"), object: nil)
            }).disposed(by: self.rx_disposeBag)
    }
    
    private func navigateToIntermediaryPage() {
        let viewController = UIViewController()
        viewController.view.frame = (self.navigationController?.viewControllers.last?.view.frame)!
        viewController.view.backgroundColor = .white
        viewController.hidesBottomBarWhenPushed = true
        viewController.showWaitOverlay()
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: Method
    
    private func didTapCategory(layoutRow: HomePageCategoryLayoutRow) {
        
        let categoryName = layoutRow.name
        
        AnalyticsManager.trackEventName("clickCategory", category: GA_EVENT_CATEGORY_HOMEPAGE, action: GA_EVENT_ACTION_CLICK, label: categoryName)
        AnalyticsManager.localyticsEvent("Event : Clicked Category", attributes: ["Category Name": categoryName ?? ""])
        
        if layoutRow.type == LayoutRowType.Marketplace.rawValue {
            let navigateViewController = NavigateViewController()
            navigateViewController.navigateToIntermediaryCategory(from: self, withCategoryId: layoutRow.category_id, categoryName: categoryName, isIntermediary: true)
        } else if layoutRow.type == LayoutRowType.Digital.rawValue {
            guard let categoryId = layoutRow.category_id else {
                TPRoutes.routeURL(URL(string: layoutRow.url)!)
                return
            }
            
            //tokocash ID = 103
            if categoryId == "103" {
                self.authenticationService.ensureLoggedInFromViewController(self, onSuccess: {
                    self.navigateToIntermediaryPage()
                    WalletService.getBalance(userId: self.userManager.getUserId())
                        .subscribe(onNext: { wallet in
                            self.navigationController?.popViewController(animated: false)
                            if wallet.isExpired() {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_FORCE_LOGOUT"), object: nil)
                            } else {
                                TPRoutes.routeURL(URL(string: (wallet.data?.action?.applinks)!)!)
                            }
                        }, onError: { error in
                            self.navigationController?.popViewController(animated: false)
                            let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
                            stickyAlertView?.show()
                        })
                        .disposed(by: self.rx_disposeBag)
                })
            } else {
                TPRoutes.routeURL(URL(string: layoutRow.url)!)
            }
            
        }
    }
}
