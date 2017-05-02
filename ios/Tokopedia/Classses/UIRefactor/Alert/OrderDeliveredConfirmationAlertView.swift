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
    
    @IBOutlet fileprivate var alertTitleLabel: UILabel!
    @IBOutlet fileprivate var alertMessageLabel: UILabel!
    @IBOutlet fileprivate var freeReturnsInfoView: UIView!
    @IBOutlet fileprivate var freeReturnsInfoHeightConstraint: NSLayoutConstraint!
    
    var isFreeReturn: Bool = false{
        didSet{
            if isFreeReturn == true {
                freeReturnsInfoHeightConstraint.constant = 50;
                setHeight(300)
                freeReturnsInfoView.isHidden = false
            } else {
                freeReturnsInfoHeightConstraint.constant = 0;
                setHeight(300)
                freeReturnsInfoView.isHidden = true
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
            let attributedString = try! NSAttributedString(
                data: (message?.data(using: String.Encoding.utf8))!,
                options: [
                    NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                    NSCharacterEncodingDocumentAttribute : String.Encoding.utf8.rawValue],
                documentAttributes: nil)

            alertMessageLabel.attributedText = attributedString;
            alertMessageLabel.font = UIFont.largeTheme();
            alertMessageLabel.textAlignment = .center;
            
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

    @IBAction fileprivate func didTapOKButton(_ sender: UIButton) {
        dismiss()
        didOK?()
    }
    
    @IBAction fileprivate func didTapComplainButton(_ sender: UIButton) {
        dismiss()
        didComplain?()
    }
    
    @IBAction fileprivate func didCancel(_ sender: UIButton) {
        dismiss()
        didCancel?()
    }
    
    func dismiss() {
        self.dismiss(withClickedButtonIndex: 0, animated: true)
    }
    
    func setHeight(_ height: CGFloat) {
        self.frame.size.height = height
    }
}
