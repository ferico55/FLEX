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

class HomePageViewController: UIViewController, LoginViewDelegate, UIScrollViewDelegate {
    
    var digitalGoodsDataSource: DigitalGoodsDataSource!
    var carouselDataSource: CarouselDataSource!
    
    var tickerRequest: AnnouncementTickerRequest!
    var tickerView: AnnouncementTickerView!
    
    var pulsaView = PulsaView!()
    var prefixes = Dictionary<String, Dictionary<String, String>>()
    var requestManager = PulsaRequest!()
    var navigator = PulsaNavigator!()
    
    var sliderPlaceholder: UIView!
    var pulsaPlaceholder: OAStackView!
    var tickerPlaceholder: UIView!
    var miniSliderPlaceholder: UIView!
    var categoryPlaceholder: OAStackView!
    var keyboardManager: PulsaKeyboardManager!
    var isNeedRefreshPulsaView: Bool = true
    var customScrollViewIndicators: [UIView]!
    
    @IBOutlet var homePageScrollView: UIScrollView!
    private var outerStackView: OAStackView!
    
    private let sliderHeight: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 225.0 : 175.0
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    private let backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
    private let sliderHeightWithMargin = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 140.0 : 92.0 as CGFloat
    private let categoryColumnWidth: CGFloat = 70.0;
    
