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
    class func createAlert(title: String, subtitle: String, image: UIImage, buttons: [CFAlertAction]?, isAlternative: Bool = true) -> CFAlertViewController {
        let style = UIDevice.current.userInterfaceIdiom == .pad ? CFAlertViewController.CFAlertControllerStyle.alert : CFAlertViewController.CFAlertControllerStyle.actionSheet
        let actionSheet = CFAlertViewController.alertController(title: nil, message: nil, textAlignment: .center, preferredStyle: style, didDismissAlertHandler: nil)
        
        actionSheet.headerView = createHeaderView(title: title, subtitle: subtitle, image: image, isAlternative: isAlternative)
        
        if let buttons = buttons {
            for button in buttons {
                actionSheet.addAction(button)
            }
        }
        
        return actionSheet
    }
    
    class func createReputationAlert(negative: Int, neutral: Int, positive: Int, buttons: [CFAlertAction]?) -> CFAlertViewController {
        let style = UIDevice.current.userInterfaceIdiom == .pad ? CFAlertViewController.CFAlertControllerStyle.alert : CFAlertViewController.CFAlertControllerStyle.actionSheet
        let actionSheet = CFAlertViewController.alertController(title: nil, message: nil, textAlignment: .center, preferredStyle: style, didDismissAlertHandler: nil)
        
        actionSheet.headerView = createReputationHeaderView(negative: negative, neutral: neutral, positive: positive)
        
        if let buttons = buttons {
            for button in buttons {
                actionSheet.addAction(button)
            }
        }
        
        return actionSheet
    }

    class func createSellerReputationAlert(imageUrl:String, point:Int, buttons: [CFAlertAction]?) -> CFAlertViewController {
        let style = UIDevice.current.userInterfaceIdiom == .pad ? CFAlertViewController.CFAlertControllerStyle.alert : CFAlertViewController.CFAlertControllerStyle.actionSheet
        let actionSheet = CFAlertViewController.alertController(title: nil, message: nil, textAlignment: .center, preferredStyle: style, didDismissAlertHandler: nil)
        
        actionSheet.headerView = createSellerReputationHeaderView(imageUrl: imageUrl, point: point)
        
        if let buttons = buttons {
            for button in buttons {
                actionSheet.addAction(button)
            }
        }
        
        return actionSheet
    }
    
    private class func createSellerReputationHeaderView(imageUrl: String, point: Int) -> UIView {
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.title1ThemeSemibold()
        titleLabel.text = "Reputasi Toko"
        titleLabel.textColor = UIColor.tpPrimaryBlackText()
        headerView.addSubview(titleLabel)
        
        let message = UILabel()
        message.font = UIFont.largeTheme()
        message.textColor = UIColor.tpSecondaryBlackText()
        message.text = "Nilai toko yang diberikan pembeli"
        headerView.addSubview(message)
        
        titleLabel.snp.makeConstraints({ make in
            make.top.equalTo(headerView.snp.top).inset(20)
            make.left.equalTo(headerView.snp.left).inset(20)
            make.right.equalTo(headerView.snp.right).inset(20)
        })
        
        message.snp.makeConstraints({ make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(headerView.snp.right).inset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        })
        
        do {
            guard let url = URL(string: imageUrl) else {
                titleLabel.text = ""
                message.text = "Maaf, Permohonan Anda tidak dapat diproses. Mohon dicoba kembali."
                
                titleLabel.snp.makeConstraints({ make in
                    make.height.equalTo(0)
                })
                message.numberOfLines = 0
                message.lineBreakMode = .byWordWrapping
                message.snp.makeConstraints({ make in
                    make.bottom.equalTo(headerView.snp.bottom)
                })
                let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height + 20)
                headerView.setNeedsLayout()
                return headerView
            }
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else {
                titleLabel.text = ""
                message.text = "Maaf, Permohonan Anda tidak dapat diproses. Mohon dicoba kembali."
                
                titleLabel.snp.makeConstraints({ make in
                    make.height.equalTo(0)
                })
                message.numberOfLines = 0
                message.lineBreakMode = .byWordWrapping
                message.snp.makeConstraints({ make in
                    make.bottom.equalTo(headerView.snp.bottom)
                })
                let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
                headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height + 20)
                headerView.setNeedsLayout()
                return headerView
            }
            let reputationImage = UIImageView(image: image)
            reputationImage.contentMode = .scaleAspectFill
            headerView.addSubview(reputationImage)
            
            reputationImage.snp.makeConstraints({ make in
                make.top.equalTo(message.snp.bottom).offset(10)
                make.left.equalTo(message.snp.left)
                make.height.equalTo(24)
                make.width.equalTo(24/image.size.height * image.size.width)
                make.bottom.equalTo(headerView.snp.bottom)
            })
            
            let pointLabel = UILabel()
            pointLabel.font = UIFont.microTheme()
            pointLabel.textColor = UIColor.tpDisabledBlackText()
            pointLabel.text = "\(point) Poin"
            headerView.addSubview(pointLabel)
            
            pointLabel.snp.makeConstraints({ make in
                make.left.equalTo(reputationImage.snp.right).offset(10)
                make.centerY.equalTo(reputationImage.snp.centerY)
            })
        }
        catch {
            titleLabel.text = ""
            message.text = "Maaf, Permohonan Anda tidak dapat diproses. Mohon dicoba kembali."
            
            titleLabel.snp.makeConstraints({ make in
                make.height.equalTo(0)
            })
            message.numberOfLines = 0
            message.lineBreakMode = .byWordWrapping
            message.snp.makeConstraints({ make in
                make.bottom.equalTo(headerView.snp.bottom)
            })
            let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
            headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height + 20)
            headerView.setNeedsLayout()
            return headerView
        }
        
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height)
        headerView.setNeedsLayout()
        return headerView
    }
    
    private class func createReputationHeaderView(negative: Int, neutral: Int, positive:Int) -> UIView {
        let headerView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.title1ThemeSemibold()
        titleLabel.text = "Reputasi Pembeli"
        titleLabel.textColor = UIColor.tpPrimaryBlackText()
        headerView.addSubview(titleLabel)
        
        let message = UILabel()
        message.font = UIFont.largeTheme()
        message.textColor = UIColor.tpSecondaryBlackText()
        message.text = "Nilai pembeli yang diberikan penjual"
        headerView.addSubview(message)
        
        titleLabel.snp.makeConstraints({ make in
            make.top.equalTo(headerView.snp.top).inset(20)
            make.left.equalTo(headerView.snp.left).inset(20)
            make.right.equalTo(headerView.snp.right).inset(20)
        })
        
        message.snp.makeConstraints({ make in
            make.left.equalTo(titleLabel.snp.left)
            make.right.equalTo(headerView.snp.right).inset(10)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        })
        
        let smileyImage = UIImageView(image: UIImage(named: "icon_smile50"))
        headerView.addSubview(smileyImage)
        smileyImage.snp.makeConstraints({ make in
            make.top.equalTo(message.snp.bottom).offset(10)
            make.left.equalTo(message.snp.left)
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.bottom.equalTo(headerView.snp.bottom)
        })
        
        let smileyLabel = UILabel()
        smileyLabel.font = UIFont.microTheme()
        smileyLabel.textColor = UIColor.tpDisabledBlackText()
        smileyLabel.text = "\(positive)"
        headerView.addSubview(smileyLabel)
        smileyLabel.snp.makeConstraints({ make in
            make.left.equalTo(smileyImage.snp.right).offset(10)
            make.centerY.equalTo(smileyImage.snp.centerY)
        })
        
        let sadImage = UIImageView(image: UIImage(named: "icon_sad50"))
        headerView.addSubview(sadImage)
        sadImage.snp.makeConstraints({ make in
            make.centerY.equalTo(smileyImage.snp.centerY)
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.left.equalTo(smileyLabel.snp.right).offset(20)
        })
        
        let sadLabel = UILabel()
        sadLabel.font = UIFont.microTheme()
        sadLabel.textColor = UIColor.tpDisabledBlackText()
        sadLabel.text = "\(negative)"
        headerView.addSubview(sadLabel)
        sadLabel.snp.makeConstraints({ make in
            make.left.equalTo(sadImage.snp.right).offset(10)
            make.centerY.equalTo(smileyImage.snp.centerY)
        })
        
        let neutralImage = UIImageView(image: UIImage(named: "icon_netral50"))
        headerView.addSubview(neutralImage)
        neutralImage.snp.makeConstraints({ make in
            make.centerY.equalTo(smileyImage.snp.centerY)
            make.height.equalTo(24)
            make.width.equalTo(24)
            make.left.equalTo(sadLabel.snp.right).offset(20)
        })
        
        let neutralLabel = UILabel()
        neutralLabel.font = UIFont.microTheme()
        neutralLabel.textColor = UIColor.tpDisabledBlackText()
        neutralLabel.text = "\(neutral)"
        headerView.addSubview(neutralLabel)
        neutralLabel.snp.makeConstraints({ make in
            make.left.equalTo(neutralImage.snp.right).offset(10)
            make.centerY.equalTo(smileyImage.snp.centerY)
        })

        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height)
        headerView.setNeedsLayout()
        
        return headerView
    }
    
    private class func createHeaderView(title: String, subtitle: String, image: UIImage, isAlternative: Bool) -> UIView {
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
        
        if !isAlternative {
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
        } else {
            titleLabel.snp.makeConstraints({ make in
                make.top.equalTo(headerView.snp.top).inset(20)
                make.left.equalTo(headerView.snp.left).inset(20)
                make.right.equalTo(headerView.snp.right).inset(20)
            })
            
            imageView.snp.makeConstraints({ make in
                make.top.equalTo(titleLabel.snp.bottom).offset(20)
                make.right.equalTo(headerView.snp.right).inset(20)
                make.height.equalTo(image.size.height)
                make.width.equalTo(image.size.width)
                make.bottom.equalTo(headerView.snp.bottom).inset(UIDevice.current.userInterfaceIdiom == .pad ? 10 : 35)
            })
            
            message.snp.makeConstraints({ make in
                make.left.equalTo(titleLabel.snp.left)
                make.right.equalTo(imageView.snp.left)
                make.top.equalTo(titleLabel.snp.bottom).offset(10)
                make.bottom.equalTo(headerView.snp.bottom)
            })
        }
        
        imageView.contentMode = .scaleAspectFit
        
        let size = headerView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        headerView.frame = CGRect(x: headerView.frame.origin.x, y: headerView.frame.origin.y, width: headerView.frame.width, height: size.height)
        headerView.setNeedsLayout()
        
        return headerView
    }
}
