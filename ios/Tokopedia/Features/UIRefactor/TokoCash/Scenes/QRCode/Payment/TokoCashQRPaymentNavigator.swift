//
//  TokoCashQRCodeNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashQRPaymentNavigator {
    
    private let navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func toQRPaymentSuccess(_ paymentInfo: TokoCashPayment) {
        let vc = TokoCashQRPaymentSuccessViewController()
        let navigator = TokoCashQRPaymentSuccessNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashQRPaymentSuccessViewModel(paymentInfo: paymentInfo, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    public func toQRPaymentFailed() {
        let vc = TokoCashQRPaymentFailedViewController()
        let navigator = TokoCashQRPaymentFailedNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashQRPaymentFailedViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
