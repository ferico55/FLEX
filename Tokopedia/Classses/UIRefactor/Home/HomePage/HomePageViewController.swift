//
//  HomePageViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class HomePageViewController: UIViewController, iCarouselDelegate, SwipeViewDelegate {
    
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
    
    private let sliderHeight: CGFloat = (UI_USER_INTERFACE_IDIOM() == .Pad) ? 225.0 : 175.0
    private let screenWidth = UIScreen.mainScreen().bounds.size.width
    
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
        
        bannersStore.fetchMiniSlideWithCompletion({[weak self] (slide, error) in
            if slide != nil {
                self!.digitalGoodsSwipeView = SwipeView(frame: CGRectMake(0, 0, self!.screenWidth, 120.0))
                self!.digitalGoodsSwipeView.backgroundColor = backgroundColor
                self!.digitalGoodsDataSource = DigitalGoodsDataSource(goods: slide, swipeView: self!.digitalGoodsSwipeView)
                self!.digitalGoodsSwipeView.dataSource = self!.digitalGoodsDataSource
                self!.digitalGoodsSwipeView.delegate = self
                self!.digitalGoodsSwipeView.clipsToBounds = true
                self!.digitalGoodsSwipeView.truncateFinalPage = true
                self!.digitalGoodsSwipeView.decelerationRate = 0.5
                
                if (UI_USER_INTERFACE_IDIOM() == .Pad) {
                    self!.digitalGoodsSwipeView.alignment = .Center
                    self!.digitalGoodsSwipeView.isCenteredChild = true
                }
                
                self!.categoryDataSource.digitalGoodsSwipeView = self!.digitalGoodsSwipeView
                
                self!.collectionView.reloadData()
            }
            
            })
    }
    
    func requestTicker() {
        tickerRequest.fetchTicker({[weak self] (ticker) in
            if (ticker.tickers.count > 0) {
                let tick = ticker.tickers[0]
                self!.tickerView = AnnouncementTickerView.newView()
                self!.tickerView.setTitle(tick.title)
                self!.tickerView.setMessage(tick.message)
                
                self!.categoryDataSource.ticker = self!.tickerView
                
                self!.collectionView.reloadData()
            }
        }) { (error) in
            
        }
    }
    
    func swipeView(swipeView: SwipeView!, didSelectItemAtIndex index: Int) {
        let good: MiniSlide = digitalGoodsDataSource.goodsAtIndex(index)
        let webView: WebViewController = WebViewController()
        webView.strTitle = "Tokopedia"
        webView.strURL = good.redirect_url
        
        navigationController?.pushViewController(webView, animated: true)
    }
    
    func moveToNextSlider() {
        slider.scrollToItemAtIndex(slider.currentItemIndex + 1, duration: 1.0)
    }
}
