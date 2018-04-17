//
//  RayView.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 13/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class RayView: UIView {
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var yellowRay: UIImageView!

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

    internal func startAnimating() {
        isHidden = false
        yellowRay.layer.removeAllAnimations()
        yellowRay.alpha = 0
        
        UIView.animate(withDuration: 1.5, animations: { [weak self] in
            guard let `self` = self else {
                return
            }
            
            self.yellowRay.alpha = 1
        }, completion: { [weak self] (completed) in
            guard let `self` = self else {
                return
            }
            UIView.animateKeyframes(withDuration: 5, delay: 0, options: [.repeat, .calculationModeCubic], animations: { [weak self] in
                guard let `self` = self else {
                    return
                }
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5, animations: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.yellowRay.alpha = 0.25
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: { [weak self] in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.yellowRay.alpha = 1
                })
            }, completion: nil)
        })
    }
    
    internal func stopAnimating() {
        yellowRay.layer.removeAllAnimations()
        isHidden = true
    }
}
