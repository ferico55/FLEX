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
    @IBOutlet private var page4View: UIView!
    @IBOutlet private var page5View: UIView!
    @IBOutlet private var page6View: UIView!
    
    @IBOutlet private var spoonFork: UIImageView!
    @IBOutlet private var babyBottle: UIImageView!
    @IBOutlet private var fabulousShoe: UIImageView!
    @IBOutlet private var tshirt: UIImageView!
    @IBOutlet private var soccerBall: UIImageView!
    @IBOutlet private var giftbox: UIImageView!
    
    
    @IBOutlet private var slide3Content: UIImageView!
    
    @IBOutlet private var page4Top: UIImageView!
    @IBOutlet private var page4Door: UIImageView!
    @IBOutlet private var page4Label: UIImageView!
    
    @IBOutlet var page5Bling: UIImageView!
    
    var introView: EAIntroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let page1 = EAIntroPage(customView: page1View)
        setupPage1()
        
        page1.onPageDidAppear = topedImageView.startAnimating
        page1.onPageDidDisappear = topedImageView.stopAnimating
        
        let page2 = EAIntroPage(customView: page2View)
        page2.onPageDidAppear = animatePage2
        page2.onPageDidDisappear = stopPage2Animations
        
        let page3 = EAIntroPage(customView: page3View)
        page3.onPageDidAppear = animatePage3
        page3.onPageDidDisappear = stopPage3Animations
        
        let page4 = EAIntroPage(customView: page4View)
        page4.onPageDidAppear = animatePage4
        page4.onPageDidDisappear = stopPage4Animations
        
        let page5 = EAIntroPage(customView: page5View)
        page5.onPageDidAppear = animatePage5
        
        let page6 = EAIntroPage(customView: page6View)
        
        introView = EAIntroView(frame: UIScreen.mainScreen().bounds, andPages: [
            page1,
            page2,
            page3,
            page4,
            page5,
            page6])
        
        introView.swipeToExit = false
        introView.showInView(presentationContainer)
        introView.backgroundColor = UIColor.clearColor()
    }
    
    private func stopPage2Animations() {
        [spoonFork, babyBottle, fabulousShoe, tshirt, soccerBall, giftbox].forEach { view in
            view.layer.removeAllAnimations()
            view.alpha = 0
        }
    }
    
    private func animatePage2() {
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
    
    private func stopPage3Animations() {
        slide3Content.layer.removeAllAnimations()
    }
    
    private func animatePage3() {
        let initialY = slide3Content.frame.origin.y
        
        UIView.animateWithDuration(0.7, delay: 0.5, options: [.Autoreverse, .CurveEaseInOut], animations: {[unowned self] in
                self.slide3Content.frame.origin.y = -122
            },
            completion: {[unowned self] complete in
                self.slide3Content.frame.origin.y = initialY
            })
    }
    
    private func stopPage4Animations() {
        [page4Top, page4Door, page4Label].forEach { view in
            view.layer.removeAllAnimations()
            view.alpha = 0
        }
    }
    
    private func animatePage4() {
        UIView.animateKeyframesWithDuration(0.8, delay: 0.3, options: .CalculationModeLinear, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0, animations: {
                self.page4Top.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.75, relativeDuration: 0, animations: {
                self.page4Door.alpha = 1
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.95, relativeDuration: 0, animations: {
                self.page4Label.alpha = 1
            })
        }, completion: nil)
    }
    
    private func animatePage5() {
        UIView.animateWithDuration(1, delay: 0.3, options: [.Autoreverse, .Repeat, .CurveEaseInOut], animations: {
            self.page5Bling.alpha = 1
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
