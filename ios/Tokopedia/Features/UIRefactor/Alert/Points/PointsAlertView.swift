//
//  PointsAlertView.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/27/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import NSAttributedString_DDHTML

@objc protocol PointsAlertViewDelegate {
    @objc optional func didDismissed(_ pointsAlertView: PointsAlertView)
}

class PointsAlertView: UIView, Modal {
    
    var delegate: PointsAlertViewDelegate? = nil

    var backgroundView = UIScrollView()
    var dialogView = UIView()
    
    convenience init(title: String, image: UIImage?, imageUrl: String?, message: String, buttons: [UIButton]?) {
        self.init(frame: UIScreen.main.bounds)
        initialize(title: title, image: image, imageUrl: imageUrl, message: message, buttons: buttons)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func initialize(title: String, image: UIImage?, imageUrl: String?, message: String, buttons: [UIButton]?) {
        dialogView.clipsToBounds = true
        
        // setup background view
        backgroundView.frame = frame
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.66)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTappedOnBackgroundView)))
        addSubview(backgroundView)
        
        // dialog view constants
        let dialogViewWidth = min(frame.width - 32, 300)
        let elementsPadding: CGFloat = 8.0
        let margin: CGFloat = 16.0
        
        // setup title
        let titleLabelMargin: CGFloat = 30.0
        let titleLabel = UILabel(frame: CGRect(x: titleLabelMargin, y: margin, width: dialogViewWidth - (titleLabelMargin * 2), height: 0))
        titleLabel.text = title
        titleLabel.font = .title1ThemeSemibold()
        titleLabel.textColor = .tpPrimaryBlackText()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.sizeToFit()
        titleLabel.frame.size = CGSize(width: dialogViewWidth - (titleLabelMargin * 2), height: titleLabel.frame.height)
        dialogView.addSubview(titleLabel)
        
        // setup image
        let imageViewMargin: CGFloat = 40.0
        let imageView = UIImageView(frame: CGRect(x: imageViewMargin, y: titleLabel.frame.origin.y + titleLabel.frame.height + elementsPadding, width: dialogViewWidth - (imageViewMargin * 2), height: dialogViewWidth - (imageViewMargin * 2)))
        if let image = image {
            imageView.image = image
        }
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            imageView.setImageWith(url)
        }
        dialogView.addSubview(imageView)
        
        // setup message
        let messageLabelMargin: CGFloat = 10.0
        let messageLabel = UILabel(frame: CGRect(x: messageLabelMargin, y: imageView.frame.height + imageView.frame.origin.y + elementsPadding, width: dialogViewWidth - (messageLabelMargin * 2), height: 0))
        messageLabel.attributedText = NSAttributedString(fromHTML: message)
        messageLabel.font = .largeTheme()
        messageLabel.textColor = .tpSecondaryBlackText()
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.sizeToFit()
        messageLabel.frame.size = CGSize(width: dialogViewWidth - (messageLabelMargin * 2), height: messageLabel.frame.height)
        dialogView.addSubview(messageLabel)
        
        // setup bottom border
        let separatorLineView = UIView()
        separatorLineView.frame.origin = CGPoint(x: 0, y: messageLabel.frame.origin.y + messageLabel.frame.height + margin)
        separatorLineView.frame.size = CGSize(width: dialogViewWidth, height: 1)
        separatorLineView.backgroundColor = UIColor.groupTableViewBackground
        dialogView.addSubview(separatorLineView)
        
        var dialogViewHeight = margin + titleLabel.frame.height + elementsPadding + imageView.frame.height + elementsPadding + messageLabel.frame.height + margin + separatorLineView.frame.height
        
        // setup buttons (if any)
        if let buttons = buttons {
            for button in buttons {
                button.frame = CGRect(x: 0, y: dialogViewHeight, width: dialogViewWidth, height: 48)
                button.addTarget(self, action: #selector(buttonDidTapped(sender:)), for: .touchUpInside)
                dialogView.addSubview(button)
                
                dialogViewHeight += button.frame.height
                
                let buttonSeparator = UIView()
                buttonSeparator.frame.origin = CGPoint(x: 0, y: dialogViewHeight)
                buttonSeparator.frame.size = CGSize(width: dialogViewWidth, height: 1)
                buttonSeparator.backgroundColor = UIColor.groupTableViewBackground
                dialogView.addSubview(buttonSeparator)
                
                dialogViewHeight += buttonSeparator.frame.height
            }
        }
        
        // setup dialog view
        dialogView.frame.origin = CGPoint(x: (frame.width - dialogViewWidth) / 2, y: frame.height)
        dialogView.frame.size = CGSize(width: dialogViewWidth, height: dialogViewHeight)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 6
        backgroundView.addSubview(dialogView)
        
        // setup content size
        backgroundView.isScrollEnabled = true
        backgroundView.contentSize = CGSize(width: frame.width, height: max(dialogView.frame.height + 32, frame.height))
    }
    
    func buttonDidTapped(sender: PointsAlertViewButton) {
        // dismiss first
        dismiss(animated: true)
        
        if let callback = sender.callback {
            callback()
        }
    }
    
    func didTappedOnBackgroundView() {
        self.delegate?.didDismissed?(self)
        dismiss(animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func showSelf(animated: Bool) {
        self.show(animated: animated)
    }
}
