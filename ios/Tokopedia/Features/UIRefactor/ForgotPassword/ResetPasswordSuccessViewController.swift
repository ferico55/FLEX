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
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Daftar"
        AnalyticsManager.trackScreenName("Success Reset Password Page")
        self.setupTitle()
        self.resetPassword()
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
    }
    
    private func setupTitle() {
        self.titleLabel.text = "Anda sudah terdaftar di Tokopedia dengan email\n\(self.email)"
    }
    
    private func resetPassword() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        networkManager.request(
            withBaseUrl: NSString.accountsUrl(),
            path: "/api/reset",
            method: .POST,
            parameter: ["email": self.email ?? ""],
            mapping: GeneralAction.mapping(),
            onSuccess: { successResult, _ in
                let reset = successResult.dictionary()[""] as! GeneralAction
                
                if reset.message_error != nil {
                    StickyAlertView.showErrorMessage(reset.message_error)
                }
            },
            onFailure: { _ in
                
            }
        )
    }
    
    @IBAction private func tapLoginNowButton(_ sender: AnyObject) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "navigateToPageInTabBar"), object: "4")
        self.navigationController?.popToRootViewController(animated: true)
    }
}
