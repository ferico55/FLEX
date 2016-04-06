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
    
    @IBOutlet private var topedImageView: UIImageView! {
        didSet {
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
    }
    
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
    
    @IBOutlet private var page5Bling: UIImageView!
    
    @IBOutlet private var labelsToReRender: [UILabel]!
    
    private var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor(red: 18.0/255, green: 199.0/255, blue: 0, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(white: 204/255.0, alpha: 1)
        return pageControl
    }()
    
    @IBOutlet private var btnRejectNotification: UIButton! {
        didSet {
            btnRejectNotification.layer.borderWidth = 1
            btnRejectNotification.layer.borderColor = UIColor(red: 58/255.0, green: 179/255.0, blue: 57/255.0, alpha: 1).CGColor
        }
    }
    
    @IBOutlet var btnLogin: UIButton! {
        didSet {
            btnLogin.layer.borderWidth = 1
            btnLogin.layer.borderColor = UIColor(red: 58/255.0, green: 179/255.0, blue: 57/255.0, alpha: 1).CGColor
        }
    }
    
    var introView: EAIntroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reRenderLabels()
        
        introView = {
            let view = EAIntroView(frame: UIScreen.mainScreen().bounds, andPages: [
                {
                    let page = EAIntroPage(customView: page1View)
                    page.onPageDidAppear = topedImageView.startAnimating
                    page.onPageDidDisappear = topedImageView.stopAnimating
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page2View)
                    page.onPageDidAppear = animatePage2
                    page.onPageDidDisappear = stopPage2Animations
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page3View)
                    page.onPageDidAppear = animatePage3
                    page.onPageDidDisappear = stopPage3Animations
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page4View)
                    page.onPageDidAppear = {[unowned self] in
                        self.pageControl.hidden = false
                        self.animatePage4()
                    }
                    page.onPageDidDisappear = stopPage4Animations
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page5View)
                    page.onPageDidAppear = {[unowned self] in
                        self.pageControl.hidden = true
                        self.animatePage5()
                    }
                    return page
                }(),
                EAIntroPage(customView: page6View)])
            
            view.pageControl = pageControl
            view.swipeToExit = false
            view.showInView(presentationContainer)
            view.skipButton = nil
            view.backgroundColor = UIColor.clearColor()
            
            return view
        }()
    }
    
    private func reRenderLabels() {
        // At first, the line spacings won't be rendered correctly, because IBInspectable properties are set after
        // each label's text is rendered. As a workaround, we simply need to re-set the texts so that
        // the line spacings are applied.
        labelsToReRender.forEach { label in
            label.text = label.text
        }
    }
        
    private func stopPage2Animations() {
        [spoonFork, babyBottle, fabulousShoe, tshirt, soccerBall, giftbox].forEach { view in
            view.layer.removeAllAnimations()
            view.alpha = 0
        }
    }
    
    private func animatePage2() {
        UIView.animateKeyframesWithDuration(1, delay: 0.5, options: .CalculationModeLinear, animations: {
            self.showView(self.giftbox, atRelativeStartTime: 0.05)
            self.showView(self.fabulousShoe, atRelativeStartTime: 0.2)
            self.showView(self.tshirt, atRelativeStartTime: 0.35)
            self.showView(self.spoonFork, atRelativeStartTime: 0.5)
            self.showView(self.babyBottle, atRelativeStartTime: 0.65)
            self.showView(self.soccerBall, atRelativeStartTime: 0.8)
        }, completion: nil)
    }
    
    private func showView(view:UIView, atRelativeStartTime startTime:Double) {
        UIView.addKeyframeWithRelativeStartTime(startTime, relativeDuration: 0, animations: {
            view.alpha = 1
        })
    }
    
    private func stopPage3Animations() {
        slide3Content.layer.removeAllAnimations()
    }
    
    private func animatePage3() {
        let initialY = slide3Content.frame.origin.y
        
        UIView.animateKeyframesWithDuration(1.4, delay: 0.5, options: .CalculationModeCubic, animations: {
            UIView.addKeyframeWithRelativeStartTime(0.1, relativeDuration: 0.5, animations: {
                self.slide3Content.frame.origin.y = -122
            })
            
            UIView.addKeyframeWithRelativeStartTime(0.51, relativeDuration: 0.5, animations: {
                self.slide3Content.frame.origin.y = initialY
            })
        }, completion: nil)
    }
    
    private func stopPage4Animations() {
        [page4Top, page4Door, page4Label].forEach { view in
            view.layer.removeAllAnimations()
            view.alpha = 0
        }
    }
    
    private func animatePage4() {
        UIView.animateKeyframesWithDuration(0.8, delay: 0.3, options: .CalculationModeLinear, animations: {
            self.showView(self.page4Top, atRelativeStartTime: 0.1)
            self.showView(self.page4Door, atRelativeStartTime: 0.75)
            self.showView(self.page4Label, atRelativeStartTime: 0.95)
        }, completion: nil)
    }
    
    private func animatePage5() {
        UIView.animateWithDuration(1, delay: 0.3, options: [.Autoreverse, .Repeat, .CurveEaseInOut], animations: {
            self.page5Bling.alpha = 1
        }, completion: nil)
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
    
    private func navigateToMainViewControllerWithPage(page: MainViewControllerPage) {
        let window = UIApplication.sharedApplication().keyWindow!
        UIView.transitionWithView(window,
            duration: 0.5,
            options: UIViewAnimationOptions.TransitionCrossDissolve,
            animations: {
                window.rootViewController = MainViewController(page: page)
            },
            completion: nil)
    }
    
    @IBAction func btnSearchTapped(sender: AnyObject) {
        navigateToMainViewControllerWithPage(.Search)
    }
    
    @IBAction func btnLoginTapped(sender: AnyObject) {
        navigateToMainViewControllerWithPage(.Login)
    }
    
    @IBAction func btnRegisterTapped(sender: AnyObject) {
        navigateToMainViewControllerWithPage(.Register)
    }
    
    @IBAction func btnNotificationTapped(sender: AnyObject) {
        if #available(iOS 8, *) {
            let notificationSettings = UIUserNotificationSettings(
                forTypes: [.Alert, .Badge, .Sound],
                categories: nil)
            
            UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        } else {
            UIApplication.sharedApplication().registerForRemoteNotificationTypes([
                .Alert, .Badge, .Sound
            ])
        }
    }
}
