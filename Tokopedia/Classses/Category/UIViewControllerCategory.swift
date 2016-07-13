//
//  UIViewControllerCategory.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

@objc enum NotificationType : Int {
    case Error
    case Success
    case Warning
}

extension UIViewController {
    class func showNotificationWithMessage(message: String,
                                           type: Int,
                                           duration: NSTimeInterval,
                                           buttonTitle: String?,
                                           dismissable: Bool,
                                           action: (() -> Void)?) {
        let view = CustomNotificationView.newView()
        
        view.actionButton.layer.borderColor = UIColor.whiteColor().CGColor
        view.actionButton.layer.borderWidth = 1.0
        view.actionButton.clipsToBounds = true
        view.setMessageLabelWithText(message)
        
        if type == NotificationType.Error.rawValue {
            view.backgroundColor = UIColor(red: 255/255.0,
                                           green: 59/255.0,
                                           blue: 48/255.0,
                                           alpha: 1.0)
        } else if type == NotificationType.Success.rawValue {
            view.backgroundColor = UIColor(red: 10/255.0,
                                           green: 126/255.0,
                                           blue: 7/255.0,
                                           alpha: 1.0)
        } else if type == NotificationType.Warning.rawValue {
            view.backgroundColor = UIColor(red: 255/255.0,
                                           green: 204/255.0,
                                           blue: 102/255.0,
                                           alpha: 1.0)
        }
        
        if buttonTitle == nil {
            view.hideActionButton()
        } else {
            view.actionButton.setTitle(buttonTitle, forState: .Normal)
        }
        
        if !dismissable {
            view.hideCloseButton()
        }
        
        view.frame.size.width = UIScreen.mainScreen().bounds.size.width
        view.setNeedsLayout()
        view.layoutIfNeeded()
        view.messageLabel.preferredMaxLayoutWidth = view.messageLabel.frame.size.width
        
        let preferredHeight = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        view.frame.size.height = preferredHeight
        
        view.closeButton.bk_whenTapped {
            SwiftOverlays.closeAnnoyingNotificationOnTopOfStatusBar(view)
        }
        
        view.actionButton.bk_whenTapped {
            SwiftOverlays.closeAnnoyingNotificationOnTopOfStatusBar(view)
            action?()
        }
        
        UIViewController.showNotificationOnTopOfStatusBar(view, duration: duration, animated: true)
    }
}