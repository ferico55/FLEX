//
//  LabelCopyable.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 11/25/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class LabelCopyable: UILabel {
    
    var onCopy : ((String) -> Void)?
    
    private func attachTapHandler(){
        self.userInteractionEnabled = true
        
        let longTap = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongTap(_:)))
        self.addGestureRecognizer(longTap)
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.attachTapHandler()
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func canResignFirstResponder() -> Bool {
        return true
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return (action == #selector(onTapCopy(_:)))
    }
    
    @objc private func handleLongTap(sender:UILongPressGestureRecognizer){
        self.becomeFirstResponder()
        
        let menu = UIMenuController.sharedMenuController()
        menu.setTargetRect(self.frame, inView: self.superview!)
        menu.setMenuVisible(true, animated: true)
        
    }
    
    @objc private func onTapCopy(sender: AnyObject?) {
        onCopy?(self.text ?? "")
    }

}
