//
//  OneClickRegisterViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
//import BCAXCOWidget

class OneClickRegisterViewController: UIViewController {

//    fileprivate let widget = InsertWidget()
    fileprivate let apiKey = "540fdef7-18c3-41d0-8596-242f1c59ce29"
    fileprivate let apiSeed = "dc88dfc6-837b-44bb-b767-d168e17e80cd"
    fileprivate let merchantID = "61005"
    fileprivate let viewModel: PaymentViewModel!
    fileprivate var userData = OneClickData()

    init(accessToken: String, viewModel: PaymentViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
//        view = UIView()
//        widget.delegate = self
//        title = "Tambah Kartu BCA Oneklik"
//        let authManager = UserAuthentificationManager()
//        widget.start()
//        widget.open(with: view,
//                    andAccessToken: accessToken,
//                    apiKey: apiKey,
//                    apiSeed: apiSeed,
//                    customerIDMerchant: authManager.getUserId(),
//                    merchantID: merchantID)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

//extension OneClickRegisterViewController: BCADelegate {
//    // This method will be called when a customer tries to register an existing CredentialNo to CustomerIDMerchant
//    func onBCARegistered(_: String!) {
//    }
//    
//    // This method will be called for successful registration and edit limit
//    func onBCASuccess(_ successObject: [AnyHashable: Any]!) {
//        guard let tokenID = successObject["xcoID"] as? String,
//            let credentialType = successObject["credentialType"] as? String,
//            let credentialNumber = successObject["credentialNo"] as? String,
//            let limit = successObject["maxLimit"] as? String else {
//                return
//        }
//        
//        let data = OneClickData(
//            tokenID: tokenID,
//            credentialType: credentialType,
//            credentialNumber: credentialNumber,
//            maxLimit: limit)
//        self.viewModel.registerOneClickData(data)
//    }
//    
//    // This method will be called when the Access Token used is expired and Merchant need to provide new Access Token (From step 1)
//    func onBCATokenExpired(_: String!) {
//    }
//    
//    // This method will be called to close widget at any time. Merchant to go back to 1 page before Open Widget
//    func onBCACloseWidget() {
//        widget.stop()
//        navigationController?.popViewController(animated: true)
//    }
//}
