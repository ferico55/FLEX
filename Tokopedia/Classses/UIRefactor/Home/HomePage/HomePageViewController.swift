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

class HomePageViewController: UIViewController, iCarouselDelegate, LoginViewDelegate, SwipeViewDelegate {
    
    var slider: iCarousel!
    var digitalGoodsSwipeView: SwipeView!
    var digitalGoodsDataSource: DigitalGoodsDataSource!
    var carouselDataSource: CarouselDataSource!
    var categoryDataSource: CategoryDataSource!
    
    var banner: [Slide!]!
    var tickerRequest: AnnouncementTickerRequest!
    var tickerView: AnnouncementTickerView!
    
    var pulsaView = PulsaView!()
    var prefixes = Dictionary<String, Dictionary<String, String>>()
    var requestManager = PulsaRequest!()
    var navigator = PulsaNavigator!()
    
    var sliderPlaceholder: UIView!
    var pulsaPlaceholder: UIView!
    var tickerPlaceholder: UIView!
    var miniSliderPlaceholder: UIView!
    var keyboardManager: PulsaKeyboardManager!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var flow: UICollectionViewFlowLayout!
   
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

        self.collectionView.keyboardDismissMode = .Interactive
        self.categoryDataSource = CategoryDataSource()
        self.categoryDataSource.delegate = self
        
        flow.headerReferenceSize = CGSizeZero
        
        self.collectionView.dataSource = self.categoryDataSource
        self.collectionView.delegate = self.categoryDataSource
        self.collectionView.backgroundColor = UIColor.whiteColor()
        self.collectionView.collectionViewLayout = flow
        
        let cellNib = UINib(nibName: "CategoryViewCell", bundle: nil)
        self.collectionView.registerNib(cellNib, forCellWithReuseIdentifier: "CategoryViewCellIdentifier")

        self.sliderPlaceholder = UIView(frame: CGRectZero)
        self.sliderPlaceholder.backgroundColor = UIColor(red: 242/255.0, green: 242/255.0, blue: 242/255.0, alpha: 1.0)
        self.pulsaPlaceholder = UIView(frame: CGRectZero)
        self.pulsaPlaceholder.backgroundColor = UIColor.whiteColor()
        self.tickerPlaceholder = UIView(frame: CGRectZero)
        self.miniSliderPlaceholder = UIView(frame: CGRectZero)
        
        self.collectionView.addSubview(self.tickerPlaceholder)
        self.collectionView.addSubview(self.sliderPlaceholder)
        self.collectionView.addSubview(self.pulsaPlaceholder)
        self.collectionView.addSubview(self.miniSliderPlaceholder)

