//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc
class IntroViewController: UIViewController {
    @IBOutlet private var presentationContainer: UIView!
    
    @IBOutlet private var topedImageView: UIImageView!
    
    @IBOutlet private var page1View: UIView!
    
    @IBOutlet private var page2View: UIView!
    
    var introView: EAIntroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let page1 = EAIntroPage(customView: page1View)
        setupPage1()
        
        page1.onPageDidAppear = topedImageView.startAnimating
        
        page1.onPageDidDisappear = topedImageView.stopAnimating
        
        let page2 = EAIntroPage(customView: page2View)
        
        let page3 = EAIntroPage()
        page3.title = "page 3"
        page3.desc = "page 3 desc"
        
        introView = EAIntroView(frame: UIScreen.mainScreen().bounds, andPages: [page1, page2, page3])
        introView.swipeToExit = false
        introView.showInView(presentationContainer)
    }
    
    private func setupPage1() {
        topedImageView.animationDuration = 3
        topedImageView.animationRepeatCount = 1
        topedImageView.animationImages = [
            UIImage(named: "onboarding_toped_1a.png")!,
            UIImage(named: "onboarding_toped_1b.png")!,
            UIImage(named: "onboarding_toped_1c.png")!,
            UIImage(named: "onboarding_toped_1d.png")!,
            UIImage(named: "onboarding_toped_1e.png")!,
            UIImage(named: "onboarding_toped_1f.png")!,
        ]
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // for some reason the introView's frame is distorted
        introView.frame = self.view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
