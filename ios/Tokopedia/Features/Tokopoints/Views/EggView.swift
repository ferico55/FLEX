//
//  EggView.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 12/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class EggView: UIView {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var eggContainer: UIView!
    @IBOutlet private weak var bottomImageView: UIImageView!
    @IBOutlet private weak var topImageView: UIImageView!
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var imgHand: UIImageView!
    
    internal var eggAsset: EggAsset? {
        didSet {
            if let eggAsset = eggAsset {
                resetViews()
                topImageView.image = eggAsset.topImage
                bottomImageView.image = eggAsset.bottomImage
                leftImageView.image = eggAsset.leftImage
                rightImageView.image = eggAsset.rightImage
            }
            else {
                setEmptyEgg()
            }
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
    
    internal func getEggImageSize() -> CGSize? {
        return topImageView.image?.size
    }
    
    internal func setAnchorPoints() {
        eggContainer.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 1))
        leftImageView.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 1))
        rightImageView.setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 1))
    }
    
    private func resetViews() {
        topImageView.isHidden = false
        bottomImageView.isHidden = false
        leftImageView.isHidden = true
        leftImageView.transform = .identity
        rightImageView.isHidden = true
        rightImageView.transform = .identity
        topImageView.layer.contentsRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        topImageView.transform = CGAffineTransform.identity
        imgHand.isHidden = true
    }
    
    internal func setEmptyEgg() {
        resetViews()
        bottomImageView.isHidden = true
        topImageView.image = #imageLiteral(resourceName: "empty-egg")
        isUserInteractionEnabled = false
    }
    
    internal func showOnboardingIfNeeded() {
        imgHand.isHidden = UserDefaults.standard.bool(forKey: "tokopointsEggOnboardingShown-\(UserAuthentificationManager().getUserId())")
        
        if !imgHand.isHidden {
            imgHand.transform = CGAffineTransform(translationX: 50, y: 50)
            UIView.animateKeyframes(withDuration: 2, delay: 0, options: [.calculationModeLinear, .repeat], animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.imgHand.transform = CGAffineTransform.identity
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    self.imgHand.transform = CGAffineTransform(translationX: 50, y: 50)
                })
            }, completion: nil)
        }
        else {
            imgHand.layer.removeAllAnimations()
        }
    }
    
    @objc
    internal func shake(crack: Bool = false, completion: (() -> Void)? = nil) {
        eggContainer.layer.removeAllAnimations()
        topImageView.layer.removeAllAnimations()
        
        let duration = crack ? 0.593 : 0.35
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeLinear, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            if crack {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.topImageView.layer.contentsRect = CGRect(x: 0, y: 1, width: 1, height: 0)
                    self.topImageView.transform = CGAffineTransform(translationX: 0, y: self.topImageView.frame.height / 2)
                })
            }
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.25, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.eggContainer.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 20)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.eggContainer.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 20)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.eggContainer.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 20)
            })
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                self.eggContainer.transform = CGAffineTransform(rotationAngle: 0)
            })
        }, completion: { [weak self] (completed) in
            guard let `self` = self else {
                return
            }
            
            self.isUserInteractionEnabled = true
            completion?()
        })
    }
    
    internal func stopShake() {
        eggContainer.layer.removeAllAnimations()
    }
    
    internal func crackOpen(duration: TimeInterval, completion: (() -> Void)? = nil) {
        topImageView.isHidden = true
        bottomImageView.isHidden = true
        
        leftImageView.isHidden = false
        rightImageView.isHidden = false
        
        UIView.animate(withDuration: duration, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.leftImageView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 4)
            self.rightImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi / 4)
        }, completion: { _ in
            completion?()
        })
    }
}
