//
//  HomeSliderView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import FirebaseRemoteConfig

class HomeSliderView: UIView {

    @IBOutlet fileprivate var carouselPlaceholder: UIView!
    fileprivate var pageControlHeight: Int = 12
    fileprivate var customPageControl: StyledPageControl!
    fileprivate let slider = iCarousel(frame: CGRect.zero)
    
    fileprivate var carouselDataSource: CarouselDataSource?
    
    override func awakeFromNib() {
        setupCustomPageControl()
        isAccessibilityElement = true
        accessibilityIdentifier = "bannerSliderView"
    }
    
    fileprivate func setupCustomPageControl() {
        customPageControl = StyledPageControl()
        customPageControl.pageControlStyle = PageControlStyleDefault
        customPageControl.coreNormalColor = .tpSecondaryWhiteText()
        customPageControl.coreSelectedColor = .tpOrange()
        customPageControl.strokeNormalColor = UIColor(white: 0, alpha: 0)
        customPageControl.borderColor = UIColor(white: 0, alpha: 0)
        customPageControl.diameter = 12
        customPageControl.gapWidth = 5
        addSubview(customPageControl)
    }
    
    func generateSliderView(withBanner banner: [Slide], withNavigationController navigationController: UINavigationController) {
        self.carouselPlaceholder.mas_makeConstraints { make in
            make?.height.mas_equalTo()(UIDevice.current.userInterfaceIdiom == .pad ? 225 : 125)
        }
        slider.backgroundColor = backgroundColor
        slider.clipsToBounds = true
        carouselPlaceholder.addSubview(slider)
        slider.mas_makeConstraints { make in
            make?.edges.mas_equalTo()(self.carouselPlaceholder)
        }
        
        self.carouselDataSource = CarouselDataSource(banner: banner,
                                                     pageControl: customPageControl,
                                                     type: .home,
                                                     slider: slider)
        guard let carouselDataSource = self.carouselDataSource else { return }
        carouselDataSource.bannerIPadSize = CGSize(width: 768, height: 225)
        carouselDataSource.bannerIPhoneSize = CGSize(width: 375, height: 125)
        carouselDataSource.navigationDelegate = navigationController
        carouselDataSource.didSelectBanner = { banner, index in
            AnalyticsManager.trackHomeBanner(banner, index: index, type: .click)
        }
        
        slider.type = .linear
        slider.dataSource = self.carouselDataSource
        slider.delegate = self.carouselDataSource
        slider.decelerationRate = 0.5
        
        customPageControl.numberOfPages = banner.count
        customPageControl.hidesForSinglePage = true
        customPageControl.mas_makeConstraints { make in
            make?.bottom.mas_equalTo()(self.carouselPlaceholder)?.with().offset()(-4)
            make?.left.mas_equalTo()(self.carouselPlaceholder)?.with().offset()(12)
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
