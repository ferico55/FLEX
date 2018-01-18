//
//  Modal.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

protocol Modal {
    func show(animated:Bool)
    func dismiss(animated:Bool)
    var backgroundView:UIScrollView {get}
    var dialogView:UIView {get set}
}

extension Modal where Self:UIView{
    
    func show(animated: Bool) {
        self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.dialogView.frame.origin = CGPoint(x: (self.frame.width - self.dialogView.frame.width) / 2, y: self.frame.height)
        UIApplication.shared.delegate?.window??.rootViewController?.view.addSubview(self)
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.66)
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
                let y = max((self.frame.height - self.dialogView.frame.height) / 2, 16)
                self.dialogView.frame.origin = CGPoint(x: self.dialogView.frame.origin.x, y: y)
            }, completion: { (completed) in
                // do nothing
            })
        }
        else {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.66)
            var centerY = self.center.y
            if self.dialogView.frame.height > self.backgroundView.frame.height {
                centerY = self.center.y + self.dialogView.frame.height - self.backgroundView.frame.height
            }
            self.dialogView.center  = CGPoint(x: self.center.x, y: centerY)
        }
    }
    
    func dismiss(animated: Bool){
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0)
            }, completion: { (completed) in
                
            })
            UIView.animate(withDuration: 0.33, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 10, options: UIViewAnimationOptions(rawValue: 0), animations: {
                self.dialogView.frame.origin = CGPoint(x: self.dialogView.frame.origin.x, y: self.frame.height)
                self.dialogView.alpha = 0
            }, completion: { (completed) in
                self.removeFromSuperview()
            })
        }
        else {
            self.removeFromSuperview()
        }
        
    }
}
