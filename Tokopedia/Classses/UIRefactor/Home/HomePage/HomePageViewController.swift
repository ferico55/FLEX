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
    private var carouselDataSource: CarouselDataSource!
    
    private var tickerRequest: AnnouncementTickerRequest!
    private var tickerView: AnnouncementTickerView!
    
    private var pulsaView: PulsaView!
    private var prefixes = Dictionary<String, Dictionary<String, String>>()
    private var requestManager: PulsaRequest!
    private var navigator: PulsaNavigator!
    
    private var sliderPlaceholder: UIView!
    private var pulsaPlaceholder: OAStackView!
    private var tickerPlaceholder: UIView!
    private var miniSliderPlaceholder: UIView!
    private var categoryPlaceholder: OAStackView!
    private var homePageCategoryData: HomePageCategoryData?
    private var pulsaActiveCategories: [PulsaCategory]?
    
    @IBOutlet private var homePageScrollView: UIScrollView!
    private var outerStackView: OAStackView!
    private lazy var layoutRows: [HomePageCategoryLayoutRow] = [HomePageCategoryLayoutRow]()
    private lazy var categoryVerticalView: OAStackView = OAStackView()
    
    private let sliderHeight: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 225.0 : 175.0
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    private let backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
    private let sliderHeightWithMargin = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 140.0 : 92.0 as CGFloat
    private let categoryColumnWidth: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 83 : UIScreen.mainScreen().bounds.size.width * 0.225
    private let imageCategoryWidth: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 50 : 30
    private let categorySpacing: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 34 : UIScreen.mainScreen().bounds.size.width * 0.05
    private let imageViewContainerHeight: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 83 : 40
    
    init() {
        super.init(nibName: "HomePageViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initOuterStackView()
        self.initViewLayout()
        self.requestTicker()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.requestBanner()
        if pulsaActiveCategories == nil {
            self.requestPulsaWidget()
        }
        if homePageCategoryData == nil {
            self.requestCategory()
        }
        AnalyticsManager.trackScreenName("Top Category")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let bannersStore = HomePageViewController.self.TKP_rootController().storeManager().homeBannerStore
        bannersStore.stopBannerRequest()
    }
    
    
    // MARK: Setup StackView
    
    private func initOuterStackView() {
        self.outerStackView = OAStackView()
        setStackViewAttribute(self.outerStackView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 5.0)
        self.homePageScrollView.addSubview(self.outerStackView)
        setupOuterStackViewConstraint()
    }
    
    private func setStackViewAttribute(stackView: OAStackView, axis: UILayoutConstraintAxis ,alignment: OAStackViewAlignment, distribution: OAStackViewDistribution, spacing: CGFloat) {
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
    }
    
    private func setupBannerView() {
        self.requestBanner()
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
        let categoryTitlelabel: UILabel = UILabel()
        categoryTitlelabel.text = title
        categoryTitlelabel.font = UIFont.largeTheme()
        categoryTitlelabel.textColor = UIColor(red: 75.0/255, green: 75.0/255, blue: 75.0/255, alpha: 1.0)
        categoryTitlelabel.mas_makeConstraints({ (make) in
            make.height.equalTo()(38)
        })
        categoryVerticalView.addArrangedSubview(categoryTitlelabel)
    }
    
    private func setHorizontalCategoryLayoutWithLayoutSections(layoutRows: [HomePageCategoryLayoutRow]) {
        let horizontalScrollView = UIScrollView()
        horizontalScrollView.showsHorizontalScrollIndicator = false
        
        let horizontalStackView = OAStackView()
        self.setStackViewAttribute(horizontalStackView, axis: .Horizontal, alignment: .Fill, distribution: .Fill, spacing: self.categorySpacing)
        horizontalScrollView.addSubview(horizontalStackView)
        horizontalStackView.mas_makeConstraints({ (make) in
            make.top.mas_equalTo()(horizontalScrollView.mas_top)
            make.bottom.mas_equalTo()(horizontalScrollView.mas_bottom)
            make.left.mas_equalTo()(horizontalScrollView.mas_left)
            make.right.mas_equalTo()(horizontalScrollView.mas_right)
            make.height.mas_equalTo()(horizontalScrollView.mas_height)
        })
        
        for layoutRow in layoutRows {
            let iconStackView = OAStackView()
            self.setStackViewAttribute(iconStackView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
            
            let url: NSURL? = NSURL(string: layoutRow.image_url)
            let iconImageView: UIImageView = UIImageView()
            if let url = url {
                iconImageView.setImageWithURL(url)
            }
            let imageViewContainer = UIView()
            imageViewContainer.addSubview(iconImageView)
            iconImageView.mas_makeConstraints({ (make) in
                make.center.equalTo()(imageViewContainer)
                make.height.width().mas_equalTo()(self.imageCategoryWidth)
            })
            iconImageView.contentMode = .ScaleAspectFit
            iconStackView.addArrangedSubview(imageViewContainer)
            imageViewContainer.mas_makeConstraints({ (make) in
                make.height.mas_equalTo()(self.imageViewContainerHeight)
            })
            let categoryNameContainer = UIView()
            categoryNameContainer.mas_makeConstraints({ (make) in
                make.height.mas_equalTo()(40)
            })
            let categoryNameLabel = UILabel()
            categoryNameLabel.text = layoutRow.name
            categoryNameLabel.font = UIFont.microTheme()
            categoryNameLabel.textColor = UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1.0)
            categoryNameLabel.textAlignment = .Center
            categoryNameLabel.numberOfLines = 0
            categoryNameContainer.addSubview(categoryNameLabel)
            categoryNameLabel.mas_makeConstraints({ (make) in
                make.top.mas_equalTo()(0)
                make.centerX.mas_equalTo()(categoryNameContainer)
                make.width.mas_equalTo()(self.categoryColumnWidth)
            })
            
            iconStackView.addArrangedSubview(categoryNameContainer)
            iconStackView.mas_makeConstraints({ (make) in
                make.width.mas_equalTo()(self.categoryColumnWidth)
            })
            horizontalStackView.addArrangedSubview(iconStackView)
            
            // didSelectIconStackView
            
            let tapGestureRecognizer = UITapGestureRecognizer.bk_recognizerWithHandler({ (recognizer, state, point) in
                self.didTapCategory(recognizer as! UITapGestureRecognizer)
            }) as! UITapGestureRecognizer
            
            iconStackView.addGestureRecognizer(tapGestureRecognizer)
            iconStackView.tag = Int(layoutRow.id)!
            self.layoutRows.append(layoutRow)
        }
        
        categoryVerticalView.addArrangedSubview(horizontalScrollView)
    }
    
    private func setCategoryUpperSeparator() {
        let upperSeparatorView = UIView()
        upperSeparatorView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(2)
        })
        let tinyOrangeView = UIView()
        tinyOrangeView.backgroundColor = UIColor(red: 255.0/255, green: 87.0/255, blue: 34.0/255, alpha: 1.0)
        tinyOrangeView.frame = CGRect(x: 0, y: 0, width: 20, height: 2)
        upperSeparatorView.addSubview(tinyOrangeView)
        categoryVerticalView.addArrangedSubview(upperSeparatorView)
        let topEmptyView = UIView()
        topEmptyView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(25)
        })
        categoryVerticalView.addArrangedSubview(topEmptyView)
    }
    
    private func setBottomSeparatorView() {
        let bottomEmptyView = UIView()
        bottomEmptyView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(8)
        })
        categoryVerticalView.addArrangedSubview(bottomEmptyView)
        
        let bottomSeparatorView = UIView()
        bottomSeparatorView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(1)
        })
        bottomSeparatorView.backgroundColor = UIColor(red: 235.0/255, green: 235.0/255, blue: 235.0/255, alpha: 1.0)
        categoryVerticalView.addArrangedSubview(bottomSeparatorView)
    }
    
    private func setupOuterStackCategoryWithData(homePageCategoryData: HomePageCategoryData) {

        for layout_section in homePageCategoryData.layout_sections {
            categoryVerticalView = OAStackView()
            self.setStackViewAttribute(categoryVerticalView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
            setCategoryTitleLabel(layout_section.title)
            
            setCategoryUpperSeparator()
            
            setHorizontalCategoryLayoutWithLayoutSections(layout_section.layout_rows)
            
            setBottomSeparatorView()
            
            self.categoryPlaceholder.addArrangedSubview(self.categoryVerticalView)
        }
    }
    
    private func initViewLayout() {
        self.sliderPlaceholder = UIView(frame: CGRectZero)
        self.sliderPlaceholder.backgroundColor = self.backgroundColor
        self.tickerPlaceholder = UIView(frame: CGRectZero)
        self.miniSliderPlaceholder = UIView(frame: CGRectZero)
        self.pulsaPlaceholder = OAStackView()
        self.categoryPlaceholder = OAStackView()
        self.setStackViewAttribute(self.categoryPlaceholder, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 24.0)
        
        // init slider
        self.sliderPlaceholder.mas_makeConstraints { make in
            make.height.mas_equalTo()(self.sliderHeight)
        }
        self.outerStackView.addArrangedSubview(self.sliderPlaceholder)
        
        // init pulsa widget
        self.outerStackView.addArrangedSubview(self.pulsaPlaceholder)
        
        // init category
        self.categoryPlaceholder.layoutMarginsRelativeArrangement = true
        self.categoryPlaceholder.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        self.outerStackView.addArrangedSubview(self.categoryPlaceholder)
    }
    
    // MARK: Request Method
    
    private func requestCategory() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.mojitoUrl(), path: "/api/v1/layout/category", method: .GET, parameter: nil, mapping: HomePageCategoryResponse.mapping(), onSuccess: { [unowned self] (mappingResult, operation) in
                let result: NSDictionary = (mappingResult as RKMappingResult).dictionary()
                let homePageCategoryResponse: HomePageCategoryResponse = result[""] as! HomePageCategoryResponse
                self.homePageCategoryData = homePageCategoryResponse.data
                self.setupOuterStackCategoryWithData(self.homePageCategoryData!)
        }) { (error) in
            let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
            stickyAlertView.show()
        }
    }
    
    private func requestBanner() {
        let bannersStore = HomePageViewController.self.TKP_rootController().storeManager().homeBannerStore
        
        let backgroundColor = self.backgroundColor
        bannersStore.fetchBannerWithCompletion({[unowned self] (banner, error) in
            let slider = iCarousel(frame: CGRectMake(0, 0, self.screenWidth, self.sliderHeight))
            slider.backgroundColor = backgroundColor
            
            self.carouselDataSource = CarouselDataSource(banner: banner)
            self.carouselDataSource.delegate = self
            
            slider.type = .Linear
            slider.dataSource = self.carouselDataSource
            slider.delegate = self.carouselDataSource
            slider.decelerationRate = 0.5
            
            self.sliderPlaceholder .addSubview(slider)
            
            slider.mas_makeConstraints { make in
                make.height.equalTo()(self.sliderHeight)
                make.top.left().right().equalTo()(self.sliderPlaceholder)
                make.bottom.equalTo()(self.sliderPlaceholder.mas_bottom)
            }
            
            let timer = NSTimer.bk_timerWithTimeInterval(5.0, block: { (timer) in
                slider.scrollToItemAtIndex(slider.currentItemIndex + 1, duration: 1.0)
                }, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
            })
        
    }
    
    
    private func requestMiniSlider() {
        let bannersStore = HomePageViewController.self.TKP_rootController().storeManager().homeBannerStore
        
        bannersStore.fetchMiniSlideWithCompletion({[unowned self] (slide, error) in
            if slide != nil {
                let digitalGoodsSwipeView = SwipeView(frame: CGRectMake(0, 0, self.screenWidth, self.sliderHeightWithMargin))
                self.digitalGoodsDataSource = DigitalGoodsDataSource(goods: slide, swipeView: digitalGoodsSwipeView)
                self.digitalGoodsDataSource.delegate = self
                
                
                digitalGoodsSwipeView.backgroundColor = self.backgroundColor
                digitalGoodsSwipeView.dataSource = self.digitalGoodsDataSource
                digitalGoodsSwipeView.delegate = self.digitalGoodsDataSource
                digitalGoodsSwipeView.clipsToBounds = true
                digitalGoodsSwipeView.truncateFinalPage = true
                digitalGoodsSwipeView.decelerationRate = 0.5
                
                self.miniSliderPlaceholder .addSubview(digitalGoodsSwipeView)
                
                digitalGoodsSwipeView.mas_makeConstraints { make in
                    make.height.equalTo()(self.sliderHeightWithMargin)
                    make.top.left().right().bottom().equalTo()(self.miniSliderPlaceholder)
                }
                
                if (UI_USER_INTERFACE_IDIOM() == .Pad) {
                    digitalGoodsSwipeView.alignment = .Center
                    digitalGoodsSwipeView.isCenteredChild = true
                }
            }
            
            })
    }
    
    private func requestPulsaWidget() {
        self.requestManager = PulsaRequest()
        self.requestManager.requestCategory()
        self.requestManager.didReceiveCategory = { [unowned self] categories in
            self.pulsaActiveCategories = categories.filter({ (pulsaCategory) -> Bool in
                pulsaCategory.attributes.status == 1
            })
            
            var sortedCategories = self.pulsaActiveCategories!
            sortedCategories.sortInPlace({
                $0.attributes.weight < $1.attributes.weight
            })
            
            self.pulsaView = PulsaView(categories: sortedCategories)
            
            self.pulsaPlaceholder.removeAllSubviews()
            self.pulsaPlaceholder.addArrangedSubview(self.pulsaView)
            self.pulsaView.mas_makeConstraints({ (make) in
                make.top.left().right().bottom().equalTo()(self.pulsaPlaceholder)
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
            
            self.pulsaView.didSuccessPressBuy = { [unowned self] (url) in
                self.navigator.navigateToSuccess(url)
            }
            
            self.pulsaView.didTapAddressbook = { [unowned self] in
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
    }
    
    private func requestTicker() {
        tickerRequest = AnnouncementTickerRequest()
        tickerRequest.fetchTicker({[unowned self] (ticker) in
            
            if (ticker.tickers.count > 0) {
                let randomIndex = Int(arc4random_uniform(UInt32(ticker.tickers.count)))
                let tick = ticker.tickers[randomIndex]
                self.tickerView = AnnouncementTickerView.newView()
                self.tickerPlaceholder.addSubview((self.tickerView)!)
                
                self.tickerView.setTitle(tick.title)
                self.tickerView.setMessage(tick.message)
                self.tickerView.onTapMessageWithUrl = {[weak self] (url) in
                    self!.navigator.navigateToWebTicker(url)
                }
                
                // init ticker
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
            
        }) { (error) in
            
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
                    let userID = userManager.getUserId()
                    let currentDeviceId = userManager.getMyDeviceToken()
                    let jsTokopediaWebViewUrl = "https://js.tokopedia.com/wvlogin?uid=\(userID)&token=\(currentDeviceId)&url=" + layoutRow.url
                    webViewController.strURL = jsTokopediaWebViewUrl
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
