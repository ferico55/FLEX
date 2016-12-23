//
//  HomeSliderView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class HomeSliderView: UIView {
    
    @IBOutlet private var carouselPlaceholder: UIView!
    @IBOutlet private var seeAllPromoButton: UIButton!
    private var pageControlHeight: Int = 12
    private var customPageControl: StyledPageControl!
    
    @IBOutlet private var homeSliderAddOnView: UIView!
    private var carouselDataSource: CarouselDataSource!
    
    override func awakeFromNib() {
        setupCustomPageControl()
        setupSliderAddOnPromoButton()
    }
    
    private func setupCustomPageControl() {
        customPageControl = StyledPageControl()
        customPageControl.pageControlStyle = PageControlStyleDefault
        customPageControl.coreNormalColor = UIColor(red: 214.0/255.0, green: 214.0/255.0, blue: 214.0/255.0, alpha: 1)
        customPageControl.coreSelectedColor = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 34.0/255, alpha: 1)
        customPageControl.diameter = 11
        customPageControl.gapWidth = 5
        self.addSubview(customPageControl)
    }
    
    private func setupSliderAddOnPromoButton() {
        let userAuthManager = UserAuthentificationManager()
        self.seeAllPromoButton.bk_whenTapped {
            var userInfo: [String : Int]!
            if userAuthManager.isLogin {
                userInfo = ["page" : 3]
            } else {
                userInfo = ["page" : 2]
            }
            NSNotificationCenter.defaultCenter().postNotificationName("didSwipeHomePage", object: self, userInfo: userInfo)
        }
    }
    
    func generateSliderView(withBanner banner: [Slide], withNavigationController navigationController: UINavigationController) {
        let slider = iCarousel(frame: CGRectZero)
        slider.backgroundColor = backgroundColor
        self.carouselPlaceholder.addSubview(slider)
        slider.mas_makeConstraints{ make in
            make.edges.mas_equalTo()(self.carouselPlaceholder)
        }
        
        self.carouselDataSource = CarouselDataSource(banner: banner, withPageControl: self.customPageControl)
        self.carouselDataSource.navigationDelegate = navigationController
        slider.type = .Linear
        slider.dataSource = self.carouselDataSource
        slider.delegate = self.carouselDataSource
        slider.decelerationRate = 0.5
        
        let timer = NSTimer.bk_timerWithTimeInterval(5.0, block: { (timer) in
            slider.scrollToItemAtIndex(slider.currentItemIndex + 1, duration: 1.0)
            }, repeats: true)
        NSRunLoop.mainRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        
        customPageControl.numberOfPages = banner.count
        customPageControl.mas_makeConstraints { (make) in
            make.centerY.mas_equalTo()(self.homeSliderAddOnView)
            make.left.mas_equalTo()(self.homeSliderAddOnView).with().offset()(20)
            make.height.mas_equalTo()(self.pageControlHeight)
            make.width.mas_equalTo()(self.pageControlHeight*Int(self.customPageControl.numberOfPages))
        }
    }
}
