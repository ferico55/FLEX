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
    
    @objc fileprivate func handleLongTap(_ sender:UILongPressGestureRecognizer){
        self.becomeFirstResponder()
        
        let menu = UIMenuController.shared
        menu.setTargetRect(self.frame, in: self.superview!)
        menu.setMenuVisible(true, animated: true)
        
    }
    
    @objc fileprivate func onTapCopy(_ sender: AnyObject?) {
        onCopy?(self.text ?? "")
    }

}
