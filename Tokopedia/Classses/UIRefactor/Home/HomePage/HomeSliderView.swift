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
    
    @IBOutlet fileprivate var homeSliderAddOnView: UIView!
    fileprivate var carouselDataSource: CarouselDataSource!
    
    override func awakeFromNib() {
        setupCustomPageControl()
        setupSliderAddOnPromoButton()
    }
    
    fileprivate func setupCustomPageControl() {
        customPageControl = StyledPageControl()
        customPageControl.pageControlStyle = PageControlStyleDefault
        customPageControl.coreNormalColor = UIColor(red: 214.0/255.0, green: 214.0/255.0, blue: 214.0/255.0, alpha: 1)
        customPageControl.coreSelectedColor = UIColor(red: 255.0/255.0, green: 87.0/255.0, blue: 34.0/255, alpha: 1)
        customPageControl.diameter = 11
        customPageControl.gapWidth = 5
        self.addSubview(customPageControl)
    }
    
    fileprivate func setupSliderAddOnPromoButton() {
        let userAuthManager = UserAuthentificationManager()
        self.seeAllPromoButton.bk_(whenTapped: {
            var userInfo: [String : Int]!
            if userAuthManager.isLogin {
                userInfo = ["page" : 3]
            } else {
                userInfo = ["page" : 2]
            }
            
            NotificationCenter.default.post(name: Notification.Name("didSwipeHomePage"), object: self, userInfo: userInfo)
        })
    }
    
    func generateSliderView(withBanner banner: [Slide], withNavigationController navigationController: UINavigationController) {
        let slider = iCarousel(frame: CGRect.zero)
        slider.backgroundColor = backgroundColor
        self.carouselPlaceholder.addSubview(slider)
        slider.mas_makeConstraints{ make in
            make?.edges.mas_equalTo()(self.carouselPlaceholder)
        }
        
        self.carouselDataSource = CarouselDataSource(banner: banner, with: self.customPageControl)
        self.carouselDataSource.navigationDelegate = navigationController
        slider.type = .linear
        slider.dataSource = self.carouselDataSource
        slider.delegate = self.carouselDataSource
        slider.decelerationRate = 0.5
        
        let timer = Timer.bk_timer(withTimeInterval: 5.0, block: { (timer) in
            slider.scrollToItem(at: slider.currentItemIndex + 1, duration: 1.0)
            }, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
        
        customPageControl.numberOfPages = banner.count
        customPageControl.mas_makeConstraints { (make) in
            make?.centerY.mas_equalTo()(self.homeSliderAddOnView)
            make?.left.mas_equalTo()(self.homeSliderAddOnView)?.with().offset()(20)
            make?.height.mas_equalTo()(self.pageControlHeight)
            make?.width.mas_equalTo()(self.pageControlHeight*Int(self.customPageControl.numberOfPages))
        }
    }
}
