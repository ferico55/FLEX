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
        
        guard let alertView = view else { return UIView() }
        
        alertView.actionButton.layer.borderColor = UIColor.white.cgColor
        alertView.actionButton.layer.borderWidth = 1.0
        alertView.actionButton.clipsToBounds = true
        alertView.setMessageLabelWithText(message)
        
        if type == NotificationType.error.rawValue {
            alertView.backgroundColor = UIColor(red: 255/255.0,
                                           green: 59/255.0,
                                           blue: 48/255.0,
                                           alpha: 1.0)
        } else if type == NotificationType.success.rawValue {
            alertView.backgroundColor = UIColor(red: 10/255.0,
                                           green: 126/255.0,
                                           blue: 7/255.0,
                                           alpha: 1.0)
        } else if type == NotificationType.warning.rawValue {
            alertView.backgroundColor = UIColor(red: 255/255.0,
                                           green: 204/255.0,
                                           blue: 102/255.0,
                                           alpha: 1.0)
        }
        
        let preferredHeight = UIApplication.shared.statusBarFrame.size.height
            + UINavigationController().navigationBar.frame.height
        
        if buttonTitle == nil {
            alertView.hideActionButton()
            alertView.frame.size.height = preferredHeight
        } else {
            alertView.actionButton.setTitle(buttonTitle, for: .normal)
            
            if UIDevice.current.modelName.caseInsensitiveCompare("iPhone X") == ComparisonResult.orderedSame {
                alertView.frame.size.height = preferredHeight + 50
            } else {
                alertView.frame.size.height = preferredHeight + 30
            }
        }
        
        if !dismissable {
            alertView.hideCloseButton()
        }
        
        alertView.frame.size.width = UIScreen.main.bounds.size.width
        alertView.setNeedsLayout()
        alertView.layoutIfNeeded()
        alertView.messageLabel.preferredMaxLayoutWidth = alertView.messageLabel.frame.size.width
        
        alertView.closeButton.bk_(whenTapped:{
            SwiftOverlays.closeNotificationOnTopOfStatusBar(view!)
        })
        
        alertView.actionButton.bk_(whenTapped:{
            SwiftOverlays.closeNotificationOnTopOfStatusBar(view!)
            action?()
        })
        
        UIViewController.showOnTopOfStatusBar(alertView, duration: duration)
        return view!
    }
}
