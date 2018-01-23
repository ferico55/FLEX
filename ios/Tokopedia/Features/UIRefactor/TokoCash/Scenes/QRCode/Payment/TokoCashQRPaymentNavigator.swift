//
//  TokoCashQRCodeNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashQRPaymentNavigator {
    
    private let storyboard: UIStoryboard
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func toQRPaymentSuccess(_ paymentInfo: TokoCashPayment) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashQRPaymentSuccessViewController.self)
        let navigator = TokoCashQRPaymentSuccessNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashQRPaymentSuccessViewModel(paymentInfo: paymentInfo, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func toQRPaymentFailed() {
        let vc = storyboard.instantiateViewController(ofType: TokoCashQRPaymentFailedViewController.self)
        let navigator = TokoCashQRPaymentFailedNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashQRPaymentFailedViewModel(navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
