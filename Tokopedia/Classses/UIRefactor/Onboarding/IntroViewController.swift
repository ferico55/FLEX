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
    
    @IBOutlet private var page3View: UIView!
    
    @IBOutlet private var spoonFork: UIImageView!
    @IBOutlet private var babyBottle: UIImageView!
    @IBOutlet private var fabulousShoe: UIImageView!
    @IBOutlet private var tshirt: UIImageView!
    @IBOutlet private var soccerBall: UIImageView!
    @IBOutlet private var giftbox: UIImageView!
    
    var introView: EAIntroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let page1 = EAIntroPage(customView: page1View)
        setupPage1()
        
        page1.onPageDidAppear = topedImageView.startAnimating
        page1.onPageDidDisappear = topedImageView.stopAnimating
        
        let page2 = EAIntroPage(customView: page2View)
        page2.onPageDidAppear = animatePage2
        
        let page3 = EAIntroPage(customView: page3View)
        
        introView = EAIntroView(frame: UIScreen.mainScreen().bounds, andPages: [page1, page2, page3])
        introView.swipeToExit = false
        introView.showInView(presentationContainer)
        introView.backgroundColor = UIColor.clearColor()
    }
    
    func animatePage2() {
        UIView.animateKeyframesWithDuration(1, delay: 0.5, options: .CalculationModeLinear, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.05, relativeDuration: 0, animations: {[unowned self] in
                self.giftbox.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.2, relativeDuration: 0, animations: {[unowned self] in
                self.fabulousShoe.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.35, relativeDuration: 0, animations: {[unowned self] in
                self.tshirt.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0, animations: {[unowned self] in
                self.spoonFork.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.65, relativeDuration: 0, animations: {[unowned self] in
                self.babyBottle.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.8, relativeDuration: 0, animations: {[unowned self] in
                self.soccerBall.alpha = 1
            })
        }, completion: nil)
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