        self.requestBanner()
        self.requestTicker()
        self.requestPulsaWidget()
        self.requestMiniSlider()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .Bordered, target: self, action: nil)
       
        self.keyboardManager = PulsaKeyboardManager()
        self.keyboardManager.collectionView = self.collectionView
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

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
    
    func requestBanner() {
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
            
            self?.sliderPlaceholder .addSubview(self!.slider)
            self?.collectionView.bringSubviewToFront((self?.sliderPlaceholder)!)
            self?.collectionView.bringSubviewToFront((self?.miniSliderPlaceholder)!)
            
            self?.sliderPlaceholder.mas_makeConstraints { make in
                make.top.equalTo()(self!.tickerPlaceholder.mas_bottom)
                make.left.equalTo()(self!.view.mas_left)
                make.right.equalTo()(self!.view.mas_right)
            }
            
            self?.slider.mas_makeConstraints { make in
                make.height.equalTo()(self!.sliderHeight)
                make.top.equalTo()(self?.sliderPlaceholder.mas_top)
                make.left.equalTo()(self?.sliderPlaceholder.mas_left)
                make.right.equalTo()(self?.sliderPlaceholder.mas_right)
                make.bottom.equalTo()(self?.sliderPlaceholder.mas_bottom).offset()(-10)
            }
            
            self?.pulsaPlaceholder.mas_makeConstraints { make in
                make.left.equalTo()(self?.sliderPlaceholder.mas_left)
                make.right.equalTo()(self?.sliderPlaceholder.mas_right)
                make.top.equalTo()(self!.sliderPlaceholder?.mas_bottom)
            }
            
            self?.miniSliderPlaceholder.mas_makeConstraints { make in
                make.left.equalTo()(self?.sliderPlaceholder.mas_left)
                make.right.equalTo()(self?.sliderPlaceholder.mas_right)
                make.top.equalTo()(self!.pulsaPlaceholder?.mas_bottom)
            }
            
            let timer = NSTimer(timeInterval: 5.0, target: self!, selector: #selector(self!.moveToNextSlider), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)

            self?.refreshCollectionViewSize()
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
        self.pulsaView.invalidateViewHeight = {
            let debounced = Debouncer(delay: 0.1) {
                self.refreshCollectionViewSize()
            }
            
            debounced.call()
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
        bannersStore.fetchMiniSlideWithCompletion({[weak self] (slide, error) in
            if slide != nil {
                self!.digitalGoodsSwipeView = SwipeView(frame: CGRectMake(0, 0, self!.screenWidth, 92.0))
                self!.digitalGoodsDataSource = DigitalGoodsDataSource(goods: slide, swipeView: self!.digitalGoodsSwipeView)
                self!.digitalGoodsSwipeView.backgroundColor = UIColor(red: (242/255.0), green: (242/255.0), blue: (242/255.0), alpha: 1)
                self!.digitalGoodsSwipeView.dataSource = self!.digitalGoodsDataSource
                self!.digitalGoodsSwipeView.delegate = self
                self!.digitalGoodsSwipeView.clipsToBounds = true
                self!.digitalGoodsSwipeView.truncateFinalPage = true
                self!.digitalGoodsSwipeView.decelerationRate = 0.5
                
                self?.miniSliderPlaceholder .addSubview(self!.digitalGoodsSwipeView)
                
                
                self?.digitalGoodsSwipeView.mas_makeConstraints { make in
                    make.height.equalTo()(92)
                    make.top.equalTo()(self?.miniSliderPlaceholder.mas_top)
                    make.left.equalTo()(self?.miniSliderPlaceholder.mas_left)
                    make.right.equalTo()(self?.miniSliderPlaceholder.mas_right)
                    make.bottom.equalTo()(self?.miniSliderPlaceholder.mas_bottom)
                }
                
                
                
                if (UI_USER_INTERFACE_IDIOM() == .Pad) {
                    self!.digitalGoodsSwipeView.alignment = .Center
                    self!.digitalGoodsSwipeView.isCenteredChild = true
                }
                
                self?.refreshCollectionViewSize()
                
            }
            
        })
    }
    
    func requestPulsaWidget() {
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
            self.pulsaView.attachToView(self.pulsaPlaceholder)
            
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
        tickerRequest.fetchTicker({[weak self] (ticker) in
            
            if (ticker.tickers.count > 0) {
                let randomIndex = Int(arc4random_uniform(UInt32(ticker.tickers.count)))
                let tick = ticker.tickers[randomIndex]
                self!.tickerView = AnnouncementTickerView.newView()
                self?.tickerPlaceholder.addSubview((self?.tickerView)!)
                
                self!.tickerView.setTitle(tick.title)
                self!.tickerView.setMessage(tick.message)
                self!.tickerView.onTapMessageWithUrl = {[weak self] (url) in
                    self!.navigator.navigateToWebTicker(url)
                }
                
                self?.tickerPlaceholder.mas_makeConstraints { make in
                    make.top.equalTo()(self!.collectionView.mas_top)
                    make.left.equalTo()(self!.view.mas_left)
                    make.right.equalTo()(self!.view.mas_right)
                }
                
                
                self?.tickerView.mas_makeConstraints { make in
                    make.left.equalTo()(self?.view.mas_left)
                    make.right.equalTo()(self?.view.mas_right)
                    make.top.bottom().equalTo()(self?.tickerPlaceholder)
                }
                
                self?.refreshCollectionViewSize()
            }
            
        }) { (error) in
            
        }
    }
    
    func moveToNextSlider() {
        slider.scrollToItemAtIndex(slider.currentItemIndex + 1, duration: 1.0)
    }
    
    func refreshCollectionViewSize() {
        let debounced = Debouncer(delay: 0.1) {
            self.flow.headerReferenceSize = CGSizeMake(self.view.frame.width, self.miniSliderPlaceholder.frame.origin.y + self.miniSliderPlaceholder.frame.size.height)
        }
        
        debounced.call()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}
