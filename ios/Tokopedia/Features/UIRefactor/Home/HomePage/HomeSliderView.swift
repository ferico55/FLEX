//
//  HomeSliderView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class HomeSliderView: UIView {
    
    @IBOutlet fileprivate var carouselPlaceholder: UIView!
    @IBOutlet fileprivate var seeAllPromoButton: UIButton!
    fileprivate var pageControlHeight: Int = 12
    fileprivate var customPageControl: StyledPageControl!
    fileprivate let slider = iCarousel(frame: CGRect.zero)
    
    @IBOutlet fileprivate var homeSliderAddOnView: UIView!
    fileprivate var carouselDataSource: CarouselDataSource?
    
    override func awakeFromNib() {
        setupCustomPageControl()
        setupSliderAddOnPromoButton()
        isAccessibilityElement = true
        accessibilityIdentifier = "bannerSliderView"
    }
    
    fileprivate func setupCustomPageControl() {
        customPageControl = StyledPageControl()
        customPageControl.pageControlStyle = PageControlStyleDefault
        customPageControl.coreNormalColor = .tpLine()
        customPageControl.coreSelectedColor = .tpGreen()
        customPageControl.diameter = 11
        customPageControl.gapWidth = 5
        addSubview(customPageControl)
    }
    
    fileprivate func setupSliderAddOnPromoButton() {
        let userAuthManager = UserAuthentificationManager()
        seeAllPromoButton.bk_(whenTapped: {
            var userInfo: [String: Int]!
            if userAuthManager.isLogin {
                userInfo = ["page": 3]
            } else {
                userInfo = ["page": 2]
            }
            
            NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: userInfo)
        })
    }
    
    func generateSliderView(withBanner banner: [Slide], withNavigationController navigationController: UINavigationController) {
        slider.backgroundColor = backgroundColor
        carouselPlaceholder.addSubview(slider)
        slider.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.carouselPlaceholder)
        }
        
        self.carouselDataSource = CarouselDataSource(banner: banner,
                                                     pageControl: customPageControl,
                                                     type: .home,
                                                     slider: slider)
        guard let carouselDataSource = self.carouselDataSource else { return }
        carouselDataSource.navigationDelegate = navigationController
        carouselDataSource.didSelectBanner = { banner, index in
            AnalyticsManager.trackHomeBanner(banner, index: index, type: .click)
        }
        
        slider.type = .linear
        slider.dataSource = self.carouselDataSource
        slider.delegate = self.carouselDataSource
        slider.decelerationRate = 0.5
        
        customPageControl.numberOfPages = banner.count
        customPageControl.mas_makeConstraints { make in
            make?.centerY.mas_equalTo()(self.homeSliderAddOnView)
            make?.left.mas_equalTo()(self.homeSliderAddOnView)?.with().offset()(20)
            make?.height.mas_equalTo()(self.pageControlHeight)
            make?.width.mas_equalTo()(self.pageControlHeight * Int(self.customPageControl.numberOfPages))
        }
    }
    
    func endBannerAutoScroll() {
        carouselDataSource?.endBannerAutoScroll()
    }
    
    func startBannerAutoScroll() {
        guard let carouselDataSource = self.carouselDataSource else { return }
        // refresh banner first with endBannerAutoScroll
        carouselDataSource.endBannerAutoScroll()
        carouselDataSource.startBannerAutoScroll()
    }
    
    func resetBannerCounter() {
        carouselDataSource?.resetBannerCounter()
    }
}
