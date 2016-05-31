//
//  UIViewControllerCategory.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 5/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    class func showNotification(message: String,
                                type: Int,
                                duration: NSTimeInterval,
                                buttonTitle: String?,
                                dismissable: Bool,
                                action: (() -> Void)?) {
        let view = CustomNotificationView.newView()
        
        view.setMessageLabelWithText(message as String)
        
        if buttonTitle == nil {
            view.hideActionButton()
        } else {
            view.actionButton.setTitle(buttonTitle, forState: .Normal)
        }
        
        if !dismissable {
            view.hideCloseButton()
        }
        
        var notificationViewFrame = view.frame
        notificationViewFrame.size.width = UIScreen.mainScreen().bounds.size.width
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
        
        let preferredHeight = view.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
        notificationViewFrame.size.height = preferredHeight
        
        view.frame = notificationViewFrame
        
        
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