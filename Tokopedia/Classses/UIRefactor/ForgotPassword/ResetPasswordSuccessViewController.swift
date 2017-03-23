//
//  ResetPasswordSuccessViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 1/23/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(ResetPasswordSuccessViewController)
class ResetPasswordSuccessViewController: UIViewController {
    
    private let email: String
    
    @IBOutlet private var messageLabel: TTTAttributedLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pendaftaran"
        AnalyticsManager.trackScreenName("Success Reset Password Page")
        self.setupMessage()
        self.resetPassword()
        // Do any additional setup after loading the view.
    }
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupMessage() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        let infoAttributedString = NSMutableAttributedString(string: "Anda sudah mempunyai akun Tokopedia dengan email ")
        
        let emailString = NSMutableAttributedString(string: email)
        
        emailString.addAttributes(
            [
                NSFontAttributeName : UIFont.boldSystemFont(ofSize: 13),
                NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.54)
            ],
            range: NSMakeRange(0, email.characters.count))
        
        infoAttributedString.addAttributes(
            [
                NSParagraphStyleAttributeName : paragraphStyle,
                NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.54),
                NSFontAttributeName : UIFont.largeTheme()
            ],
            range: NSMakeRange(0, infoAttributedString.length))
        
        infoAttributedString.append(emailString)
        
        self.messageLabel.attributedText = infoAttributedString
    }
    
    private func resetPassword() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/api/reset",
            method: .POST,
            parameter: ["email" : self.email ?? ""],
            mapping: GeneralAction.mapping(),
            onSuccess: { (successResult, operation) in
                let reset = successResult.dictionary()[""] as! GeneralAction
                
                if reset.message_error != nil {
                    StickyAlertView.showErrorMessage(reset.message_error)
                }
            },
            onFailure: { (error) in
                
        })
    }
    
    @IBAction private func tapLoginNowButton(_ sender: AnyObject) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "navigateToPageInTabBar"), object: "4")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}
