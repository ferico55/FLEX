//
//  OtherVerificationViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 29/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class OtherVerificationViewController: UIViewController {
    
    @IBOutlet weak var smsView: UIView!
    @IBOutlet weak var phoneCallView: UIView!
    @IBOutlet weak var smsLabel: UILabel!
    @IBOutlet weak var phoneCallLabel: UILabel!
    internal var phoneNumber : String!
    internal var onTapResend: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    // MARK: Setup View
    private func setupView() {
        self.title = "Verifikasi"
        
        // MARK: Set phone number on both label
        let regularFont = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.tpSecondaryBlackText()]
        let semiboldFont = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()]
        
        let smsLabelString = NSMutableAttributedString(string: "Melalui SMS ke nomor \n\(self.phoneNumber ?? "").", attributes: regularFont)
        smsLabelString.addAttributes(semiboldFont, range: NSRange(location: 8, length:3))
        self.smsLabel.attributedText = smsLabelString
        
        let phoneCallLabelString = NSMutableAttributedString(string: "Melalui panggilan telepon \nke nomor \(self.phoneNumber ?? "").", attributes: regularFont)
        phoneCallLabelString.addAttributes(semiboldFont, range: NSRange(location: 8, length: 17))
        self.phoneCallLabel.attributedText = phoneCallLabelString
        
        // MARK: Set Gesture for SMS
        let tapSms = UITapGestureRecognizer(target: self, action: #selector(self.sendOtpBySms(_:)))
        self.smsView.addGestureRecognizer(tapSms)
        
        // MARK: Set Gesture for Phone Call
        let tapPhoneCall = UITapGestureRecognizer(target: self, action: #selector(self.sendOtpByPhoneCall(_:)))
        self.phoneCallView.addGestureRecognizer(tapPhoneCall)
    }
    
    @objc func sendOtpBySms(_ sender: UITapGestureRecognizer) {
        AnalyticsManager.trackEventName("clickLogin", category: "phone verification", action: "change method", label: "sms")
        self.onTapResend?(false)
    }
    
    @objc func sendOtpByPhoneCall(_ sender: UITapGestureRecognizer) {
        AnalyticsManager.trackEventName("clickLogin", category: "phone verification", action: "change method", label: "phone")
        self.onTapResend?(true)
    }
}
