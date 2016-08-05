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
@objc class HomePageViewController: UIViewController, iCarouselDelegate, SwipeViewDelegate, LoginViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
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
        
        collectionView.contentSize = view.bounds.size
        
        loadIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 30))
        collectionView.addSubview(loadIndicator)
        
        loadIndicator.bringSubviewToFront(view)
        loadIndicator.startAnimating()
        
        categoryDataSource = CategoryDataSource()
        categoryDataSource.delegate = self
        
        collectionView.dataSource = categoryDataSource
        collectionView.delegate = categoryDataSource
        collectionView.backgroundColor = UIColor.whiteColor()
        
        let cellNib = UINib(nibName: "CategoryViewCell", bundle: nil)
        collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryViewCellIdentifier")
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "bannerCell")
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "tickerCell")
        collectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "miniSlideCell")
        
        tickerRequest = AnnouncementTickerRequest()
        
        let timer = NSTimer(timeInterval: 5.0, target: self, selector: #selector(moveToNextSlider), userInfo: nil, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Bordered, target: self, action: nil)
        
        self.loadBanners()
        self.requestTicker()
        
        TPAnalytics.trackScreenName("Top Category")
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
            self!.loadIndicator.stopAnimating()
            
            self!.banner = banner
            self!.slider = iCarousel(frame: CGRectMake(0, 0, self!.screenWidth, self!.sliderHeight))
            self!.slider.backgroundColor = backgroundColor
            
            self!.carouselDataSource = CarouselDataSource(banner: banner)
            self!.carouselDataSource.delegate = self
            
            self!.slider.type = .Linear
            self!.slider.dataSource = self!.carouselDataSource
            self!.slider.delegate = self!.carouselDataSource
            self!.slider.decelerationRate = 0.5
            
            self!.categoryDataSource.slider = self!.slider
            
            self!.collectionView.reloadData()
            })
        
//        bannersStore.fetchMiniSlideWithCompletion({[weak self] (slide, error) in
//            if slide != nil {
//                self!.digitalGoodsSwipeView = SwipeView(frame: CGRectMake(0, 0, self!.screenWidth, 120.0))
//                self!.digitalGoodsSwipeView.backgroundColor = backgroundColor
//                self!.digitalGoodsDataSource = DigitalGoodsDataSource(goods: slide, swipeView: self!.digitalGoodsSwipeView)
//                self!.digitalGoodsSwipeView.dataSource = self!.digitalGoodsDataSource
//                self!.digitalGoodsSwipeView.delegate = self
//                self!.digitalGoodsSwipeView.clipsToBounds = true
//                self!.digitalGoodsSwipeView.truncateFinalPage = true
//                self!.digitalGoodsSwipeView.decelerationRate = 0.5
//                
//                if (UI_USER_INTERFACE_IDIOM() == .Pad) {
//                    self!.digitalGoodsSwipeView.alignment = .Center
//                    self!.digitalGoodsSwipeView.isCenteredChild = true
//                }
//                
//                self!.categoryDataSource.digitalGoodsSwipeView = self!.digitalGoodsSwipeView
//                
//                self!.collectionView.reloadData()
//            }
//            
//            })
        
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
            
            self.categoryDataSource.pulsaContainer = self.pulsaView
            self.collectionView.reloadData()
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
        self.collectionView.reloadData()
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
                
                self!.categoryDataSource.ticker = self!.tickerView
                
            }
            
            self!.collectionView.reloadData()
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