    init() {
        super.init(nibName: "HomePageViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.categoryDataSource = CategoryDataSource()
        //        self.categoryDataSource.delegate = self
        //
        //        flow.headerReferenceSize = CGSizeZero
        //
        //        self.collectionView.keyboardDismissMode = .Interactive
        //        self.collectionView.dataSource = self.categoryDataSource
        //        self.collectionView.delegate = self.categoryDataSource
        //        self.collectionView.backgroundColor = UIColor.whiteColor()
        //        self.collectionView.collectionViewLayout = flow
        //
        //        let cellNib = UINib(nibName: "CategoryViewCell", bundle: nil)
        //        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryViewCellIdentifier")
        //
        //        self.initViewLayout()
        //        self.requestPulsaWidget()
        //
        self.initKeyboardManager()
        self.initOuterStackView()
        self.initViewLayout()
        self.requestCategory()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.requestBanner()
        self.requestTicker()
        self.requestMiniSlider()
        self.requestPulsaWidget()
        
        TPAnalytics.trackScreenName("Top Category")
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let bannersStore = HomePageViewController.self.TKP_rootController().storeManager().homeBannerStore
        bannersStore.stopBannerRequest()
        
        self.keyboardManager.endObservingKeyboard()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.keyboardManager.beginObservingKeyboard()
    }
    
    // MARK: Setup StackView
    
    func initOuterStackView() {
        self.outerStackView = OAStackView()
        setStackViewAttribute(self.outerStackView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
        self.homePageScrollView.addSubview(self.outerStackView)
        setupOuterStackViewConstraint()
    }
    
    func setStackViewAttribute(stackView: OAStackView, axis: UILayoutConstraintAxis ,alignment: OAStackViewAlignment, distribution: OAStackViewDistribution, spacing: CGFloat) {
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
    }
    
    func setupBannerView() {
        self.requestBanner()
    }
    
    func setupOuterStackViewConstraint() {
        self.outerStackView.mas_makeConstraints { [weak self] (make) in
            if let weakSelf = self {
                make.top.mas_equalTo()(weakSelf.homePageScrollView.mas_top)
                make.bottom.mas_equalTo()(weakSelf.homePageScrollView.mas_bottom)
                make.left.mas_equalTo()(weakSelf.homePageScrollView.mas_left)
                make.right.mas_equalTo()(weakSelf.homePageScrollView.mas_right)
                make.width.mas_equalTo()(weakSelf.view.mas_width)
            }
        }
    }
    
    // MARK: Init Layout
    
    func initViewLayout() {
        self.sliderPlaceholder = UIView(frame: CGRectZero)
        self.sliderPlaceholder.backgroundColor = self.backgroundColor
        self.tickerPlaceholder = UIView(frame: CGRectZero)
        self.miniSliderPlaceholder = UIView(frame: CGRectZero)
        self.pulsaPlaceholder = OAStackView()
        self.setStackViewAttribute(self.pulsaPlaceholder, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
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
        self.categoryPlaceholder.mas_makeConstraints { (make) in
            make.left.mas_equalTo()(self.outerStackView.mas_left).with().offset()(20)
        }
        
    }
    
    // MARK: Keyboard Manager
    
    func initKeyboardManager() {
        self.keyboardManager = PulsaKeyboardManager()
        self.keyboardManager.homePageScrollView = self.homePageScrollView
    }
    
    // MARK: Request Method
    
    func requestCategory() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        networkManager.requestWithBaseUrl(NSString.mojitoUrl(), path: "/api/v1/layout/category", method: .GET, parameter: nil, mapping: HomePageCategoryResponse.mapping(), onSuccess: { (mappingResult, operation) in
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                if let weakSelf = self {
                    let result: NSDictionary = (mappingResult as RKMappingResult).dictionary()
                    let homePageCategoryResponse: HomePageCategoryResponse = result[""] as! HomePageCategoryResponse
                    let homePageCategoryData: HomePageCategoryData = homePageCategoryResponse.data
                    weakSelf.customScrollViewIndicators = [UIView]();
                    let verticalStackView = OAStackView()
                    for (index, layout_section) in homePageCategoryData.layout_sections.enumerate() {
                        let categoryTitlelabel: UILabel = UILabel()
                        categoryTitlelabel.text = layout_section.title
                        categoryTitlelabel.font = UIFont.largeTheme()
                        categoryTitlelabel.textColor = UIColor(red: 75.0/255, green: 75.0/255, blue: 75.0/255, alpha: 1.0)
                        categoryTitlelabel.mas_makeConstraints({ (make) in
                            make.height.equalTo()(38)
                        })
                        
                        
                        weakSelf.setStackViewAttribute(verticalStackView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
                        verticalStackView.addArrangedSubview(categoryTitlelabel)
                        
                        let horizontalScrollView = UIScrollView()
                        horizontalScrollView.tag = index
                        horizontalScrollView.delegate = self
                        horizontalScrollView.mas_makeConstraints({ (make) in
                            make.height.equalTo()(75)
                        })
                        horizontalScrollView.showsHorizontalScrollIndicator = false
                        
                        let horizontalStackView = OAStackView()
                        weakSelf.setStackViewAttribute(horizontalStackView, axis: .Horizontal, alignment: .Fill, distribution: .Fill, spacing: 0.0)
                        horizontalScrollView.addSubview(horizontalStackView)
                        horizontalStackView.mas_makeConstraints({ (make) in
                            make.top.mas_equalTo()(horizontalScrollView.mas_top)
                            make.bottom.mas_equalTo()(horizontalScrollView.mas_bottom)
                            make.left.mas_equalTo()(horizontalScrollView.mas_left)
                            make.right.mas_equalTo()(horizontalScrollView.mas_right)
                            make.height.mas_equalTo()(horizontalScrollView.mas_height)
                        })
                        
                        for layout_row in layout_section.layout_rows {
//                            let catLabel = UILabel()
//                            catLabel.text = layout_row.name
//                            catLabel.textAlignment = .Center
//                            catLabel.mas_makeConstraints({ (make) in
//                                make.width.mas_equalTo()(weakSelf.categoryColumnWidth)
//                            })
                            let iconStackView = OAStackView()
                            weakSelf.setStackViewAttribute(iconStackView, axis: .Vertical, alignment: .Fill, distribution: .Fill, spacing: 0.0)
                            let iconImageView = UIImageView(image: UIImage(named: "default_profile_picture"))
                            iconStackView.addArrangedSubview(iconImageView)
                            iconImageView.mas_makeConstraints({ (make) in
                                make.height.mas_equalTo()(20)
                            })
                            let categoryNameLabel = UILabel()
                            categoryNameLabel.text = layout_row.name
                            categoryNameLabel.font = UIFont.microTheme()
                            categoryNameLabel.textColor = UIColor(red: 153.0/255, green: 153.0/255, blue: 153.0/255, alpha: 1.0)
                            categoryNameLabel.textAlignment = .Center
                            categoryNameLabel.numberOfLines = 0
                            iconStackView.addArrangedSubview(categoryNameLabel)
                            iconStackView.mas_makeConstraints({ (make) in
                                make.width.mas_equalTo()(weakSelf.categoryColumnWidth)
                            })
                            horizontalStackView.addArrangedSubview(iconStackView)
                        }
                        
                        if (CGFloat(layout_section.layout_rows.count) * weakSelf.categoryColumnWidth > weakSelf.screenWidth) {
                            let customScrollView = UIView()
                            let customScrollViewIndicator = UIView()
                            weakSelf.customScrollViewIndicators.append(customScrollViewIndicator)
                            customScrollViewIndicator.backgroundColor = UIColor(red: 255.0/255, green: 87.0/255, blue: 34.0/255, alpha: 1.0)
                            customScrollView.addSubview(customScrollViewIndicator)
                            customScrollView.mas_makeConstraints({ (make) in
                                make.height.mas_equalTo()(2)
                            })
                            verticalStackView.addArrangedSubview(customScrollView)
                            let widthScrollBar = (weakSelf.screenWidth - 20) * ((weakSelf.screenWidth - 20) / (weakSelf.categoryColumnWidth * CGFloat(layout_section.layout_rows.count)))
                            customScrollViewIndicator.frame = CGRect(x: 0, y: 0, width: widthScrollBar, height: 2)
                        }
                        verticalStackView.addArrangedSubview(horizontalScrollView)
                        
                        var separatorView = UIView()
                        separatorView.mas_makeConstraints({ (make) in
                            make.height.mas_equalTo()(1)
                        })
                        separatorView.backgroundColor = UIColor(red: 235.0/255, green: 235.0/255, blue: 235.0/255, alpha: 1.0)
                        verticalStackView.addArrangedSubview(separatorView)
                    }
                    weakSelf.categoryPlaceholder.addArrangedSubview(verticalStackView)
                }
                })
            
            }) { (error) in
                let stickyAlertView = StickyAlertView(errorMessages: [error.localizedDescription], delegate: self)
                stickyAlertView.show()
        }
    }
    
    func requestBanner() {
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
            
            self.refreshCollectionViewHeaderSize()
            })
        
    }
    
    func mappingPrefixFromOperators(operators: [PulsaOperator]) {
        //mapping operator by prefix
        // {0812 : {"image" : "simpati.png", "id" : "1"}}
        operators.enumerate().forEach { id, op in
            op.attributes.prefix.map { prefix in
                var prefixDictionary = Dictionary<String, String>()
                prefixDictionary["image"] = op.attributes.image
                prefixDictionary["id"] = op.id
                
                //BOLT only had 3 chars prefix
                if(prefix.characters.count == 3) {
                    let range = 0...9
                    range.enumerate().forEach { index, element in
                        prefixes[prefix.stringByAppendingString(String(element))] = prefixDictionary
                    }
                } else {
                    prefixes[prefix] = prefixDictionary
                }
            }
            
        }
        
        if(prefixes.count > 0) {
            self.pulsaView.prefixes = self.prefixes
        }
    }
    
    func didReceiveOperator(operators: [PulsaOperator]) {
        self.mappingPrefixFromOperators(operators)
        
        self.pulsaView.addActionNumberField();
        self.pulsaView.refreshContainerSize = {
            self.refreshPulsaWidgetHeight()
        }
        
        self.pulsaView.didPrefixEntered = { operatorId, categoryId in
            self.pulsaView.selectedOperator = self.findOperatorById(operatorId, operators: operators)
            
            self.requestManager.requestProduct(operatorId, categoryId: categoryId)
            
            self.requestManager.didReceiveProduct = { products in
                self.didReceiveProduct(products)
            }
            
        }
        
        self.pulsaView.didTapAddressbook = { [unowned self] contacts in
            self.navigator.navigateToAddressBook(contacts)
        }
        
        self.pulsaView.didShowAlertPermission = {
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
    
    func didReceiveProduct(products: [PulsaProduct]) {
        if(products.count > 0) {
            self.pulsaView.showBuyButton(products)
            self.pulsaView.didTapProduct = { [unowned self] products in
                self.navigator.navigateToPulsaProduct(products)
            }
        }
    }
    
    func findOperatorById(id: String, operators: [PulsaOperator]) -> PulsaOperator{
        var foundOperator = PulsaOperator()
        operators.enumerate().forEach { index, op in
            if(op.id == id) {
                foundOperator = operators[index]
            }
        }
        
        return foundOperator
    }
    
    func redirectViewController(viewController: AnyObject!) {
        
    }
    
    func requestMiniSlider() {
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
                
                self.refreshCollectionViewHeaderSize()
                
            }
            
            })
    }
    
    func requestPulsaWidget() {
        guard self.isNeedRefreshPulsaView == true else {
            self.isNeedRefreshPulsaView = true
            return
        }
        self.requestManager = PulsaRequest()
        self.requestManager.requestCategory()
        self.requestManager.didReceiveCategory = { [unowned self] categories in
            var activeCategories: [PulsaCategory] = []
            categories.enumerate().forEach { id, category in
                if(category.attributes.status == 1) {
                    activeCategories.append(category)
                }
            }
            
            var sortedCategories = activeCategories
            sortedCategories.sortInPlace({
                $0.attributes.weight < $1.attributes.weight
            })
            
            self.pulsaView = PulsaView(categories: sortedCategories)
            self.pulsaView.mas_makeConstraints({ (make) in
                make.height.mas_equalTo()(100)
            })
            
            self.pulsaPlaceholder.removeAllSubviews()
            self.pulsaPlaceholder.addArrangedSubview(self.pulsaView)
            
            self.navigator = PulsaNavigator()
            self.navigator.pulsaView = self.pulsaView
            self.navigator.controller = self
            
            self.pulsaView.didAskedForLogin = {
                self.navigator.loginDelegate = self
                self.navigator.navigateToLoginIfRequired()
            }
            
            self.pulsaView.didSuccessPressBuy = { url in
                self.navigator.navigateToSuccess(url)
            }
            
            self.requestManager.requestOperator()
            self.requestManager.didReceiveOperator = { operators in
                var sortedOperators = operators
                
                sortedOperators.sortInPlace({
                    $0.attributes.weight < $1.attributes.weight
                })
                
                self.didReceiveOperator(sortedOperators)
            }
        }
    }
    
    func requestTicker() {
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
                
                self.tickerPlaceholder.mas_makeConstraints { make in
                    //                    make.top.equalTo()(self.collectionView.mas_top)
                    make.left.right().equalTo()(self.view)
                }
                
                
                self.tickerView.mas_makeConstraints { make in
                    make.left.right().equalTo()(self.view)
                    make.top.bottom().equalTo()(self.tickerPlaceholder)
                }
                
                self.refreshCollectionViewHeaderSize()
            }
            
        }) { (error) in
            
        }
    }
    
    func refreshCollectionViewHeaderSize() {
        let debounced = Debouncer(delay: 0.1) {
            //            self.flow.headerReferenceSize = CGSizeMake(self.view.frame.width, self.miniSliderPlaceholder.frame.origin.y + self.miniSliderPlaceholder.frame.size.height)
            
        }
        debounced.call()
    }
    
    func refreshPulsaWidgetHeight() {
        self.pulsaView.mas_updateConstraints { (make) in
            make.height.mas_equalTo()(220)
        }
        super.updateViewConstraints()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.customScrollViewIndicators[scrollView.tag].frame.origin.x = scrollView.contentOffset.x * ((screenWidth - 20) / scrollView.contentSize.width)
    }
}
