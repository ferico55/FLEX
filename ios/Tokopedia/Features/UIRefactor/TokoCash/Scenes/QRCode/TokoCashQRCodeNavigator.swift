//
//  TokoCashQRCodeNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

@objc class TokoCashQRCodeNavigator: NSObject {
    
    private let storyboard: UIStoryboard
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func toQRPayment(_ QRInfo: TokoCashQRInfo) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashQRPaymentViewController.self)
        let navigator = TokoCashQRPaymentNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashQRPaymentViewModel(QRInfo: QRInfo, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
