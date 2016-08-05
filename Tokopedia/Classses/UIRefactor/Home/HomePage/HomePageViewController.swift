//
//  HomePageViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
@objc

class HomePageViewController: UIViewController, iCarouselDelegate, SwipeViewDelegate, LoginViewDelegate {
    
    private var slider: iCarousel!
    private var digitalGoodsSwipeView: SwipeView!
    private var bannerView: UIImageView!
    private var sliderView: UIView!
    private var carouselDataSource: CarouselDataSource!
    private var digitalGoodsDataSource: DigitalGoodsDataSource!
    private var categoryDataSource: CategoryDataSource!
    
    
    private var banner: [Slide!]!
    private var loadIndicator: UIActivityIndicatorView!
    private var tickerRequest: AnnouncementTickerRequest!
    private var tickerView: AnnouncementTickerView!
    
    var pulsaView = PulsaView!()
    var prefixes = Dictionary<String, Dictionary<String, String>>()
    var requestManager = PulsaRequest!()
    
    
    var carouselView: UIView!
    var pulsaPlaceholder: UIView!
    var categoryView: UIView!
    var collectionView: UICollectionView!
    
    
    private let sliderHeight: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 225.0 : 175.0
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    
    init() {
        super.init(nibName: "HomePageViewController", bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.categoryDataSource = CategoryDataSource()
        self.categoryDataSource.delegate = self
        
        let flow = UICollectionViewFlowLayout()
        
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: flow)
        self.collectionView.dataSource = self.categoryDataSource
        self.collectionView.delegate = self.categoryDataSource
        self.collectionView.backgroundColor = UIColor.redColor()
        self.collectionView.contentSize = self.view.bounds.size
        
        let cellNib = UINib(nibName: "CategoryViewCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryViewCellIdentifier")
        
        self.view.addSubview(self.collectionView)

        self.carouselView = UIView(frame: CGRectZero)
        self.view.addSubview((self.carouselView)!)
        
        self.pulsaPlaceholder = UIView(frame: CGRectZero)
        self.view.addSubview(self.pulsaPlaceholder)
        
        self.collectionView.mas_makeConstraints { make in
            make.left.equalTo()(self.view.mas_left)
            make.right.equalTo()(self.view.mas_right)
            make.top.equalTo()(self.pulsaPlaceholder.mas_bottom).offset()(10)
        }
        
        tickerRequest = AnnouncementTickerRequest()
        self.loadBanners()
        self.requestTicker()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Bordered, target: self, action: nil)
        
        let timer = NSTimer(timeInterval: 5.0, target: self, selector: #selector(moveToNextSlider), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        TPAnalytics.trackScreenName("Top Category")
        self.collectionView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        let bannersStore = HomePageViewController.self.TKP_rootController().storeManager().homeBannerStore
        bannersStore.stopBannerRequest()
    }
    
