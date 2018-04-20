//
//  HomeTabBarItem.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 28/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Lottie
import UIKit

@objc internal enum HomeIconState : Int {
    case jumpingRocket
    case homeActivated
    case disabled
}

@objc internal class HomeTabBarItem: UIView {
    private var jumpingRocketLottie: LOTAnimationView
    private var homeTabMenuLottie: LOTAnimationView
    private (set) var state: HomeIconState
    private var tabBarItem: UITabBarItem
    private let selectedImage = #imageLiteral(resourceName: "icon_home_active.png").withRenderingMode(.alwaysOriginal)
    private let defaultImage = #imageLiteral(resourceName: "icon_home.png").withRenderingMode(.alwaysOriginal)
    private var transparentImage: UIImage?
    private var isDisabled: Bool = false
    private var previousState: HomeIconState
    private var _focused: Bool = true
    
    internal override var isFocused: Bool {
        set(value) {
            _focused = value
            if value {
                self.restorePreviousState(animated: false)
            } else {
                self.setState(.disabled, animated: false)
            }
        }
        get {
            return _focused
        }
    }
    
    internal init(tabBarItem: UITabBarItem, rect: CGRect) {
        jumpingRocketLottie = LOTAnimationView(name: "movingRocket")
        homeTabMenuLottie = LOTAnimationView(name: "rocketTransition")
        self.state = .jumpingRocket
        self.previousState = .jumpingRocket
        self.tabBarItem = tabBarItem
        self.tabBarItem.title = "For You"
        super.init(frame: rect)
        
        let isIphoneX = self.isIphoneX()
        
        jumpingRocketLottie.animationProgress = 0
        jumpingRocketLottie.loopAnimation = true
        jumpingRocketLottie.play()
        jumpingRocketLottie.contentMode = .scaleAspectFit
        jumpingRocketLottie.backgroundColor = UIColor.clear
        self.addSubview(jumpingRocketLottie)
        jumpingRocketLottie.frame = self.frame
        jumpingRocketLottie.isHidden = false
        
        homeTabMenuLottie.animationProgress = 1
        homeTabMenuLottie.animationSpeed = 1.5
        homeTabMenuLottie.loopAnimation = false
        homeTabMenuLottie.contentMode = .scaleAspectFit
        homeTabMenuLottie.backgroundColor = UIColor.clear
        self.addSubview(homeTabMenuLottie)
        if isIphoneX {
            homeTabMenuLottie.frame = CGRect(x: self.frame.midX - (29 / 2), y: self.frame.midY - (29 / 2), width: 29, height: 29)
        } else {
            homeTabMenuLottie.frame.size = CGSize(width: 29, height: 29)
            homeTabMenuLottie.center = self.center
        }
        homeTabMenuLottie.isHidden = true
        
        transparentImage = self.getTransparentImage(size: CGSize(width: 12, height: 32))
        toggleTabBarImage(visible: false)
    }
    
    private func isIphoneX() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func toggleTabBarImage(visible: Bool) {
        tabBarItem.image = visible ? defaultImage : transparentImage
        tabBarItem.selectedImage = visible ? selectedImage : transparentImage
    }
    
    private func getTransparentImage(size: CGSize) -> UIImage? {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        UIColor.clear.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        return UIImage(cgImage: cgImage).withRenderingMode(.alwaysOriginal)
    }
    
    private func sendImpression(state: HomeIconState) {
        var action = ""
        switch state {
        case .jumpingRocket:
            action = "impression on infinite product jumper"
        case .homeActivated:
            action = "impression on home jumper"
        case .disabled:
            return
        }
        AnalyticsManager.trackEventName("userImpressionHomePage", category: "homepage", action: action, label: "")
    }
    
    private func animateScale(nextTitle: String) {
        let layer = homeTabMenuLottie.layer
        let timing = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let scaleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(timing)
        scaleAnimation.beginTime = CACurrentMediaTime() + 0.2
        scaleAnimation.duration = 0.3
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.2
        layer.add(scaleAnimation, forKey: "scale")
        
        CATransaction.setCompletionBlock {
            DispatchQueue.main.async { [unowned self] in
                self.tabBarItem.title = nextTitle
            }
        }
        
        CATransaction.commit()
    }
    
    private func restorePreviousState(animated: Bool) {
        if self.state != .disabled {
            return
        }

        self.setState(previousState, animated: animated)
    }
    
    internal func setState(_ state: HomeIconState, animated: Bool) {
        DispatchQueue.main.async { [unowned self] in
            self.setState(state, animated: animated, completionHandler: nil)
        }
    }
    
    private func setState(_ state: HomeIconState, animated: Bool, completionHandler: (() -> Void)? ) {
        if state == self.state && !isDisabled {
            completionHandler?()
            return
        }
        
        if homeTabMenuLottie.isAnimationPlaying {
            homeTabMenuLottie.stop()
        }

        sendImpression(state: state)
        isDisabled = false
        switch state {
        case .jumpingRocket:
            if animated {
                toggleTabBarImage(visible: false)
                homeTabMenuLottie.isHidden = false
                jumpingRocketLottie.isHidden = true
                homeTabMenuLottie.play(fromProgress: 1, toProgress: 0, withCompletion: { [unowned self] _ in
                    self.homeTabMenuLottie.isHidden = true
                    self.jumpingRocketLottie.isHidden = false
                    self.jumpingRocketLottie.animationProgress = 0
                    self.jumpingRocketLottie.play()
                    self.toggleTabBarImage(visible: false)
                    
                    completionHandler?()
                })
                
                self.animateScale(nextTitle: "For You")
            } else {
                homeTabMenuLottie.isHidden = true
                jumpingRocketLottie.isHidden = false
                jumpingRocketLottie.animationProgress = 0
                jumpingRocketLottie.play()
                toggleTabBarImage(visible: false)
                tabBarItem.title = "For You"
            }
        case .homeActivated:
            if animated {
                toggleTabBarImage(visible: false)
                homeTabMenuLottie.isHidden = false
                jumpingRocketLottie.isHidden = true
                homeTabMenuLottie.play(fromProgress: 0, toProgress: 1, withCompletion: { [unowned self] _ in
                    self.homeTabMenuLottie.isHidden = true
                    self.jumpingRocketLottie.isHidden = true
                    self.jumpingRocketLottie.stop()
                    self.tabBarItem.title = "Home"
                    self.toggleTabBarImage(visible: true)
                    
                    completionHandler?()
                })
                self.tabBarItem.title = "Home"
            } else {
                homeTabMenuLottie.isHidden = true
                jumpingRocketLottie.isHidden = true
                jumpingRocketLottie.stop()
                toggleTabBarImage(visible: true)
                self.tabBarItem.title = "Home"
            }
        case .disabled:
            isDisabled = true
            tabBarItem.title = "Home"
            homeTabMenuLottie.isHidden = true
            jumpingRocketLottie.isHidden = true
            jumpingRocketLottie.stop()
            toggleTabBarImage(visible: true)
        }
        
        if self.state != .disabled && state == .disabled {
            self.previousState = self.state
        }
        self.state = state
    }
}
