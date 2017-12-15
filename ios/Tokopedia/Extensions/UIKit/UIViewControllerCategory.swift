//
//  UIViewControllerCategory.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit
import SwiftOverlays

@objc enum NotificationType : Int {
    case error
    case success
    case warning
}

extension UIViewController {
    @discardableResult class func showNotificationWithMessage(_ message: String,
                                           type: Int,
                                           duration: TimeInterval,
                                           buttonTitle: String?,
                                           dismissable: Bool,
                                           action: (() -> Void)?) -> UIView {
        let view = CustomNotificationView.new()
        
        view?.actionButton.layer.borderColor = UIColor.white.cgColor
        view?.actionButton.layer.borderWidth = 1.0
        view?.actionButton.clipsToBounds = true
        view?.setMessageLabelWithText(message)
        
        if type == NotificationType.error.rawValue {
            view?.backgroundColor = UIColor(red: 255/255.0,
                                           green: 59/255.0,
                                           blue: 48/255.0,
                                           alpha: 1.0)
        } else if type == NotificationType.success.rawValue {
            view?.backgroundColor = UIColor(red: 10/255.0,
                                           green: 126/255.0,
                                           blue: 7/255.0,
                                           alpha: 1.0)
        } else if type == NotificationType.warning.rawValue {
            view?.backgroundColor = UIColor(red: 255/255.0,
                                           green: 204/255.0,
                                           blue: 102/255.0,
                                           alpha: 1.0)
        }
        
        if buttonTitle == nil {
            view?.hideActionButton()
        } else {
            view?.actionButton.setTitle(buttonTitle, for: .normal)
        }
        
        if !dismissable {
            view?.hideCloseButton()
        }
        
        view?.frame.size.width = UIScreen.main.bounds.size.width
        view?.setNeedsLayout()
        view?.layoutIfNeeded()
        view?.messageLabel.preferredMaxLayoutWidth = (view?.messageLabel.frame.size.width)!
        
        let preferredHeight = view?.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        view?.frame.size.height = preferredHeight!
        
        view?.closeButton.bk_(whenTapped:{
            SwiftOverlays.closeAnnoyingNotificationOnTopOfStatusBar(view!)
        })
        
        view?.actionButton.bk_(whenTapped:{
            SwiftOverlays.closeAnnoyingNotificationOnTopOfStatusBar(view!)
            action?()
        })
        
        UIViewController.showNotificationOnTopOfStatusBar(view!, duration: duration)
        return view!
    }
}
