//
//  RegisterPhoneNumberNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 02/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class RegisterPhoneNumberNavigator {
    
    private let navigationController: UINavigationController?
    
    public init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }

    public func toTnC() {
        let webViewController = WKWebViewController(urlString: "https://m.tokopedia.com/terms.pl")
        webViewController.title = "Syarat dan Ketentuan"
        navigationController?.pushViewController(webViewController, animated: true)
    }

    public func toPrivacyPolicy() {
        let webViewController = WKWebViewController(urlString: "https://m.tokopedia.com/privacy.pl")
        webViewController.title = "Kebijakan Privasi"
        navigationController?.pushViewController(webViewController, animated: true)
    }

    public func toLoginPhoneNumber(_ tokoCashData: TokoCashLoginSendOTPResponse) {
        let controller = LoginPhoneNumberOTPViewController(nibName: nil, bundle: nil)
        controller.hidesBottomBarWhenPushed = true
        controller.tokoCashLoginSendOTPResponse = tokoCashData
        navigationController?.pushViewController(controller, animated: true)
    }
    
    public func toCOTP(_ modeDetail: ModeListDetail, accountInfo: AccountInfo, delegate: CentralizedOTPDelegate) {
        let vc = CentralizedOTPViewController(otpType: .registerPhoneNumber)
        vc.modeDetail = modeDetail
        vc.accountInfo = accountInfo
        vc.delegate = delegate
        let nc = UINavigationController(rootViewController: vc)
        navigationController?.present(nc, animated: true, completion: nil)
    }
    
   
}
