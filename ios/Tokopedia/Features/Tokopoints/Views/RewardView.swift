//
//  RewardView.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class RewardView: UIView {

    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var imgSunray: UIImageView!
    @IBOutlet private weak var imgReward: UIImageView!
    @IBOutlet private weak var viewAdditional: UIView!
    @IBOutlet private weak var lblBenefits: UILabel!
    @IBOutlet private weak var btnReturn: UIButton!
    @IBOutlet private weak var btnCta: UIButton!
    @IBOutlet private weak var btnCtaTopConstraint1: NSLayoutConstraint!
    @IBOutlet private weak var btnCtaTopConstraint2: NSLayoutConstraint!
    
    internal var imageReward: UIImage! {
        didSet {
            imgReward.image = imageReward
        }
    }
    internal var onDismiss: (() -> Void)?
    private let eventClick = "luckyEggClick"
    
    internal var crackResult: CrackResultMutation.Data.CrackResult? {
        didSet {
            guard let crackResult = crackResult else {
                return
            }
            
            lblBenefits.attributedText = crackResult.benefitText
            btnReturn.setTitle(crackResult.returnButton.title, for: .normal)
            btnReturn.isHidden = crackResult.returnButton.buttonType == .invisible
            if crackResult.returnButton.buttonType == .invisible {
                btnCtaTopConstraint1.priority = 900
                btnCtaTopConstraint2.priority = 950
            }
            else {
                btnCtaTopConstraint1.priority = 950
                btnCtaTopConstraint2.priority = 900
            }
            btnCta.setTitle(crackResult.ctaButton.title, for: .normal)
            btnCta.isHidden = crackResult.ctaButton.buttonType == .invisible
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    internal func showReward(duration: TimeInterval) {
        imgSunray.layer.removeAllAnimations()
        imgReward.layer.removeAllAnimations()
        viewAdditional.layer.removeAllAnimations()
        
        viewAdditional.alpha = 0
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.isHidden = false
        
        imgSunray.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform(translationX: 0, y: 160))
        imgReward.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform(translationX: 0, y: 160))
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                
                self.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            })
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.imgSunray.transform = CGAffineTransform.identity
                self.imgReward.transform = CGAffineTransform.identity
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.viewAdditional.alpha = 1
            })
        }, completion: { [weak self] _ in
            guard let `self` = self else {
                return
            }
            
            UIView.animate(withDuration: 7.5, delay: 0, options: [.repeat, .curveLinear], animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.imgSunray.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
            }, completion: nil)
        })
    }

    @IBAction private func btnReturnDidTapped(_ sender: Any) {
        guard let crackResult = crackResult else {
            return
        }
        
        if let benefitType = crackResult.benefitType, let title = crackResult.returnButton.title {
            AnalyticsManager.trackEventName(eventClick, category: "lucky egg - \(benefitType)", action: "click", label: title)
        }
        
        if crackResult.returnButton.buttonType == .dismiss {
            isHidden = true
            onDismiss?()
        }
        else if crackResult.returnButton.buttonType == .redirect, let applink = crackResult.returnButton.applink, !applink.isEmpty {
            TPRoutes.routeURL(URL(string: applink))
        }
    }
    
    @IBAction private func btnCtaDidTapped(_ sender: Any) {
        guard let crackResult = crackResult else {
            return
        }
        
        if let benefitType = crackResult.benefitType, let title = crackResult.ctaButton.title {
            AnalyticsManager.trackEventName(eventClick, category: "lucky egg - \(benefitType)", action: "click", label: title)
        }
        
        if crackResult.ctaButton.buttonType == .dismiss {
            isHidden = true
            onDismiss?()
        }
        else if crackResult.ctaButton.buttonType == .redirect, let applink = crackResult.ctaButton.applink, !applink.isEmpty {
            TPRoutes.routeURL(URL(string: applink))
        }
    }
    
    @IBAction private func btnCloseDidTapped(_ sender: Any) {
        guard let crackResult = crackResult else {
            return
        }
        
        if let benefitType = crackResult.benefitType {
            AnalyticsManager.trackEventName(eventClick, category: "lucky egg - \(benefitType)", action: "click", label: "close button")
        }
        
        isHidden = true
        onDismiss?()
    }
}
