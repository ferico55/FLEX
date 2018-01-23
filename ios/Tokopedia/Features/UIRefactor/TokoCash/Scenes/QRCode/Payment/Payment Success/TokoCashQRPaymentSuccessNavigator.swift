//
//  TokoCashQRPaymentSuccessNavigator.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 04/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashQRPaymentSuccessNavigator {
    
    private let storyboard: UIStoryboard
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.storyboard = UIStoryboard(name: "TokoCash", bundle: nil)
        self.navigationController = navigationController
    }
    
    func backToHome() {
        navigationController.popToRootViewController(animated: true)
    }
    
    func toHelp(_ transactionId: String) {
        let vc = storyboard.instantiateViewController(ofType: TokoCashHelpViewController.self)
        let navigator = TokoCashHelpNavigator(navigationController: navigationController)
        vc.viewModel = TokoCashHelpViewModel(transactionId, navigator: navigator)
        navigationController.pushViewController(vc, animated: true)
    }
}
