//
//  LabelCopyable.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class LabelCopyable: UILabel {
    
    fileprivate func attachTapHandler(){
        self.isUserInteractionEnabled = true
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongTap(_:)))
        self.addGestureRecognizer(longTap)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.attachTapHandler()
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override var canResignFirstResponder : Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return (action == #selector(onTapCopy(_:)))
    }
    
    private var pointerFrame: CGRect {
        var rect = self.frame
        
        switch textAlignment {
        case .left: rect.size.width = 0
        case .right:
            rect.origin.x += rect.size.width
            rect.size.width = 0
        default: break
        }
        
        return rect
    }
    
    @objc fileprivate func handleLongTap(_ sender:UILongPressGestureRecognizer){
        guard let superview = self.superview, sender.state == .began else { return }
        
        self.becomeFirstResponder()
        
        let menu = UIMenuController.shared
        menu.menuItems = [UIMenuItem(title: "Copy", action: #selector(onTapCopy))]
        menu.setTargetRect(self.pointerFrame, in: superview)
        menu.setMenuVisible(true, animated: true)
        
    }
    
    @objc fileprivate func onTapCopy(_ sender: AnyObject?) {
        UIPasteboard.general.string = self.text ?? ""
    }

}
