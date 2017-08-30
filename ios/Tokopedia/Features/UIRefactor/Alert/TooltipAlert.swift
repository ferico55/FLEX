//
//  TooltipAlert.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 7/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import CFAlertViewController
import SnapKit

@objc(TooltipAlert)
class TooltipAlert: NSObject {
    class func createAlert(title: String, subtitle: String, image: UIImage, buttons: [CFAlertAction]?) -> CFAlertViewController {
        let style = UIDevice.current.userInterfaceIdiom == .pad ? CFAlertViewController.CFAlertControllerStyle.alert : CFAlertViewController.CFAlertControllerStyle.actionSheet
        let actionSheet = CFAlertViewController.alertController(title: nil, message: nil, textAlignment: .center, preferredStyle: style, didDismissAlertHandler: nil)
        actionSheet.headerView = createHeaderView(title: title, subtitle: subtitle, image: image)
        
        if let buttons = buttons {
            for button in buttons {
                actionSheet.addAction(button)
            }
        }
        
        return actionSheet
    }
    
    private class func createHeaderView(title: String, subtitle: String, image: UIImage) -> UIView {
        let headerView = UIView()
        let imageView = UIImageView(image: image)
        let titleLabel = UILabel()
        titleLabel.font = UIFont.title1ThemeSemibold()
        titleLabel.text = title
        titleLabel.textColor = UIColor.tpPrimaryBlackText()
        
        let message = UILabel()
        message.font = UIFont.largeTheme()
        message.textColor = UIColor.tpSecondaryBlackText()
        message.numberOfLines = 0
        message.text = subtitle
        message.lineBreakMode = .byWordWrapping
        message.sizeToFit()
        
        headerView.addSubview(titleLabel)
        headerView.addSubview(message)
        headerView.addSubview(imageView)
        
        titleLabel.snp.makeConstraints({ make in
            make.top.equalTo(headerView.snp.top).inset(20)
            make.left.equalTo(headerView.snp.left).inset(20)
            make.right.equalTo(message.snp.right)
        })
        
        message.snp.makeConstraints({ make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(imageView.snp.left)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        })
        
        imageView.snp.makeConstraints({ make in
            make.top.equalTo(titleLabel.snp.top)
            make.right.equalTo(headerView.snp.right).inset(20)
            make.height.equalTo(image.size.height)
            make.width.equalTo(image.size.width)
            make.bottom.equalTo(headerView.snp.bottom).inset(10)
        })
        
        imageView.contentMode = .scaleAspectFit
        
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height)
        headerView.setNeedsLayout()
        
        return headerView
    }
}
