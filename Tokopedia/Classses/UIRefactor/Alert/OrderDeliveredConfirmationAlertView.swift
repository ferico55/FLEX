//
//  FreeReturnsConfirmationAlertView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class OrderDeliveredConfirmationAlertView: TKPDAlertView {
    
    var didComplain: (() -> Void)?
    
    var didOK: (() -> Void)?
    
    var didCancel: (() -> Void)?
    
    @IBOutlet private var alertTitleLabel: UILabel!
    @IBOutlet private var alertMessageLabel: UILabel!
    @IBOutlet private var freeReturnsInfoView: UIView!
    @IBOutlet private var freeReturnsInfoHeightConstraint: NSLayoutConstraint!
    
    var isFreeReturn: Bool = false{
        didSet{
            if isFreeReturn == true {
                freeReturnsInfoHeightConstraint.constant = 50;
                setHeight(300)
                freeReturnsInfoView.hidden = false
            } else {
                freeReturnsInfoHeightConstraint.constant = 0;
                setHeight(250)
                freeReturnsInfoView.hidden = true
            }
        }
    }
    
    var title: String? {
        didSet{
            alertTitleLabel.text = title
        }
    }
    
    var message: String? {
        didSet{
            alertMessageLabel.text = message
            let attributedString = try! NSAttributedString(data: (message?.dataUsingEncoding(NSUTF8StringEncoding))!, options: [NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute : NSNumber(unsignedInteger:NSUTF8StringEncoding)], documentAttributes: nil)

            alertMessageLabel.attributedText = attributedString;
            alertMessageLabel.font = UIFont.largeTheme();
            alertMessageLabel.textAlignment = .Center;
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.frame.size.width = 300
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBAction private func didTapOKButton(sender: UIButton) {
        dismiss()
        didOK?()
    }
    
    @IBAction private func didTapComplainButton(sender: UIButton) {
        dismiss()
        didComplain?()
    }
    
    @IBAction private func didCancel(sender: UIButton) {
        dismiss()
        didCancel?()
    }
    
    func dismiss() {
        self.dismissWithClickedButtonIndex(0, animated: true)
    }
    
    func setHeight(height: CGFloat) {
        self.frame.size.height = height
    }
}
