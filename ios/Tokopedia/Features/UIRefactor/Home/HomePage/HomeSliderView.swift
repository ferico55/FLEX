//
//  HomeSliderView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 12/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import FirebaseRemoteConfig
import UIKit

internal class HomeSliderView: UIView {

    @IBOutlet fileprivate var carouselPlaceholder: UIView!
    fileprivate var pageControlHeight: Int = 12
    fileprivate var customPageControl: StyledPageControl!
    fileprivate let slider = iCarousel(frame: CGRect.zero)
    
    fileprivate var carouselDataSource: CarouselDataSource?
    
    internal override func awakeFromNib() {
        super.awakeFromNib()

        setupCustomPageControl()
        isAccessibilityElement = true
        accessibilityIdentifier = "bannerSliderView"
    }
    
    fileprivate func setupCustomPageControl() {
        customPageControl = StyledPageControl()
        customPageControl.pageControlStyle = PageControlStyleDefault
        customPageControl.coreNormalColor = .tpSecondaryWhiteText()
        customPageControl.coreSelectedColor = .tpOrange()
        customPageControl.strokeNormalColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        customPageControl.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        customPageControl.diameter = 12
        customPageControl.gapWidth = 5
        addSubview(customPageControl)
    }
    
    internal func generateSliderView(withBanner banner: [Slide], withNavigationController navigationController: UINavigationController) {
        self.carouselPlaceholder.snp.makeConstraints { make in
            make.height.equalTo(UIDevice.current.userInterfaceIdiom == .pad ? 225 : 125)
        }
        slider.backgroundColor = backgroundColor
        slider.clipsToBounds = true
        carouselPlaceholder.addSubview(slider)
        slider.snp.makeConstraints { [unowned self] make in
            make.edges.equalTo(self.carouselPlaceholder)
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
            
            var bannerTitle: String = "none / other"
            
            if let title = banner.bannerTitle {
                bannerTitle = title
            }
            
            guard var urlComponent = URLComponents(string: banner.applinks) else {
                return
            }
            
            if let urlComp = urlComponent.queryItems, urlComp.count > 0 {
                urlComponent.queryItems?.append(URLQueryItem(name: "trackerAttribution", value: String(format: "%@", "1 - sliderBanner \(index + 1) - \(bannerTitle)")))
            } else {
                urlComponent.queryItems = [URLQueryItem(name: "trackerAttribution", value: String(format: "%@", "1 - sliderBanner \(index + 1) - \(bannerTitle)"))]
            }
            
            guard let url = urlComponent.url else {
                return
            }
            
            TPRoutes.routeURL(url)
        }
        
        slider.type = .linear
        slider.dataSource = self.carouselDataSource
        slider.delegate = self.carouselDataSource
        slider.decelerationRate = 0.5
        
        customPageControl.numberOfPages = banner.count
        customPageControl.hidesForSinglePage = true
        customPageControl.snp.makeConstraints { [unowned self] make in
            make.bottom.equalTo(self.carouselPlaceholder).offset(-4)
            make.left.equalTo(self.carouselPlaceholder).offset(12)
            make.height.equalTo(self.pageControlHeight)
            make.width.equalTo(self.pageControlHeight * Int(self.customPageControl.numberOfPages))
        }
    }
    
    internal func endBannerAutoScroll() {
        carouselDataSource?.endBannerAutoScroll()
    }
    
    internal func startBannerAutoScroll() {
        guard let carouselDataSource = self.carouselDataSource else { return }
        // refresh banner first with endBannerAutoScroll
        carouselDataSource.endBannerAutoScroll()
        carouselDataSource.startBannerAutoScroll()
    }
    
    internal func resetBannerCounter() {
        carouselDataSource?.resetBannerCounter()
    }
}
