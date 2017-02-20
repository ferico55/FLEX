//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc
class IntroViewController: UIViewController, EAIntroDelegate {
    @IBOutlet fileprivate var presentationContainer: UIView!
    
    @IBOutlet fileprivate var topedImageView: UIImageView! {
        didSet {
            topedImageView.animationDuration = 4.2
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
    
    @IBOutlet fileprivate var page1View: UIView!
    @IBOutlet fileprivate var page2View: UIView!
    @IBOutlet fileprivate var page3View: UIView!
    @IBOutlet fileprivate var page4View: UIView!
    @IBOutlet fileprivate var page5View: UIView!
    @IBOutlet fileprivate var page6View: UIView!
    
    @IBOutlet fileprivate var spoonFork: UIImageView!
    @IBOutlet fileprivate var babyBottle: UIImageView!
    @IBOutlet fileprivate var fabulousShoe: UIImageView!
    @IBOutlet fileprivate var tshirt: UIImageView!
    @IBOutlet fileprivate var soccerBall: UIImageView!
    @IBOutlet fileprivate var giftbox: UIImageView!
    
    
    @IBOutlet fileprivate var slide3Content: UIImageView!
    
    @IBOutlet fileprivate var page4Top: UIImageView!
    @IBOutlet fileprivate var page4Door: UIImageView!
    @IBOutlet fileprivate var page4Label: UIImageView!
    
    @IBOutlet fileprivate var page5Bling: UIImageView!
    
    @IBOutlet fileprivate var labelsToReRender: [UILabel]!
    
    fileprivate var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor(red: 18.0/255, green: 199.0/255, blue: 0, alpha: 1)
        pageControl.pageIndicatorTintColor = UIColor(white: 204/255.0, alpha: 1)
        return pageControl
    }()
    
    @IBOutlet fileprivate var btnRejectNotification: UIButton! {
        didSet {
            btnRejectNotification.layer.borderWidth = 1
            btnRejectNotification.layer.borderColor = UIColor(red: 58/255.0, green: 179/255.0, blue: 57/255.0, alpha: 1).cgColor
        }
    }
    
    @IBOutlet var btnLogin: UIButton! {
        didSet {
            btnLogin.layer.borderWidth = 1
            btnLogin.layer.borderColor = UIColor(red: 58/255.0, green: 179/255.0, blue: 57/255.0, alpha: 1).cgColor
        }
    }
    
    var introView: EAIntroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        AnalyticsManager.trackScreenName("Onboarding")
        
        UIApplication.shared.statusBarStyle = .default
        
        reRenderLabels()
        
        introView = {
            let view = EAIntroView(frame: UIScreen.main.bounds, andPages: [
                {
                    let page = EAIntroPage(customView: page1View)
                    page?.onPageDidAppear = topedImageView.startAnimating
                    page?.onPageDidDisappear = topedImageView.stopAnimating
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page2View)
                    page?.onPageDidAppear = {[unowned self] in
                        self.animatePage2()
                    }
                    
                    page?.onPageDidDisappear = {[unowned self] in
                        self.stopPage2Animations()
                    }
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page3View)
                    page?.onPageDidAppear = {[unowned self] in
                        self.animatePage3()
                    }
                    page?.onPageDidDisappear = {[unowned self] in
                        self.stopPage3Animations()
                    }
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page4View)
                    page?.onPageDidAppear = {[unowned self] in
                        self.animatePage4()
                    }
                    page?.onPageDidDisappear = {[unowned self] in
                        self.stopPage4Animations()
                    }
                    return page
                }(),
                {
                    let page = EAIntroPage(customView: page5View)
                    page?.onPageDidAppear = {[unowned self] in
                        self.animatePage5()
                    }
                    return page
                }(),
                EAIntroPage(customView: page6View)])
            
            view?.pageControl = pageControl
            view?.swipeToExit = false
            view?.show(in: presentationContainer)
            view?.skipButton = nil
            view?.backgroundColor = UIColor.clear
            view?.delegate = self
            
            return view
        }()
    }
    
    fileprivate func togglePageControlVisibility(_ pageIndex: UInt) {
        pageControl.isHidden = pageIndex > 3
    }
    
    func intro(_ introView: EAIntroView!, pageAppeared page: EAIntroPage!, with pageIndex: UInt) {
        togglePageControlVisibility(pageIndex)

        if (pageIndex > 3) {
            introView.scrollView.isScrollEnabled = false
        }
    }
    
    fileprivate func reRenderLabels() {
        // At first, the line spacings won't be rendered correctly, because IBInspectable properties are set after
        // each label's text is rendered. As a workaround, we simply need to re-set the texts so that
        // the line spacings are applied.
        labelsToReRender.forEach { label in
            label.text = label.text
        }
    }
        
    fileprivate func stopPage2Animations() {
        [spoonFork, babyBottle, fabulousShoe, tshirt, soccerBall, giftbox].forEach { view in
            view?.layer.removeAllAnimations()
            view?.alpha = 0
        }
    }
    
    fileprivate func animatePage2() {
        UIView.animateKeyframes(withDuration: 1, delay: 0.5, options: UIViewKeyframeAnimationOptions(), animations: {
            self.showView(self.giftbox, atRelativeStartTime: 0.05)
            self.showView(self.fabulousShoe, atRelativeStartTime: 0.2)
            self.showView(self.tshirt, atRelativeStartTime: 0.35)
            self.showView(self.spoonFork, atRelativeStartTime: 0.5)
            self.showView(self.babyBottle, atRelativeStartTime: 0.65)
            self.showView(self.soccerBall, atRelativeStartTime: 0.8)
        }, completion: nil)
    }
    
    fileprivate func showView(_ view:UIView, atRelativeStartTime startTime:Double) {
        UIView.addKeyframe(withRelativeStartTime: startTime, relativeDuration: 0.2, animations: {
            view.alpha = 1
        })
    }
    
    fileprivate func stopPage3Animations() {
        slide3Content.layer.removeAllAnimations()
    }
    
    fileprivate func animatePage3() {
        let initialY = slide3Content.frame.origin.y
        let targetY = initialY - slide3Content.frame.size.height +
            slide3Content.superview!.frame.size.height
        
        UIView.animateKeyframes(withDuration: 1.4, delay: 0.5, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.5, animations: {
                self.slide3Content.frame.origin.y = targetY
            })
            
            UIView.addKeyframe(withRelativeStartTime: 0.51, relativeDuration: 0.5, animations: {
                self.slide3Content.frame.origin.y = initialY
            })
        }, completion: nil)
    }
    
    fileprivate func stopPage4Animations() {
        [page4Top, page4Door, page4Label].forEach { view in
            view?.layer.removeAllAnimations()
            view?.alpha = 0
        }
    }
    
    fileprivate func animatePage4() {
        UIView.animateKeyframes(withDuration: 0.8, delay: 0.3, options: UIViewKeyframeAnimationOptions(), animations: {
            self.showView(self.page4Top, atRelativeStartTime: 0.1)
            self.showView(self.page4Door, atRelativeStartTime: 0.75)
            self.showView(self.page4Label, atRelativeStartTime: 0.95)
        }, completion: nil)
    }
    
    fileprivate func animatePage5() {
        UIView.animate(withDuration: 1, delay: 0.3, options: [.autoreverse, .repeat], animations: {
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
    
    fileprivate func navigateToMainViewControllerWithPage(_ page: MainViewControllerPage) {
        let window = UIApplication.shared.keyWindow!
        window.backgroundColor = UIColor.clear
        let nextViewController = MainViewController(page: page)
        
        nextViewController?.view.frame = self.view.frame

        //need to call this to prevent stale notification observer
        introView.hide(withFadeOutDuration: 1)

        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = nextViewController
            },
            completion: nil)
    }
    
    fileprivate func markOnboardingPlayed() {
        UserDefaults.standard.set(true, forKey: "has_shown_onboarding")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func btnSearchTapped(_ sender: AnyObject) {
        markOnboardingPlayed()
        AnalyticsManager.track(onBoardingClickButton: "Search")
        navigateToMainViewControllerWithPage(.search)
    }
    
    @IBAction func btnLoginTapped(_ sender: AnyObject) {
        markOnboardingPlayed()
        AnalyticsManager.track(onBoardingClickButton: "Login")
        navigateToMainViewControllerWithPage(.login)
    }
    
    @IBAction func btnRegisterTapped(_ sender: AnyObject) {
        markOnboardingPlayed()
        AnalyticsManager.track(onBoardingClickButton: "Register")
        navigateToMainViewControllerWithPage(.register)
    }
    
    @IBAction func btnNotificationTapped(_ sender: AnyObject) {
        JLNotificationPermission.sharedInstance().isExtraAlertEnabled = false
        JLNotificationPermission.sharedInstance().authorize({[unowned self] deviceId, error in
            let deniedCode = JLAuthorizationErrorCode.permissionSystemDenied.rawValue
            if let errorCode = error?._code, errorCode == deniedCode {
                guard #available(iOS 8, *) else { return }
                let url = NSURL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.openURL(url as URL)
            }
            
            if let _ = deviceId {
                self.introView.setCurrentPageIndex(5, animated: true)
            }
        })
        
        AnalyticsManager.track(onBoardingClickButton: "Activate push notification")
    }
    
    @IBAction func btnRejectNotificationTapped(_ sender: AnyObject) {
        introView.scrollingEnabled = true
        introView.setCurrentPageIndex(5, animated: true)
        AnalyticsManager.track(onBoardingClickButton: "Reject push notification")
    }
}