    // MARK: - Request Banner
    func loadBanners() {
        let bannersStore = HomePageViewController.self.TKP_rootController().storeManager().homeBannerStore
        
        let backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        
        
        bannersStore.fetchBannerWithCompletion({[weak self] (banner, error) in
            self!.banner = banner
            self!.slider = iCarousel(frame: CGRectMake(0, 0, self!.screenWidth, self!.sliderHeight))
            self!.slider.backgroundColor = backgroundColor
            
            self!.carouselDataSource = CarouselDataSource(banner: banner)
            self!.carouselDataSource.delegate = self
            
            self!.slider.type = .Linear
            self!.slider.dataSource = self!.carouselDataSource
            self!.slider.delegate = self!.carouselDataSource
            self!.slider.decelerationRate = 0.5
            
            
            self?.carouselView .addSubview(self!.slider)
            self?.carouselView.mas_makeConstraints { make in
                make.top.equalTo()(self!.view.mas_top)
                make.left.equalTo()(self!.view.mas_left)
                make.right.equalTo()(self!.view.mas_right)
            }
            
            self?.slider.mas_makeConstraints { make in
                make.height.equalTo()(175)
                make.top.equalTo()(self?.carouselView.mas_top)
                make.left.equalTo()(self?.carouselView.mas_left)
                make.right.equalTo()(self?.carouselView.mas_right)
                make.bottom.equalTo()(self?.carouselView.mas_bottom)
            }
            
            self!.pulsaPlaceholder.mas_makeConstraints { make in
                make.left.equalTo()(self!.view.mas_left)
                make.right.equalTo()(self!.view.mas_right)
                make.top.equalTo()(self!.carouselView.mas_bottom).offset()(10)
            }
            
            self?.collectionView.mas_makeConstraints { make in
                make.top.equalTo()(self?.pulsaPlaceholder.mas_bottom)
                make.left.equalTo()(self?.view.mas_left)
                make.right.equalTo()(self?.view.mas_right)
                make.bottom.equalTo()(self?.view.mas_bottom)
            }
        })
        
        
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

            
            let container = UIView(frame: CGRectZero)
            self.pulsaView = PulsaView(categories: sortedCategories)
            self.pulsaView.attachToView(self.pulsaPlaceholder)
            
            self.pulsaView.didAskedForLogin = {
                let navigation = UINavigationController()
                navigation.navigationBar.backgroundColor = UIColor(red: (18.0/255.0), green: (199.0/255.0), blue: (0/255.0), alpha: 1)
                navigation.navigationBar.translucent = false
                navigation.navigationBar.tintColor = UIColor.whiteColor()
                
                let controller = LoginViewController()
                controller.isPresentedViewController = true
                controller.redirectViewController = self
                controller.delegate = self
                
                navigation.viewControllers = [controller]
                
                self.navigationController?.presentViewController(navigation, animated: true, completion: nil)
            }
            
            self.pulsaView.didSuccessPressBuy = { url in
                let controller = WebViewController()
                controller.strURL = url.absoluteString
                
                self.navigationController!.pushViewController(controller, animated: true)
            }
            
            self.requestManager.requestOperator()
            self.requestManager.didReceiveOperator = { operators in
                var sortedOperators = operators
                
                sortedOperators.sortInPlace({
                    $0.attributes.weight < $1.attributes.weight
                })
                
                self.didReceiveOperator(sortedOperators)
            }
            
//            self.categoryDataSource.pulsaContainer = self.pulsaView
        }
        
        
    }
    
    func didReceiveOperator(operators: [PulsaOperator]) {
        //mapping operator by prefix
        // {0812 : {"image" : "simpati.png", "id" : "1"}}
        for op in operators {
            for var prefix in op.attributes.prefix {
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
        
        self.pulsaView.addActionNumberField();
        self.pulsaView.didPrefixEntered = { [unowned self] operatorId, categoryId in
            //            let debounced = Debouncer(delay: 1.0) {
            self.pulsaView.selectedOperator = self.findOperatorById(operatorId, operators: operators)
            
            self.requestManager.requestProduct(operatorId, categoryId: categoryId)
            self.requestManager.didReceiveProduct = { products in
                self.didReceiveProduct(products)
            }
            //            }
            //            debounced.call()
        }
        
        self.pulsaView.didTapAddressbook = { [unowned self] contacts in
            let controller = AddressBookViewController()
            controller.contacts = contacts
            controller.didTapContact = { [unowned self] contact in
                var phoneNumber = (contact.phones?.first?.number)!
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: nil)
                
                self.pulsaView.numberField.text = phoneNumber
                
                if(phoneNumber.characters.count >= 4) {
                    let prefix = phoneNumber.substringWithRange(Range<String.Index>(start: phoneNumber.startIndex.advancedBy(0), end: phoneNumber.startIndex.advancedBy(4)))
                    
                    self.pulsaView.setRightViewNumberField(prefix)
                }
            }
            
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func didReceiveProduct(products: [PulsaProduct]) {
        if(products.count > 0) {
            self.pulsaView.showBuyButton(products)
            self.pulsaView.didTapProduct = { [unowned self] products in
                let controller = PulsaProductViewController()
                var activeProducts: [PulsaProduct] = []
                
                products.map { product in
                    //                    if(product.attributes.status == 1) {
                    activeProducts.append(product)
                    //                    }
                }
                
                activeProducts.sortInPlace({
                    $0.attributes.weight < $1.attributes.weight
                })
                
                controller.products = activeProducts
                controller.didSelectProduct = { [unowned self] product in
                    self.pulsaView.selectedProduct = product
                    self.pulsaView.hideErrors()
                    self.pulsaView.productButton.setTitle(product.attributes.desc, forState: .Normal)
                }
                
                self.navigationController!.pushViewController(controller, animated: true)
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
    
    func requestTicker() {
        tickerRequest.fetchTicker({[weak self] (ticker) in
            if (ticker.tickers.count > 0) {
                let randomIndex = Int(arc4random_uniform(UInt32(ticker.tickers.count)))
                let tick = ticker.tickers[randomIndex]
                self!.tickerView = AnnouncementTickerView.newView()
                self!.tickerView.setTitle(tick.title)
                self!.tickerView.setMessage(tick.message)
                self!.tickerView.onTapMessageWithUrl = {[weak self] (url) in
                    self!.openWebViewWithURL(url)
                }
                
//                self!.categoryDataSource.ticker = self!.tickerView
                
            }
            
        }) { (error) in
            
        }
    }
    
    func swipeView(swipeView: SwipeView!, didSelectItemAtIndex index: Int) {
        let good: MiniSlide = digitalGoodsDataSource.goodsAtIndex(index)
        let webView = PulsaViewController()
//        webView.strTitle = "Tokopedia"
//        webView.strURL = good.redirect_url
        
        navigationController?.pushViewController(webView, animated: true)
    }
    
    func moveToNextSlider() {
        slider.scrollToItemAtIndex(slider.currentItemIndex + 1, duration: 1.0)
    }
    
    func openWebViewWithURL(url: NSURL) {
        let controller = WebViewController()
        controller.strURL = url.absoluteString
        controller.strTitle = "Mengarahkan..."
        controller.onTapLinkWithUrl = {[weak self] (url) in
            if url.absoluteString == "https://www.tokopedia.com/" {
                self!.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
