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

@IBDesignable
@objc

class HomePageViewController: UIViewController, LoginViewDelegate {
    
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
    private var categoryPlaceholder: OAStackView!
    private var homePageCategoryData: HomePageCategoryData?
    private var pulsaActiveCategories: [PulsaCategory]?
    
    private var topPicksPlaceholder = UIView()
    private var isTopPicksDataEmpty = true

    private var storeManager = TKPStoreManager()
    
    @IBOutlet private var homePageScrollView: UIScrollView!
    private var outerStackView: OAStackView!
    private lazy var layoutRows: [HomePageCategoryLayoutRow] = [HomePageCategoryLayoutRow]()
    private lazy var categoryVerticalView: OAStackView = OAStackView()
    
    private let sliderHeight: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 275.0 : 225.0
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    private let backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
    private let imageCategoryWidth: CGFloat = 25.0
    private let iconSeparatorGrayColor: UIColor = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1)
    private let horizontalStackViewSpacing: CGFloat = 30.0
    
    private var isRequestingCategory: Bool = false
    private var canRequestTicker: Bool = true
    private var isRequestingBanner: Bool = false
    private var isRequestingPulsaWidget: Bool = false
    private var isRequestingOfficialStore: Bool = false
    private var officialStoreRequestSuccess: Bool = false
    
    private let officialStorePlaceholder = UIView()
    
    init() {
        super.init(nibName: "HomePageViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homePageScrollView.keyboardDismissMode = .OnDrag
        self.initOuterStackView()
        self.initViewLayout()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if isRequestingBanner == false {
            self.requestBanner()
        }
        if canRequestTicker == true {
            self.requestTicker()
        }
        if pulsaActiveCategories == nil && isRequestingPulsaWidget == false {
            self.requestPulsaWidget()
        }
        if homePageCategoryData == nil && isRequestingCategory == false {
            self.requestCategory()
        }
        
        if !officialStoreRequestSuccess && !isRequestingOfficialStore {
            self.requestOfficialStore()
        }
        
        if isTopPicksDataEmpty {
            let topPicksWidgetViewController = TopPicksWidgetViewController()
            topPicksWidgetViewController.didGetTopPicksData = { [unowned self] in
                self.isTopPicksDataEmpty = false
            }
            self.addChildViewController(topPicksWidgetViewController)
            self.topPicksPlaceholder.addSubview(topPicksWidgetViewController.view)
            topPicksWidgetViewController.view.mas_makeConstraints { (make) in
                make.edges.mas_equalTo()(self.topPicksPlaceholder)
            }
        }
    
        AnalyticsManager.trackScreenName("Top Category")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let bannersStore = self.storeManager.homeBannerStore
        bannersStore.stopBannerRequest()
    }
    
    
    // MARK: Setup StackView
    
    private func initOuterStackView() {
        self.outerStackView = OAStackView()
        setStackViewAttribute(self.outerStackView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
        self.homePageScrollView.addSubview(self.outerStackView)
        setupOuterStackViewConstraint()
    }
    
    private func setStackViewAttribute(stackView: OAStackView, axis: UILayoutConstraintAxis ,alignment: OAStackViewAlignment, distribution: OAStackViewDistribution, spacing: CGFloat) {
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
    }
    
    private func setupOuterStackViewConstraint() {
        self.outerStackView.mas_makeConstraints { (make) in
            make.top.mas_equalTo()(self.homePageScrollView.mas_top)
            make.bottom.mas_equalTo()(self.homePageScrollView.mas_bottom)
            make.left.mas_equalTo()(self.homePageScrollView.mas_left)
            make.right.mas_equalTo()(self.homePageScrollView.mas_right)
            make.width.mas_equalTo()(self.view.mas_width)
        }
    }
    
    private func setCategoryTitleLabel(title: String) {
        HomePageHeaderSectionStyle.setHeaderTitle(forStackView: categoryVerticalView, title: title)
    }
    
    private func setIconImageContainerToIconStackView(iconStackView: OAStackView, withLayoutRow layoutRow: HomePageCategoryLayoutRow) {
        let url: NSURL? = NSURL(string: layoutRow.image_url)
        let iconImageView: UIImageView = UIImageView()
        if let url = url {
            iconImageView.setImageWithURL(url)
        }
        let imageViewContainer = UIView()
        imageViewContainer.addSubview(iconImageView)
        iconImageView.mas_makeConstraints({ (make) in
            make.left.equalTo()(imageViewContainer)
            make.centerY.equalTo()(imageViewContainer)
            make.height.width().mas_equalTo()(self.imageCategoryWidth)
        })
        iconImageView.contentMode = .ScaleAspectFit
        iconStackView.addArrangedSubview(imageViewContainer)
        imageViewContainer.mas_makeConstraints({ (make) in
            make.width.mas_equalTo()(self.imageCategoryWidth)
        })
    }
    
    private func setCategoryNameLabelContainerToIconStackView(iconStackView: OAStackView, withLayoutRow layoutRow: HomePageCategoryLayoutRow) -> UIView{
        let categoryNameContainer = UIView()
        let categoryNameLabel = UILabel()
        categoryNameLabel.text = layoutRow.name
        categoryNameLabel.font = UIFont.microTheme()
        categoryNameLabel.textColor = UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1.0)
        categoryNameLabel.textAlignment = .Left
        categoryNameLabel.numberOfLines = 2
        categoryNameContainer.addSubview(categoryNameLabel)
        categoryNameLabel.mas_makeConstraints({ (make) in
            make.left.right().mas_equalTo()(categoryNameContainer)
            make.centerY.mas_equalTo()(categoryNameContainer)
        })
        iconStackView.addArrangedSubview(categoryNameContainer)
        
        return categoryNameContainer
    }
    
    private func setTapGestureRecognizerToIconStackView(iconStackView: OAStackView, withLayoutRow layoutRow: HomePageCategoryLayoutRow) {
        let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizerWithHandler({ (recognizer, state, point) in
            self.didTapCategory(recognizer as! UITapGestureRecognizer)
        }) as! UITapGestureRecognizer
        
        iconStackView.addGestureRecognizer(tapGestureRecognizer)
        iconStackView.tag = Int(layoutRow.id)!
        self.layoutRows.append(layoutRow)
    }
    
    private func setHorizontalCategoryLayoutWithLayoutSections(layoutRows: [HomePageCategoryLayoutRow]) {
        var horizontalStackView = refreshHorizontalStackView()
        for (index,layoutRow) in layoutRows.enumerate() {
            let iconStackView = OAStackView()
            self.setStackViewAttribute(iconStackView, axis: .Horizontal, alignment: .Fill, distribution: .Fill, spacing: 8.0)
            self.setIconImageContainerToIconStackView(iconStackView, withLayoutRow: layoutRow)
            let categoryNameContainer = self.setCategoryNameLabelContainerToIconStackView(iconStackView, withLayoutRow: layoutRow)
            horizontalStackView.addArrangedSubview(iconStackView)
            self.setTapGestureRecognizerToIconStackView(iconStackView, withLayoutRow: layoutRow)
            
            if index % self.totalColumnInOneRow() == self.numberNeededToChangeRow() {
                self.categoryVerticalView.addArrangedSubview(horizontalStackView)
                horizontalStackView = refreshHorizontalStackView()
                if (index != layoutRows.count - 1) {
                    drawHorizontalIconSeparator()
                }
            } else if index == layoutRows.count - 1 {
                let verticalIconSeparator = UIView()
                verticalIconSeparator.backgroundColor = iconSeparatorGrayColor
                categoryNameContainer.addSubview(verticalIconSeparator)
                verticalIconSeparator.mas_makeConstraints({ (make) in
                    make.width.mas_equalTo()(1)
                    make.right.mas_equalTo()(categoryNameContainer).with().offset()(self.horizontalStackViewSpacing / 2)
                    make.top.mas_equalTo()(categoryNameContainer).with().offset()(5)
                    make.bottom.mas_equalTo()(categoryNameContainer).with().offset()(-5)
                })
                
                for _ in 1...self.totalColumnInOneRow() - (index % self.totalColumnInOneRow() + 1)
                {
                    let emptyIconView = UIView()
                    horizontalStackView.addArrangedSubview(emptyIconView)
                }
                self.categoryVerticalView.addArrangedSubview(horizontalStackView)
            } else {
                let verticalIconSeparator = UIView()
                verticalIconSeparator.backgroundColor = iconSeparatorGrayColor
                categoryNameContainer.addSubview(verticalIconSeparator)
                verticalIconSeparator.mas_makeConstraints({ (make) in
                    make.width.mas_equalTo()(1)
                    make.right.mas_equalTo()(categoryNameContainer).with().offset()(self.horizontalStackViewSpacing/2)
                    make.top.mas_equalTo()(categoryNameContainer).with().offset()(5)
                    make.bottom.mas_equalTo()(categoryNameContainer).with().offset()(-5)
                })
            }
        }
    }
    
    private func totalColumnInOneRow() -> Int {
        return UI_USER_INTERFACE_IDIOM() == .Pad ? 4 : 2
    }
    
    private func numberNeededToChangeRow() -> Int {
        return totalColumnInOneRow() - 1
    }
    
    private func setCategoryUpperSeparator() {
        HomePageHeaderSectionStyle.setHeaderUpperSeparator(forStackView: categoryVerticalView)
    }
    
    private func setOuterCategorySeparatorView() {
        let outerCategorySeparatorView = UIView()
        outerCategorySeparatorView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(10)
        })
        outerCategorySeparatorView.backgroundColor = UIColor(red: 241.0/255, green: 241.0/255, blue: 241.0/255, alpha: 1.0)
        categoryPlaceholder.addArrangedSubview(outerCategorySeparatorView)
    }
    
    private func setupOuterStackCategoryWithData(homePageCategoryData: HomePageCategoryData) {
        
        for (index,layout_section) in homePageCategoryData.layout_sections.enumerate() {
            
            setOuterCategorySeparatorView()
            categoryVerticalView = OAStackView()
            categoryVerticalView.layoutMarginsRelativeArrangement = true
            categoryVerticalView.layoutMargins = UIEdgeInsets(top: 5, left: 20, bottom: 0, right: 20)
            self.setStackViewAttribute(categoryVerticalView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
            
            setCategoryTitleLabel(layout_section.title)
            
            setCategoryUpperSeparator()
            
            setHorizontalCategoryLayoutWithLayoutSections(layout_section.layout_rows)
            
            self.categoryPlaceholder.addArrangedSubview(self.categoryVerticalView)
        }
        setOuterCategorySeparatorView()
    }
    
    private func initViewLayout() {
        self.sliderPlaceholder = UIView()
        self.sliderPlaceholder.backgroundColor = self.backgroundColor
        self.tickerPlaceholder = UIView(frame: CGRectZero)
        self.pulsaPlaceholder = UIView()
        self.categoryPlaceholder = OAStackView()
        self.setStackViewAttribute(self.categoryPlaceholder, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
        
        // init slider
        self.sliderPlaceholder.mas_makeConstraints { make in
            make.height.mas_equalTo()(self.sliderHeight)
        }
        self.outerStackView.addArrangedSubview(self.sliderPlaceholder)
        
        // init pulsa widget
        self.outerStackView.addArrangedSubview(self.pulsaPlaceholder)
        
        // init category
        self.outerStackView.addArrangedSubview(self.categoryPlaceholder)
        
        // init top picks
        self.outerStackView.addArrangedSubview(self.topPicksPlaceholder)
        
        self.outerStackView.addArrangedSubview(self.officialStorePlaceholder)
    }
    
    private func refreshHorizontalStackView() -> OAStackView {
        let horizontalStackView = OAStackView()
        self.setStackViewAttribute(horizontalStackView, axis: .Horizontal, alignment: .Fill, distribution: .FillProportionally, spacing: horizontalStackViewSpacing)
        horizontalStackView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(50)
        })
        return horizontalStackView
    }
    
    private func drawHorizontalIconSeparator() {
        let horizontalIconSeparator = UIView()
        horizontalIconSeparator.backgroundColor = iconSeparatorGrayColor
        self.categoryVerticalView.addArrangedSubview(horizontalIconSeparator)
        horizontalIconSeparator.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(1)
        })
    }
    
    // MARK: Request Method
    
    private func requestCategory() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        isRequestingCategory = true
        networkManager.requestWithBaseUrl(NSString.mojitoUrl(), path: "/api/v1/layout/category", method: .GET, parameter: nil, mapping: HomePageCategoryResponse.mapping(), onSuccess: { [unowned self] (mappingResult, operation) in
            self.isRequestingCategory = false
            let result: NSDictionary = (mappingResult as RKMappingResult).dictionary()
            let homePageCategoryResponse: HomePageCategoryResponse = result[""] as! HomePageCategoryResponse
            self.homePageCategoryData = homePageCategoryResponse.data
            self.setupOuterStackCategoryWithData(self.homePageCategoryData!)
        }) { [unowned self] (error) in
            self.isRequestingCategory = false
            let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
            stickyAlertView.show()
        }
    }
    
    private func requestBanner() {
        let bannersStore = self.storeManager.homeBannerStore
        
        let backgroundColor = self.backgroundColor
        isRequestingBanner = true
        bannersStore.fetchBannerWithCompletion({[unowned self] (banner, error) in
            self.isRequestingBanner = false
            guard banner != nil else {
                return
            }
            let homeSliderView = UINib(nibName: "HomeSliderView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! HomeSliderView
            homeSliderView.generateSliderView(withBanner: banner, withNavigationController: self.navigationController!)
            
            self.sliderPlaceholder.addSubview(homeSliderView)
            
            homeSliderView.mas_makeConstraints { make in
                make.edges.mas_equalTo()(self.sliderPlaceholder)
            }
            
            })
    }
    
    private func requestPulsaWidget() {
        self.requestManager = PulsaRequest()
        self.requestManager.requestCategory()
        isRequestingPulsaWidget = true
        self.requestManager.didReceiveCategory = { [unowned self] categories in
            self.isRequestingPulsaWidget = false
            self.pulsaActiveCategories = categories.filter({ (pulsaCategory) -> Bool in
                pulsaCategory.attributes.status == 1
            })
            
            var sortedCategories = self.pulsaActiveCategories!
            sortedCategories.sortInPlace({
                $0.attributes.weight < $1.attributes.weight
            })
            
            self.pulsaView = PulsaView(categories: sortedCategories)
            
            self.pulsaPlaceholder.removeAllSubviews()
            self.pulsaPlaceholder.backgroundColor = self.iconSeparatorGrayColor
            self.pulsaPlaceholder.addSubview(self.pulsaView)
            self.pulsaView.mas_makeConstraints({ (make) in
                make.top.bottom().equalTo()(self.pulsaPlaceholder)
                make.left.mas_equalTo()(self.pulsaPlaceholder).offset()(7)
                make.right.mas_equalTo()(self.pulsaPlaceholder).offset()(-7)
            })
            
            self.navigator = PulsaNavigator()
            self.navigator.pulsaView = self.pulsaView
            self.navigator.controller = self
            
            self.pulsaView.didAskedForLogin = { [unowned self] in
                self.navigator.loginDelegate = self
                self.navigator.navigateToLoginIfRequired()
            }
            
            self.pulsaView.didTapProduct = { [unowned self] products in
                self.navigator.navigateToPulsaProduct(products, selectedOperator: self.pulsaView.selectedOperator)
            }
            
            self.pulsaView.didTapOperator = { [unowned self] (operators) in
                self.navigator.navigateToPulsaOperator(operators)
            }
            
            self.pulsaView.didSuccessPressBuy = { [unowned self] (url) in
                self.navigator.navigateToSuccess(url)
            }
            
            self.pulsaView.didTapAddressbook = { [unowned self] in
                AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Click Phonebook Icon")
                self.navigator.navigateToAddressBook()
            }
            
            self.pulsaView.didShowAlertPermission = { [unowned self] in
                let alert = UIAlertController(title: "", message: "Aplikasi Tokopedia tidak dapat mengakses kontak kamu. Aktifkan terlebih dahulu di menu : Settings -> Privacy -> Contacts", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Aktifkan", style: .Default, handler: { (action) in
                    switch action.style{
                    case .Default:
                        JLContactsPermission.sharedInstance().displayAppSystemSettings()
                        
                    case .Cancel:
                        print("cancel")
                        
                    case .Destructive:
                        print("destructive")
                    }
                }))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        self.requestManager.didNotSuccessReceiveCategory = {
            self.isRequestingPulsaWidget = false
        }
    }
    
    private func requestOfficialStore() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.requestWithBaseUrl(
            NSString.mojitoUrl(),
            path: "/os/api/v1/brands/list",
            method: .GET,
            parameter: ["device":"ios"],
            mapping: V4Response.mappingWithData(OfficialStoreHomeItem.mapping()),
            onSuccess: { [weak self] (mappingResult, operation) in
                guard let `self` = self else { return }
                
                self.isRequestingOfficialStore = false
                self.officialStoreRequestSuccess = true
                
                let result = mappingResult.dictionary()[""] as! V4Response
                let shops = result.data as! [OfficialStoreHomeItem]
                
                guard !shops.isEmpty else { return }
                
                let officialStoreSection = OfficialStoreSectionViewController(shops: shops)
                
                self.addChildViewController(officialStoreSection)
                self.officialStorePlaceholder.addSubview(officialStoreSection.view)
                
                officialStoreSection.view.mas_makeConstraints { (make) in
                    make.edges.equalTo()(self.officialStorePlaceholder)
                }
            },
            onFailure: {error in
                self.isRequestingOfficialStore = false
            })
    }
    
    private func requestTicker() {
        tickerRequest = AnnouncementTickerRequest()
        canRequestTicker = false
        tickerRequest.fetchTicker({[unowned self] (ticker) in
            self.canRequestTicker = true
            if (ticker.tickers.count > 0) {
                
                let randomIndex = Int(arc4random_uniform(UInt32(ticker.tickers.count)))
                let tick = ticker.tickers[randomIndex]

                
                if self.tickerView == nil {
                    
                    self.tickerView = AnnouncementTickerView.init(message: tick.message, colorHexString: tick.color)
                    self.tickerPlaceholder.addSubview((self.tickerView)!)
                    
                    self.tickerView.onTapMessageWithUrl = {[weak self] (url) in
                        self!.navigator.navigateToWebTicker(url)
                    }
                    
                    self.tickerView.onTapCloseButton = {[unowned self] in
                        self.canRequestTicker = false
                        self.outerStackView.removeArrangedSubview(self.tickerView)
                        self.tickerView.removeFromSuperview()
                    }
                    
                    self.outerStackView.insertArrangedSubview(self.tickerPlaceholder, atIndex: 0)
                    
                    self.tickerPlaceholder.mas_makeConstraints { make in
                        make.left.right().equalTo()(self.view)
                    }
                    
                    self.tickerView.mas_makeConstraints { make in
                        make.left.right().equalTo()(self.view)
                        make.top.bottom().equalTo()(self.tickerPlaceholder)
                    }
                    
                    self.tickerPlaceholder.addSubview(self.tickerView)
                }
                
                self.tickerView.setMessage(tick.message, withContentColorHexString: tick.color)
            }
        }) { (error) in
            self.canRequestTicker = true
        }
    }
    
    // MARK: Method
    
    private func didTapCategory(tapGestureRecognizer: UITapGestureRecognizer) {
        var selectedIconStackView = tapGestureRecognizer.view as! OAStackView
        
        for layoutRow in layoutRows {
            if Int(layoutRow.id) == selectedIconStackView.tag {
                let categoryName = layoutRow.name
                
                AnalyticsManager.trackEventName("clickCategory", category: GA_EVENT_CATEGORY_HOMEPAGE, action: GA_EVENT_ACTION_CLICK, label: categoryName)
                AnalyticsManager.localyticsEvent("Event : Clicked Category", attributes: ["Category Name" : categoryName])
                
                if (layoutRow.type == LayoutRowType.Marketplace.rawValue) {
                    let navigateViewController = NavigateViewController()
                    let categoryId = layoutRow.category_id
                    navigateViewController.navigateToCategoryFromViewController(self, withCategoryId: categoryId, categoryName: categoryName)
                    break
                } else if (layoutRow.type == LayoutRowType.Digital.rawValue) {
                    let webViewController = WebViewController()
                    let userManager = UserAuthentificationManager()
                    
                    webViewController.shouldAuthorizeRequest = true
                    webViewController.strURL = userManager.webViewUrlFromUrl(layoutRow.url)
                    webViewController.onTapLinkWithUrl = { [weak self] (url) in
                        if let weakSelf = self {
                            if url.absoluteString == "https://www.tokopedia.com/" {
                                weakSelf.navigationController?.popViewControllerAnimated(true)
                            }
                        }
                    }
                    self.navigationController?.pushViewController(webViewController, animated: true)
                    break
                }
            }
        }
    }
    
    //MARK: Login Delegate
    
    func redirectViewController(viewController: AnyObject!) {
        
    }
}
